--[[
    =============================================
    INTEGRAÇÃO AUTOMÁTICA - QB-LOGS
    =============================================
    Hooks automáticos com qbx_core, ox_inventory,
    qbx_vehicleshop, qbx_bankrobbery, qbx_jewelery
    e qbx_houserobbery.

    Este arquivo escuta eventos REAIS do framework
    sem precisar que outros scripts chamem qb-logs.
]]

-- =============================================
-- QBOX/QBCORE - MUDANÇA DE DINHEIRO (AUTOMÁTICO)
-- =============================================
-- Evento disparado por qbx_core em TODA mudança de dinheiro
-- Parâmetros: source, moneyType, amount, actionType ('add'|'remove'|'set'), reason

AddEventHandler('QBCore:Server:OnMoneyChange', function(src, moneyType, amount, actionType, reason)
    if not src or src <= 0 then return end

    local actionLabels = {
        add = '💰 RECEBEU DINHEIRO',
        remove = '💸 PERDEU DINHEIRO',
        set = '🔧 DINHEIRO DEFINIDO',
    }

    local char = GetCharacterData(src)
    local newBalance = '?'

    -- Buscar saldo via GetCharacterData's Player (usa os mesmos fallbacks)
    local fw = GetFramework()
    if fw then
        local ok, Player = pcall(fw.Functions.GetPlayer, src)
        if ok and Player and Player.PlayerData and Player.PlayerData.money then
            newBalance = Player.PlayerData.money[moneyType] or '?'
        end
    end
    -- Fallback: export direto
    if newBalance == '?' and GetResourceState('qbx_core') == 'started' then
        local ok, Player = pcall(exports['qbx_core'].GetPlayer, exports['qbx_core'], src)
        if ok and Player and Player.PlayerData and Player.PlayerData.money then
            newBalance = Player.PlayerData.money[moneyType] or '?'
        end
    end

    SendPlayerLog(src, 'money', actionLabels[actionType] or 'ALTERAÇÃO DE DINHEIRO',
        'Tipo: **' .. (moneyType or 'cash') .. '**' ..
        '\nQuantidade: **$' .. (amount or 0) .. '**' ..
        '\nAção: **' .. (actionType or '?') .. '**' ..
        '\nNovo Saldo: **$' .. newBalance .. '**' ..
        '\nMotivo: ' .. (reason or 'Não especificado'))
end)

-- =============================================
-- QBOX/QBCORE - MUDANÇA DE JOB (AUTOMÁTICO)
-- Roteia para canal específico por job
-- =============================================

local jobChannelMap = {
    ambulance = 'job_ambulance',
    mechanic  = 'job_mechanic',
    police    = 'job_police',
    sheriff   = 'job_police',
    bcso      = 'job_police',
}

AddEventHandler('QBCore:Server:OnJobUpdate', function(src, jobData)
    if not src or src <= 0 then return end

    local jobName = jobData.name or ''
    local logType = jobChannelMap[jobName] or 'job_general'

    SendPlayerLog(src, logType, 'MUDOU DE EMPREGO',
        'Novo Job: **' .. (jobData.label or jobName or '?') .. '**' ..
        '\nGrade: **' .. (jobData.grade and jobData.grade.name or '?') .. ' (Nível ' .. (jobData.grade and jobData.grade.level or 0) .. ')**' ..
        '\nEm serviço: **' .. (jobData.onduty and 'Sim' or 'Não') .. '**')
end)

-- =============================================
-- QBOX/QBCORE - MUDANÇA DE GANG (AUTOMÁTICO)
-- =============================================

AddEventHandler('QBCore:Server:OnGangUpdate', function(src, gangData)
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'general', 'MUDOU DE GANGUE',
        'Nova Gang: **' .. (gangData.label or gangData.name or '?') .. '**' ..
        '\nGrade: **' .. (gangData.grade and gangData.grade.name or '?') .. ' (Nível ' .. (gangData.grade and gangData.grade.level or 0) .. ')**')
end)

-- =============================================
-- QBOX/QBCORE - DUTY ON/OFF (AUTOMÁTICO)
-- =============================================

AddEventHandler('QBCore:Server:SetDuty', function(src, onDuty)
    if not src or src <= 0 then return end

    local char = GetCharacterData(src)
    local status = onDuty and '🟢 ENTROU EM SERVIÇO' or '🔴 SAIU DE SERVIÇO'

    SendPlayerLog(src, 'police', status,
        'Job: **' .. char.job .. '**')
end)

-- =============================================
-- OX_INVENTORY - HOOKS AUTOMÁTICOS
-- =============================================
-- Registra hooks no ox_inventory para capturar
-- adição, remoção, troca e uso de itens.

CreateThread(function()
    -- Aguarda o ox_inventory iniciar completamente
    while GetResourceState('ox_inventory') ~= 'started' do
        Wait(500)
    end
    Wait(2000) -- Espera extra para garantir que exports estão prontos

    -- ========== HOOK: ITEM ADICIONADO ==========
    exports['ox_inventory']:registerHook('addItem', function(payload)
        local src = payload.source
        if not src or src <= 0 then return true end

        local itemName = type(payload.item) == 'table' and (payload.item.label or payload.item.name) or payload.item
        local itemCount = payload.count or 1

        SendPlayerLog(src, 'inventory', 'ITEM ADICIONADO',
            'Item: **' .. (itemName or 'Desconhecido') .. '**' ..
            '\nQuantidade: **' .. itemCount .. '**')

        return true -- Não bloqueia a ação
    end, {})

    -- ========== HOOK: ITEM REMOVIDO ==========
    exports['ox_inventory']:registerHook('removeItem', function(payload)
        local src = payload.source
        if not src or src <= 0 then return true end

        local itemName = type(payload.item) == 'table' and (payload.item.label or payload.item.name) or payload.item
        local itemCount = payload.count or 1

        SendPlayerLog(src, 'inventory', 'ITEM REMOVIDO',
            'Item: **' .. (itemName or 'Desconhecido') .. '**' ..
            '\nQuantidade: **' .. itemCount .. '**')

        return true
    end, {})

    -- ========== HOOK: ITEM USADO ==========
    exports['ox_inventory']:registerHook('usingItem', function(payload)
        local src = payload.source
        if not src or src <= 0 then return true end

        local item = payload.item
        local itemName = item and (item.label or item.name) or 'Desconhecido'

        SendPlayerLog(src, 'inventory', 'ITEM USADO',
            'Item: **' .. itemName .. '**' ..
            '\nSlot: **' .. (item and item.slot or '?') .. '**')

        return true
    end, {})

    -- ========== HOOK: TROCA/TRANSFERÊNCIA DE ITENS ==========
    exports['ox_inventory']:registerHook('swapItems', function(payload)
        local src = payload.source
        if not src or src <= 0 then return true end

        local fromInv = tostring(payload.fromInventory or '?')
        local toInv = tostring(payload.toInventory or '?')

        -- Só loga se for entre inventários diferentes (transferência)
        if fromInv == toInv then return true end

        local fromSlot = payload.fromSlot
        local itemName = 'Desconhecido'
        local itemCount = payload.count or 0

        if type(fromSlot) == 'table' then
            itemName = fromSlot.label or fromSlot.name or 'Desconhecido'
        end

        -- Detectar drop no chão
        local logType = 'drop'

        if toInv == 'newdrop' or (type(toInv) == 'string' and toInv:find('drop')) then
            actionLabel = 'DROPOU ITEM NO CHÃO'
            logType = 'drop'
        end

        SendPlayerLog(src, logType, actionLabel,
            'Item: **' .. itemName .. '**' ..
            '\nQuantidade: **' .. itemCount .. '**' ..
            '\nDe: **' .. fromInv .. '**' ..
            '\nPara: **' .. toInv .. '**')

        return true
    end, {})

    -- ========== HOOK: COMPRA EM LOJA ==========
    exports['ox_inventory']:registerHook('buyItem', function(payload)
        local src = payload.source
        if not src or src <= 0 then return true end

        local itemName = type(payload.itemName) == 'string' and payload.itemName or
                         (type(payload.item) == 'table' and (payload.item.label or payload.item.name) or 'Desconhecido')
        local count = payload.count or 1
        local price = payload.totalPrice or payload.price or 0

        SendPlayerLog(src, 'shop', 'COMPROU ITEM EM LOJA',
            'Item: **' .. itemName .. '**' ..
            '\nQuantidade: **' .. count .. '**' ..
            '\nPreço Total: **$' .. price .. '**' ..
            '\nLoja: **' .. tostring(payload.shopType or payload.inventoryId or '?') .. '**')

        return true
    end, {})

    -- ========== HOOK: CRAFT DE ITEM ==========
    exports['ox_inventory']:registerHook('craftItem', function(payload)
        local src = payload.source
        if not src or src <= 0 then return true end

        local recipe = payload.recipe
        local recipeName = type(recipe) == 'table' and (recipe.label or recipe.name) or tostring(recipe or '?')

        SendPlayerLog(src, 'inventory', 'CRAFTOU ITEM',
            'Receita: **' .. recipeName .. '**')

        return true
    end, {})

    print('[qb-logs] Hooks do ox_inventory registrados com sucesso!')
end)

-- =============================================
-- QBOX VEHICLESHOP - COMPRA DE VEÍCULOS
-- =============================================

AddEventHandler('qbx_vehicleshop:server:buyShowroomVehicle', function(vehicleData)
    -- Este evento é RegisterNetEvent, então source é o comprador
    -- Porém ele é chamado internamente, então usamos um hook diferente
end)

-- Hook na compra monitorando o evento de dinheiro com reason 'vehicle-bought-in-showroom'
-- Já capturado pelo QBCore:Server:OnMoneyChange acima com reason

-- Interceptar compra via callback no vehicleshop
RegisterNetEvent('qbx_vehicleshop:server:buyShowroomVehicle', function(vehicleData)
    local src = source
    if not src or src <= 0 then return end

    local vehicle = vehicleData and vehicleData.buyVehicle or 'Desconhecido'

    SendPlayerLog(src, 'vehicles', 'COMPROU VEÍCULO NA CONCESSIONÁRIA',
        'Modelo: **' .. vehicle .. '**')
end)

-- Interceptar test drive
RegisterNetEvent('qbx_vehicleshop:server:testDrive', function(data)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'vehicles', 'INICIOU TEST DRIVE',
        'Modelo: **' .. (data and data.vehicle or 'Desconhecido') .. '**')
end)

-- Interceptar venda de vendedor para jogador
RegisterNetEvent('qbx_vehicleshop:server:sellShowroomVehicle', function(vehicle, playerId, vip)
    local src = source
    if not src or src <= 0 then return end

    local targetId = tonumber(playerId)

    local msg = '**--- VENDEDOR ---**\n'
    msg = msg .. BuildPlayerBlock(src) .. '\n\n'
    if targetId then
        msg = msg .. '**--- COMPRADOR ---**\n'
        msg = msg .. BuildPlayerBlock(targetId) .. '\n\n'
    end
    msg = msg .. '========================\n'
    msg = msg .. '**AÇÃO:** VENDA DE VEÍCULO\n'
    msg = msg .. '**Modelo:** ' .. (vehicle or 'Desconhecido') .. '\n'
    msg = msg .. '\n**[Data]:** ' .. GetFormattedDate()
    msg = msg .. '\n**[Hora]:** ' .. GetFormattedTime()

    SendLog('vehicles', '🚗 Venda de Veículo', msg, nil, nil)
end)

-- =============================================
-- QBOX BANK ROBBERY - ROUBOS AO BANCO
-- =============================================

RegisterNetEvent('qbx_bankrobbery:server:setBankState', function(bankId)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'robbery', 'INICIOU ROUBO AO BANCO',
        'Banco: **' .. (bankId or 'Desconhecido') .. '**', 15158332)
end)

RegisterNetEvent('qbx_bankrobbery:server:recieveItem', function(itemType, bankId, lockerId)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'robbery', 'PEGOU ITEM DO ROUBO AO BANCO',
        'Banco: **' .. (bankId or '?') .. '**' ..
        '\nCofre: **' .. (lockerId or '?') .. '**' ..
        '\nTipo: **' .. (itemType or '?') .. '**', 15158332)
end)

RegisterNetEvent('qbx_bankrobbery:server:callCops', function(copType, bank, coords)
    local src = source
    if not src or src <= 0 then return end

    local coordStr = coords and ('X: %.2f | Y: %.2f | Z: %.2f'):format(coords.x or 0, coords.y or 0, coords.z or 0) or '?'

    SendPlayerLog(src, 'robbery', 'ALERTA POLICIAL - ROUBO AO BANCO',
        'Tipo: **' .. (copType or '?') .. '**' ..
        '\nBanco: **' .. (bank or '?') .. '**' ..
        '\nCoordenadas: **' .. coordStr .. '**', 3447003)
end)

-- =============================================
-- QBOX JEWELERY - ROUBO À JOALHERIA
-- =============================================

RegisterNetEvent('qb-jewelery:server:endcabinet', function()
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'robbery', 'ROUBOU VITRINE DA JOALHERIA',
        'Tipo: Vitrine finalizada', 15158332)
end)

RegisterNetEvent('qb-jewellery:server:succeshackdoor', function()
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'robbery', 'HACKEOU PORTA DA JOALHERIA',
        'Status: **Hack bem-sucedido**', 15158332)
end)

RegisterNetEvent('qb-jewellery:server:failedhackdoor', function()
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'robbery', 'FALHOU HACK DA JOALHERIA',
        'Status: **Hack falhou**', 15844367)
end)

-- =============================================
-- QBOX HOUSE ROBBERY - ROUBO A CASAS
-- =============================================

RegisterNetEvent('qbx_houserobbery:server:enterHouse', function(index)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'robbery', 'ENTROU EM CASA PARA ROUBAR',
        'Casa: **#' .. (index or '?') .. '**', 15158332)
end)

RegisterNetEvent('qbx_houserobbery:server:leaveHouse', function()
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'robbery', 'SAIU DA CASA ROUBADA',
        'Jogador saiu da propriedade', 15844367)
end)

RegisterNetEvent('qbx_houserobbery:server:lootFinished', function(houseIndex, lootIndex)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'robbery', 'COLETOU LOOT EM CASA',
        'Casa: **#' .. (houseIndex or '?') .. '**' ..
        '\nLoot: **#' .. (lootIndex or '?') .. '**', 15158332)
end)

RegisterNetEvent('qbx_houserobbery:server:pickupFinished', function(houseIndex, pickupIndex)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'robbery', 'PEGOU OBJETO EM CASA',
        'Casa: **#' .. (houseIndex or '?') .. '**' ..
        '\nObjeto: **#' .. (pickupIndex or '?') .. '**', 15158332)
end)

-- =============================================
-- ALERTA POLICIAL GLOBAL
-- =============================================
-- Captura o evento police:server:policeAlert que é
-- disparado por vários recursos (bank, jewelery, house)

AddEventHandler('police:server:policeAlert', function(message, ...)
    SendLog('police', '🚨 Alerta Policial', '**' .. (message or 'Alerta sem descrição') .. '**', 3447003, nil)
end)

-- =============================================
-- QBOX/QBCORE - METADATA CHANGES
-- =============================================
-- Captura mudanças de metadata como hunger, thirst, stress

AddEventHandler('qbx_core:server:onSetMetaData', function(metadata, oldValue, newValue, src)
    -- Só loga metadata relevante para segurança
    local importantMeta = {
        ['isdead'] = true,
        ['inlaststand'] = true,
        ['armor'] = true,
        ['ishandcuffed'] = true,
        ['injail'] = true,
    }

    if not importantMeta[metadata] then return end
    if not src or src <= 0 then return end

    local labels = {
        ['isdead'] = newValue and '💀 MORREU' or '💚 REVIVEU',
        ['inlaststand'] = newValue and '🩸 ÚLTIMO SUSPIRO' or '💚 REANIMADO',
        ['armor'] = '🛡️ COLETE ALTERADO',
        ['ishandcuffed'] = newValue and '🔒 ALGEMADO' or '🔓 DESALGEMADO',
        ['injail'] = newValue and '🔒 PRESO' or '🔓 SOLTO DA PRISÃO',
    }

    local logType = metadata == 'injail' and 'prisao' or
                    metadata == 'ishandcuffed' and 'detido' or 'general'

    SendPlayerLog(src, logType, labels[metadata] or ('META: ' .. metadata),
        'Campo: **' .. metadata .. '**' ..
        '\nAnterior: **' .. tostring(oldValue) .. '**' ..
        '\nNovo: **' .. tostring(newValue) .. '**')
end)

-- =============================================
-- CHAT / COMANDOS (QBCORE)
-- =============================================

-- Captura comandos de chat executados
AddEventHandler('chatMessage', function(src, author, message)
    if not src or src <= 0 then return end
    -- Loga apenas comandos (começam com /)
    if message and message:sub(1, 1) == '/' then
        SendPlayerLog(src, 'staff', 'EXECUTOU COMANDO',
            'Comando: **' .. message .. '**')
    end
end)

-- =============================================
-- PLAYER DEATH (VIA METADATA - BACKUP)
-- =============================================
-- Caso baseevents não esteja ativo, captura morte via metadata

-- =============================================
-- RESOURCE START/STOP (COM ANTI-SPAM DE BOOT)
-- =============================================

-- Sistema de inicialização: acumula resources em vez de spammar
local startupMode = true
local startedResources = {}
local stoppedResources = {}
local startupTimer = nil

-- Resources do sistema que serão ignorados no relatório
local systemResources = {
    ['monitor'] = true,
    ['sessionmanager'] = true,
    ['sessionmanager-rdr3'] = true,
    ['spawnmanager'] = true,
    ['mapmanager'] = true,
    ['chat'] = true,
    ['hardcap'] = true,
    ['baseevents'] = true,
    ['yarn'] = true,
    ['webpack'] = true,
    ['fivem'] = true,
}

-- Envia o relatório final de inicialização
local function SendStartupReport()
    if not startupMode then return end
    startupMode = false

    local total = #startedResources
    if total == 0 then return end

    -- Montar lista (limitar a 40 por embed para não estourar limite do Discord)
    local listLines = {}
    for i, name in ipairs(startedResources) do
        table.insert(listLines, '`' .. name .. '`')
    end

    local listStr = table.concat(listLines, ' • ')

    -- Truncar se muito longo (Discord tem limite de 4096 chars na description)
    if #listStr > 3500 then
        listStr = listStr:sub(1, 3500) .. '\n... e mais'
    end

    local msg = '**Total de resources iniciados:** ' .. total .. '\n\n'
    msg = msg .. listStr .. '\n\n'
    msg = msg .. '========================\n'
    msg = msg .. '**[Data]:** ' .. GetFormattedDate() .. '\n'
    msg = msg .. '**[Hora]:** ' .. GetFormattedTime()

    SendLog('general', '📦 Relatório de Inicialização', msg, 3066993, nil)

    -- Limpar memória
    startedResources = {}
    stoppedResources = {}

    print('[qb-logs] Relatório de inicialização enviado (' .. total .. ' resources)')
end

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then return end

    if startupMode then
        -- Durante boot: acumular
        if not systemResources[resource] then
            table.insert(startedResources, resource)
        end

        -- Resetar timer a cada resource novo (espera 12s após o último)
        if startupTimer then
            -- Cancela timer anterior criando novo
        end
        startupTimer = true
        SetTimeout(12000, function()
            if startupMode then
                SendStartupReport()
            end
        end)
    else
        -- Pós-boot: log individual normal
        SendLog('staff', '📦 Resource Iniciado', '**' .. resource .. '** foi iniciado.\n\n**[Data]:** ' .. GetFormattedDate() .. '\n**[Hora]:** ' .. GetFormattedTime(), 3066993, nil)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then return end

    if startupMode then
        -- Ignora stops durante boot
        if not systemResources[resource] then
            table.insert(stoppedResources, resource)
        end
    else
        -- Pós-boot: log individual normal
        SendLog('staff', '📦 Resource Parado', '**' .. resource .. '** foi parado.\n\n**[Data]:** ' .. GetFormattedDate() .. '\n**[Hora]:** ' .. GetFormattedTime(), 15158332, nil)
    end
end)

-- Fallback: garantir que o relatório é enviado mesmo se o timer falhar
CreateThread(function()
    Wait(30000) -- 30 segundos é tempo suficiente para qualquer boot
    if startupMode then
        SendStartupReport()
    end
end)

-- =============================================
-- MENSAGEM DE INICIALIZAÇÃO
-- =============================================

CreateThread(function()
    Wait(3000)
    local integrations = {}

    if GetResourceState('qbx_core') == 'started' or GetResourceState('qb-core') == 'started' then
        table.insert(integrations, 'qbx_core (Dinheiro, Job, Duty, Metadata)')
    end
    if GetResourceState('ox_inventory') == 'started' then
        table.insert(integrations, 'ox_inventory (Items, Drops, Crafting, Lojas)')
    end
    if GetResourceState('qbx_vehicleshop') == 'started' then
        table.insert(integrations, 'qbx_vehicleshop (Compra/Venda/TestDrive)')
    end
    if GetResourceState('qbx_bankrobbery') == 'started' then
        table.insert(integrations, 'qbx_bankrobbery (Roubo ao Banco)')
    end
    if GetResourceState('qbx_jewelery') == 'started' then
        table.insert(integrations, 'qbx_jewelery (Roubo à Joalheria)')
    end
    if GetResourceState('qbx_houserobbery') == 'started' then
        table.insert(integrations, 'qbx_houserobbery (Roubo a Casas)')
    end

    print('[qb-logs] ======== INTEGRAÇÕES ========')
    for _, v in ipairs(integrations) do
        print('[qb-logs]  ✔ ' .. v)
    end
    print('[qb-logs] ==============================')
end)
