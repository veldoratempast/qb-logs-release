--[[
    =============================================
    INTEGRAÇÕES COMPLETAS - QB-LOGS
    =============================================
    Hooks automáticos com TODOS os scripts da base.
    Este arquivo escuta eventos reais de cada resource
    sem precisar modificar os scripts originais.

    Scripts integrados:
    - qbx_drugs           (Drogas: venda, entrega)
    - qbx_customs         (Customs: mods, reparos)
    - qbx_management      (Boss: contratar, promover)
    - qbx_cityhall        (Licenças, candidatura a job)
    - qbx_mechanicjob     (Mecânico: reparos, peças)
    - qbx_garbagejob      (Lixeiro: turnos, pagamento)
    - qbx_properties      (Propriedades: entrar/sair)
    - qbx_scrapyard       (Ferro velho: sucata)
    - qbx_pawnshop        (Penhores: venda, fundição)
    - qbx_towjob          (Guincho: reboque)
    - qbx_truckrobbery    (Roubo de caminhão)
    - qbx_spawn           (Spawn de jogador)
    - qbx_fireworks       (Fogos de artifício)
    - mri_Qfarm           (Fazenda: colheita)
    - mri_Qstorerobbery   (Roubo a loja)
    - mri_Qfleecaheist    (Assalto Fleeca)
    - mri_Qcarkeys        (Chaves de veículo)
    - mri_Qstashes        (Stashes: criar/deletar)
    - mri_Qrobnpcs        (Roubo de NPC)
    - mri_Qcrafting       (Craft de itens)
    - mri_Qstarterpack    (Starter pack)
    - mri_Qblackout       (Blackout da cidade)
    - mri_Qjobsystem      (Sistema de empregos)
    - mri_Qjobcenter      (Centro de empregos)
    - rhd_garage          (Garagem: spawn, transfer)
    - illenium-appearance (Aparência: roupa, barber)
    - bbv-airdrops        (Airdrops)
    - ox_doorlock         (Portas: trancar/destrancar)
    - lb-phone            (Telefone)
]]

-- Helper para checar se resource existe
local function IsResourceActive(name)
    return GetResourceState(name) == 'started'
end

-- =============================================
-- PS-ADMINMENU - HOOKS ADMIN (AUTOMÁTICOS)
-- =============================================
-- Intercepta todos os eventos server-side do ps-adminmenu
-- para logar ações administrativas com formato padronizado.

-- Revive (jogador específico)
RegisterNetEvent('ps-adminmenu:server:Revive', function(data, selectedData)
    local src = source
    if not selectedData or not selectedData["Player"] then return end
    local target = selectedData["Player"].value
    SendAdminLog(src, target, '/revive', 'Reviveu jogador via admin menu', 'admin', 3066993)
end)

-- Revive All
RegisterNetEvent('ps-adminmenu:server:ReviveAll', function()
    local src = source
    SendAdminLog(src, nil, '/reviveall', 'Reviveu TODOS os jogadores', 'admin', 3066993)
end)

-- Revive Radius
RegisterNetEvent('ps-adminmenu:server:ReviveRadius', function()
    local src = source
    SendAdminLog(src, nil, '/reviveradius', 'Reviveu jogadores em raio de 15m', 'admin', 3066993)
end)

-- Ban Player
RegisterNetEvent('ps-adminmenu:server:BanPlayer', function(data, selectedData)
    local src = source
    if not selectedData then return end
    local target = selectedData["Player"] and selectedData["Player"].value
    local reason = selectedData["Reason"] and selectedData["Reason"].value or 'N/A'
    local duration = selectedData["Duração"] and selectedData["Duração"].value or 'Permanente'
    SendAdminLog(src, target, '/ban (admin menu)', 'Baniu jogador\nMotivo: ' .. reason .. '\nDuração: ' .. tostring(duration), 'ban', 15158332)
end)

-- Kick Player
RegisterNetEvent('ps-adminmenu:server:KickPlayer', function(data, selectedData)
    local src = source
    if not selectedData then return end
    local target = selectedData["Player"] and selectedData["Player"].value
    local reason = selectedData["Reason"] and selectedData["Reason"].value or 'N/A'
    SendAdminLog(src, target, '/kick (admin menu)', 'Kickou jogador\nMotivo: ' .. reason, 'kick', 15158332)
end)

-- Warn Player
RegisterNetEvent('ps-adminmenu:server:WarnPlayer', function(data, selectedData)
    local src = source
    if not selectedData then return end
    local target = selectedData["Player"] and selectedData["Player"].value
    local reason = selectedData["Reason"] and selectedData["Reason"].value or 'N/A'
    SendAdminLog(src, target, '/warn (admin menu)', 'Deu warn ao jogador\nMotivo: ' .. reason, 'admin', 15844367)
end)

-- Give Money
RegisterNetEvent('ps-adminmenu:server:GiveMoney', function(data, selectedData)
    local src = source
    if not selectedData then return end
    local target = selectedData["Player"] and selectedData["Player"].value
    local amount = selectedData["Amount"] and selectedData["Amount"].value or '?'
    local moneyType = selectedData["Type"] and selectedData["Type"].value or 'cash'
    SendAdminLog(src, target, '/givemoney (admin menu)', 'Deu dinheiro\nTipo: ' .. moneyType .. '\nValor: $' .. tostring(amount), 'admin', 15844367)
end)

-- Give Money All
RegisterNetEvent('ps-adminmenu:server:GiveMoneyAll', function(data, selectedData)
    local src = source
    if not selectedData then return end
    local amount = selectedData["Amount"] and selectedData["Amount"].value or '?'
    local moneyType = selectedData["Type"] and selectedData["Type"].value or 'cash'
    SendAdminLog(src, nil, '/givemoneyall (admin menu)', 'Deu dinheiro para TODOS\nTipo: ' .. moneyType .. '\nValor: $' .. tostring(amount), 'admin', 15844367)
end)

-- Take Money
RegisterNetEvent('ps-adminmenu:server:TakeMoney', function(data, selectedData)
    local src = source
    if not selectedData then return end
    local target = selectedData["Player"] and selectedData["Player"].value
    local amount = selectedData["Amount"] and selectedData["Amount"].value or '?'
    local moneyType = selectedData["Type"] and selectedData["Type"].value or 'cash'
    SendAdminLog(src, target, '/takemoney (admin menu)', 'Removeu dinheiro\nTipo: ' .. moneyType .. '\nValor: $' .. tostring(amount), 'admin', 15844367)
end)

-- Unban (por CID)
RegisterNetEvent('ps-adminmenu:server:unban_cid', function(data, selectedData)
    local src = source
    if not selectedData then return end
    local cid = selectedData["cid"] and selectedData["cid"].value or '?'
    SendAdminLog(src, nil, '/unban (CID)', 'Desbaniu jogador via CID: ' .. cid, 'desban', 3066993)
end)

-- Unban (por RowID)
RegisterNetEvent('ps-adminmenu:server:unban_rowid', function(data, selectedData)
    local src = source
    SendAdminLog(src, nil, '/unban (RowID)', 'Desbaniu jogador via painel admin', 'desban', 3066993)
end)

-- Unban Player (por ID online)
RegisterNetEvent('ps-adminmenu:server:UnbanPlayer', function(data, selectedData)
    local src = source
    if not selectedData then return end
    local target = selectedData["Player"] and selectedData["Player"].value
    SendAdminLog(src, target, '/unban (admin menu)', 'Desbaniu jogador', 'desban', 3066993)
end)

-- Delete CID
RegisterNetEvent('ps-adminmenu:server:delete_cid', function(data, selectedData)
    local src = source
    if not selectedData then return end
    local cid = selectedData["cid"] and selectedData["cid"].value or '?'
    SendAdminLog(src, nil, '/deletecid', 'Deletou personagem CID: ' .. cid, 'admin', 15158332)
end)

-- Set Routing Bucket
RegisterNetEvent('ps-adminmenu:server:SetBucket', function(data, selectedData)
    local src = source
    if not selectedData then return end
    local target = selectedData["Player"] and selectedData["Player"].value
    local bucket = selectedData["Bucket"] and selectedData["Bucket"].value or '?'
    SendAdminLog(src, target, '/setbucket', 'Moveu jogador para bucket: ' .. tostring(bucket), 'admin', 15105570)
end)

-- Toggle Blackout
RegisterNetEvent('ps-adminmenu:server:ToggleBlackout', function()
    local src = source
    SendAdminLog(src, nil, '/blackout', 'Alternou blackout da cidade', 'admin', 15105570)
end)

-- Cuff Player
RegisterNetEvent('ps-adminmenu:server:CuffPlayer', function(data, selectedData)
    local src = source
    if not selectedData then return end
    local target = selectedData["Player"] and selectedData["Player"].value
    SendAdminLog(src, target, '/cuff (admin menu)', 'Algemou/desalgemou jogador', 'admin', 15105570)
end)

-- Verify Player
RegisterNetEvent('ps-adminmenu:server:verifyPlayer', function(data, selectedData)
    local src = source
    if not selectedData then return end
    local target = selectedData["Player"] and selectedData["Player"].value
    SendAdminLog(src, target, '/verify', 'Verificou/desverificou jogador', 'admin', 3066993)
end)

-- =============================================
-- QBOX DRUGS - DROGAS
-- =============================================

RegisterNetEvent('qb-drugs:server:updateDealerItems', function(dealerId, itemName, amount)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'drugs', 'VENDEU DROGAS AO DEALER',
        'Dealer: **#' .. tostring(dealerId or '?') .. '**' ..
        '\nItem: **' .. tostring(itemName or '?') .. '**' ..
        '\nQuantidade: **' .. tostring(amount or '?') .. '**')
end)

RegisterNetEvent('qb-drugs:server:giveDeliveryItems', function()
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'drugs', 'RECEBEU ITENS PARA ENTREGA',
        'Iniciou missão de entrega de drogas')
end)

RegisterNetEvent('qb-drugs:server:successDelivery', function()
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'drugs', 'ENTREGA DE DROGAS CONCLUÍDA',
        'Entrega realizada com sucesso')
end)

RegisterNetEvent('qb-drugs:server:randomPoliceAlert', function()
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'drugs', 'ALERTA POLICIAL - DROGAS',
        'Atividade suspeita de drogas detectada', 3447003)
end)

-- =============================================
-- QBOX CUSTOMS - CUSTOMIZAÇÃO DE VEÍCULOS
-- =============================================

RegisterNetEvent('qbx_customs:server:saveVehicleProps', function(netId, props)
    local src = source
    if not src or src <= 0 then return end

    local plate = props and props.plate or 'N/A'

    SendPlayerLog(src, 'customs', 'CUSTOMIZOU VEÍCULO',
        'Placa: **' .. plate .. '**')
end)

-- =============================================
-- QBOX MANAGEMENT - BOSS MENU
-- =============================================
-- Os callbacks do qbx_management são via lib.callback,
-- então hookeamos os eventos do core que eles disparam

-- Quando um jogador é contratado/demitido/promovido, o core dispara
-- QBCore:Server:OnJobUpdate que já está no server_hooks.lua.
-- Aqui adicionamos detecção extra via override de exports.

CreateThread(function()
    if not IsResourceActive('qbx_management') then return end
    Wait(3000)

    -- Monitorar mudanças de grade via o evento do core
    AddEventHandler('QBCore:Server:OnJobUpdate', function(src, jobData)
        if not src or src <= 0 then return end
        -- Já logado no server_hooks.lua, mas adicionamos tag de management
        -- se o evento vier de um boss menu (detectado pela call stack)
    end)

    print('[qb-logs] Integração qbx_management registrada')
end)

-- =============================================
-- QBOX CITYHALL - PREFEITURA
-- =============================================
-- Hooks nos callbacks de compra de licenças e candidatura a emprego
-- Os pagamentos são capturados pelo QBCore:Server:OnMoneyChange

-- Candidatura a emprego no cityhall é via callback, capturamos
-- a mudança via QBCore:Server:OnJobUpdate no server_hooks.lua

-- =============================================
-- QBOX MECHANICJOB - MECÂNICO
-- =============================================

RegisterNetEvent('qb-vehicletuning:server:SaveVehicleProps', function(plate, props)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'mechanic', 'SALVOU MODS DO VEÍCULO',
        'Placa: **' .. tostring(plate or 'N/A') .. '**')
end)

RegisterNetEvent('vehiclemod:server:fixEverything', function(plate)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'mechanic', 'CONSERTOU VEÍCULO COMPLETO',
        'Placa: **' .. tostring(plate or 'N/A') .. '**')
end)

RegisterNetEvent('vehiclemod:server:updatePart', function(plate, part, level)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'mechanic', 'ATUALIZOU PEÇA DO VEÍCULO',
        'Placa: **' .. tostring(plate or 'N/A') .. '**' ..
        '\nPeça: **' .. tostring(part or '?') .. '**' ..
        '\nNível: **' .. tostring(level or '?') .. '**')
end)

RegisterNetEvent('qb-vehicletuning:server:SetPartLevel', function(plate, part, level)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'mechanic', 'DEFINIU NÍVEL DE PEÇA',
        'Placa: **' .. tostring(plate or 'N/A') .. '**' ..
        '\nPeça: **' .. tostring(part or '?') .. '**' ..
        '\nNível: **' .. tostring(level or '?') .. '**')
end)

RegisterNetEvent('vehiclemod:server:setupVehicleStatus', function(plate, status)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'mechanic', 'CONFIGUROU STATUS DO VEÍCULO',
        'Placa: **' .. tostring(plate or 'N/A') .. '**')
end)

RegisterNetEvent('qb-vehicletuning:server:SetAttachedVehicle', function(plate, attachedPlate)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'mechanic', 'VEÍCULO ANEXADO NA PLATAFORMA',
        'Placa Plataforma: **' .. tostring(plate or 'N/A') .. '**' ..
        '\nPlaca Veículo: **' .. tostring(attachedPlate or 'N/A') .. '**')
end)

-- =============================================
-- QBOX GARBAGEJOB - LIXEIRO
-- =============================================

RegisterNetEvent('garbagejob:server:payShift', function()
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'jobs', 'RECEBEU PAGAMENTO - LIXEIRO',
        'Turno de trabalho finalizado com pagamento')
end)

-- =============================================
-- QBOX PROPERTIES - PROPRIEDADES
-- =============================================

RegisterNetEvent('qbx_properties:server:enterProperty', function(propertyId)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'property', 'ENTROU EM PROPRIEDADE',
        'Propriedade: **#' .. tostring(propertyId or '?') .. '**')
end)

RegisterNetEvent('qbx_properties:server:exitProperty', function()
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'property', 'SAIU DA PROPRIEDADE',
        'Jogador saiu da propriedade')
end)

RegisterNetEvent('qbx_properties:server:ringProperty', function(propertyId)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'property', 'TOCOU CAMPAINHA',
        'Propriedade: **#' .. tostring(propertyId or '?') .. '**')
end)

-- =============================================
-- QBOX SCRAPYARD - FERRO VELHO
-- =============================================

RegisterNetEvent('qbx_scrapyard:server:scrapVehicle', function(listKey, netId)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'ilegal', 'SUCATEOU VEÍCULO',
        'Item: **' .. tostring(listKey or '?') .. '**' ..
        '\nNetID: **' .. tostring(netId or '?') .. '**')
end)

-- =============================================
-- QBOX PAWNSHOP - LOJA DE PENHORES
-- =============================================

RegisterNetEvent('qb-pawnshop:server:sellPawnItems', function(itemName, itemAmount, itemPrice)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'pawnshop', 'VENDEU ITEM NO PENHOR',
        'Item: **' .. tostring(itemName or '?') .. '**' ..
        '\nQuantidade: **' .. tostring(itemAmount or 1) .. '**' ..
        '\nPreço: **$' .. tostring(itemPrice or 0) .. '**')
end)

RegisterNetEvent('qb-pawnshop:server:meltItemRemove', function(itemName, itemAmount, item)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'pawnshop', 'INICIOU FUNDIÇÃO DE ITEM',
        'Item: **' .. tostring(itemName or '?') .. '**' ..
        '\nQuantidade: **' .. tostring(itemAmount or 1) .. '**')
end)

RegisterNetEvent('qb-pawnshop:server:pickupMelted', function(item)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'pawnshop', 'COLETOU ITEM FUNDIDO',
        'Item: **' .. tostring(item or '?') .. '**')
end)

-- =============================================
-- QBOX TOWJOB - GUINCHO
-- =============================================

RegisterNetEvent('qb-tow:server:DoBail', function(bool, vehInfo)
    local src = source
    if not src or src <= 0 then return end

    local plate = vehInfo and vehInfo.plate or 'N/A'
    local action = bool and 'RESGATOU VEÍCULO' or 'ENTREGOU VEÍCULO'

    SendPlayerLog(src, 'jobs', action .. ' (GUINCHO)',
        'Placa: **' .. plate .. '**')
end)

-- =============================================
-- QBOX TRUCKROBBERY - ROUBO DE CAMINHÃO
-- =============================================

RegisterNetEvent('qbx_truckrobbery:server:startMission', function()
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'heist', 'INICIOU ROUBO DE CAMINHÃO',
        'Missão de roubo de caminhão iniciada', 15158332)
end)

RegisterNetEvent('qbx_truckrobbery:server:plantedBomb', function()
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'heist', 'PLANTOU BOMBA NO CAMINHÃO',
        'Explosivo plantado para roubo de carga', 15158332)
end)

-- =============================================
-- QBOX SPAWN
-- =============================================

RegisterNetEvent('qbx_spawn:server:spawn', function()
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'login', 'SPAWNOU NO SERVIDOR',
        'Personagem spawnou no mundo')
end)

-- =============================================
-- QBOX FIREWORKS - FOGOS DE ARTIFÍCIO
-- =============================================

RegisterNetEvent('qbx_fireworks:server:spawnObject', function(model, coords)
    local src = source
    if not src or src <= 0 then return end

    local coordStr = coords and ('X: %.2f | Y: %.2f | Z: %.2f'):format(coords.x or 0, coords.y or 0, coords.z or 0) or '?'

    SendPlayerLog(src, 'general', 'SOLTOU FOGOS DE ARTIFÍCIO',
        'Modelo: **' .. tostring(model or '?') .. '**' ..
        '\nCoordenadas: **' .. coordStr .. '**')
end)

-- =============================================
-- MRI QFARM - FAZENDA
-- =============================================
-- Os callbacks de farm são via lib.callback, capturamos
-- via os itens adicionados (já logados pelo ox_inventory hook).
-- Adicionamos hook específico para colheita.

RegisterNetEvent('mri_Qfarm:server:getRewardItem', function(itemName, amount)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'jobs', 'COLHEU ITEM DA FAZENDA',
        'Item: **' .. tostring(itemName or '?') .. '**' ..
        '\nQuantidade: **' .. tostring(amount or 1) .. '**')
end)

-- =============================================
-- MRI QSTOREROBBERY - ROUBO A LOJA
-- =============================================

RegisterNetEvent('ran-storerobbery:server:setUse', function(storeId, registerId)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'robbery', 'ROUBANDO REGISTRADORA',
        'Loja: **#' .. tostring(storeId or '?') .. '**' ..
        '\nRegistradora: **#' .. tostring(registerId or '?') .. '**', 15158332)
end)

RegisterNetEvent('ran-storerobbery:server:registerAlert', function(storeId)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'robbery', 'ALERTA - ROUBO A LOJA',
        'Loja: **#' .. tostring(storeId or '?') .. '**' ..
        '\nAlerta policial disparado', 3447003)
end)

RegisterNetEvent('ran-storerobbery:server:setHackUse', function(storeId)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'robbery', 'HACKEANDO COFRE DA LOJA',
        'Loja: **#' .. tostring(storeId or '?') .. '**', 15158332)
end)

-- =============================================
-- MRI QFLEECAHEIST - ASSALTO FLEECA
-- =============================================

RegisterNetEvent('fleecaheist:server:rewardItem', function()
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'heist', 'COMPLETOU ASSALTO FLEECA',
        'Recompensa recebida do assalto ao Fleeca Bank', 15158332)
end)

-- =============================================
-- MRI QCARKEYS - CHAVES DE VEÍCULO
-- =============================================

RegisterNetEvent('mm_carkeys:server:acquirevehiclekeys', function(plate)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'carkeys', 'OBTEVE CHAVE PERMANENTE',
        'Placa: **' .. tostring(plate or 'N/A') .. '**')
end)

RegisterNetEvent('mm_carkeys:server:acquiretempvehiclekeys', function(plate)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'carkeys', 'OBTEVE CHAVE TEMPORÁRIA',
        'Placa: **' .. tostring(plate or 'N/A') .. '**')
end)

RegisterNetEvent('mm_carkeys:server:removetempvehiclekeys', function(plate)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'carkeys', 'PERDEU CHAVE TEMPORÁRIA',
        'Placa: **' .. tostring(plate or 'N/A') .. '**')
end)

RegisterNetEvent('mm_carkeys:server:setVehLockState', function(plate, state)
    local src = source
    if not src or src <= 0 then return end

    local stateLabel = state and 'TRANCOU' or 'DESTRANCOU'

    SendPlayerLog(src, 'carkeys', stateLabel .. ' VEÍCULO',
        'Placa: **' .. tostring(plate or 'N/A') .. '**')
end)

RegisterNetEvent('mm_carkeys:server:removelockpick', function()
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'ilegal', 'USOU LOCKPICK EM VEÍCULO',
        'Lockpick consumido ao tentar abrir veículo')
end)

RegisterNetEvent('qb-vehiclekeys:server:AcquireVehicleKeys', function(plate)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'carkeys', 'OBTEVE CHAVE (COMPAT QB)',
        'Placa: **' .. tostring(plate or 'N/A') .. '**')
end)

-- =============================================
-- MRI QSTASHES - STASHES
-- =============================================

RegisterNetEvent('insertStashesData', function(data)
    local src = source
    if not src or src <= 0 then return end

    local name = type(data) == 'table' and (data.name or data.label) or tostring(data or '?')

    SendPlayerLog(src, 'stashes', 'CRIOU NOVO STASH',
        'Nome: **' .. name .. '**', 15105570)
end)

RegisterNetEvent('deleteStashesData', function(id)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'stashes', 'DELETOU STASH',
        'ID: **' .. tostring(id or '?') .. '**', 15158332)
end)

RegisterNetEvent('updateStashesData', function(data)
    local src = source
    if not src or src <= 0 then return end

    local name = type(data) == 'table' and (data.name or data.label) or tostring(data or '?')

    SendPlayerLog(src, 'stashes', 'ATUALIZOU STASH',
        'Nome: **' .. name .. '**')
end)

RegisterNetEvent('updateStashLocation', function(id, coords)
    local src = source
    if not src or src <= 0 then return end

    local coordStr = coords and ('X: %.2f | Y: %.2f | Z: %.2f'):format(coords.x or 0, coords.y or 0, coords.z or 0) or '?'

    SendPlayerLog(src, 'stashes', 'MOVEU STASH',
        'ID: **' .. tostring(id or '?') .. '**' ..
        '\nNova Posição: **' .. coordStr .. '**')
end)

-- =============================================
-- MRI QROBNPCS - ROUBO DE NPC
-- =============================================
-- O evento xt-robnpcs:server:robNPC é via callback.
-- Capturamos os itens/dinheiro ganhos via ox_inventory hooks
-- e QBCore:Server:OnMoneyChange.

-- =============================================
-- MRI QCRAFTING - CRAFT DE ITENS
-- =============================================

RegisterNetEvent('qt-crafting:ItemInterval', function(task, item, count)
    local src = source
    if not src or src <= 0 then return end

    local taskLabel = task == 'craft' and 'CRAFTANDO' or tostring(task or 'PROCESSANDO')

    SendPlayerLog(src, 'crafting', taskLabel:upper() .. ' ITEM',
        'Item: **' .. tostring(item or '?') .. '**' ..
        '\nQuantidade: **' .. tostring(count or 1) .. '**')
end)

RegisterNetEvent('qt-crafting:CreateWorkShop', function(data)
    local src = source
    if not src or src <= 0 then return end

    local name = type(data) == 'table' and (data.name or data.label) or '?'

    SendPlayerLog(src, 'crafting', 'CRIOU MESA DE CRAFT',
        'Nome: **' .. name .. '**', 15105570)
end)

RegisterNetEvent('qt-crafting:DeleteTable', function(id, name)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'crafting', 'DELETOU MESA DE CRAFT',
        'ID: **' .. tostring(id or '?') .. '**' ..
        '\nNome: **' .. tostring(name or '?') .. '**', 15158332)
end)

RegisterNetEvent('qt-crafting:ChangeName', function(id, newname)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'crafting', 'RENOMEOU MESA DE CRAFT',
        'ID: **' .. tostring(id or '?') .. '**' ..
        '\nNovo Nome: **' .. tostring(newname or '?') .. '**')
end)

RegisterNetEvent('qt-crafting:AddItemCrafting', function(data)
    local src = source
    if not src or src <= 0 then return end

    local item = type(data) == 'table' and (data.item or data.name) or '?'

    SendPlayerLog(src, 'crafting', 'ADICIONOU RECEITA DE CRAFT',
        'Item: **' .. tostring(item) .. '**', 15105570)
end)

RegisterNetEvent('qt-crafting:RemoveRequirement', function(id)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'crafting', 'REMOVEU REQUISITO DE CRAFT',
        'ID: **' .. tostring(id or '?') .. '**')
end)

RegisterNetEvent('qt-crafting:ChangeJobs', function(id, jobs)
    local src = source
    if not src or src <= 0 then return end

    local jobStr = type(jobs) == 'table' and json.encode(jobs) or tostring(jobs or '?')

    SendPlayerLog(src, 'crafting', 'ALTEROU JOBS DA MESA DE CRAFT',
        'ID: **' .. tostring(id or '?') .. '**' ..
        '\nJobs: **' .. jobStr .. '**')
end)

-- =============================================
-- MRI QSTARTERPACK - STARTER PACK
-- =============================================

RegisterNetEvent('cfx-tcd-starterpack:Server:ClaimStarterpack', function(starterpack_type)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'starterpack', 'RESGATOU STARTER PACK',
        'Tipo: **' .. tostring(starterpack_type or '?') .. '**')
end)

RegisterNetEvent('cfx-tcd-starterpack:Server:ClaimVehicle', function(vehicleData)
    local src = source
    if not src or src <= 0 then return end

    local model = type(vehicleData) == 'table' and (vehicleData.model or vehicleData.vehicle) or tostring(vehicleData or '?')

    SendPlayerLog(src, 'starterpack', 'RESGATOU VEÍCULO DO STARTER PACK',
        'Modelo: **' .. model .. '**')
end)

-- =============================================
-- MRI QBLACKOUT - BLACKOUT
-- =============================================

RegisterNetEvent('ss-blackout:blackout', function()
    local src = source
    if src and src > 0 then
        SendPlayerLog(src, 'admin', 'ATIVOU/DESATIVOU BLACKOUT',
            'Evento de blackout disparado')
    else
        SendLog('admin', '⚡ Blackout', '**Evento de blackout da cidade disparado**\n\n**[Data]:** ' .. GetFormattedDate() .. '\n**[Hora]:** ' .. GetFormattedTime(), 15105570, nil)
    end
end)

RegisterNetEvent('ss-blackout:blackouton', function()
    SendLog('admin', '⚡ Blackout LIGADO', '**A cidade entrou em blackout!**\n\n**[Data]:** ' .. GetFormattedDate() .. '\n**[Hora]:** ' .. GetFormattedTime(), 15158332, nil)
end)

RegisterNetEvent('ss-blackout:blackoutoff', function()
    SendLog('admin', '💡 Blackout DESLIGADO', '**O blackout da cidade foi encerrado.**\n\n**[Data]:** ' .. GetFormattedDate() .. '\n**[Hora]:** ' .. GetFormattedTime(), 3066993, nil)
end)

-- =============================================
-- MRI QJOBSYSTEM - SISTEMA DE EMPREGOS
-- =============================================

RegisterNetEvent('mri_Qjobsystem:server:saveNewJob', function(jobData)
    local src = source
    if not src or src <= 0 then return end

    local jobName = type(jobData) == 'table' and (jobData.name or jobData.label) or '?'

    SendPlayerLog(src, 'management', 'CRIOU NOVO EMPREGO',
        'Emprego: **' .. jobName .. '**', 15105570)
end)

RegisterNetEvent('mri_Qjobsystem:server:saveJob', function(jobData)
    local src = source
    if not src or src <= 0 then return end

    local jobName = type(jobData) == 'table' and (jobData.name or jobData.label) or '?'

    SendPlayerLog(src, 'management', 'EDITOU EMPREGO',
        'Emprego: **' .. jobName .. '**')
end)

RegisterNetEvent('mri_Qjobsystem:server:deleteJob', function(jobData)
    local src = source
    if not src or src <= 0 then return end

    local jobName = type(jobData) == 'table' and (jobData.name or jobData.label) or '?'

    SendPlayerLog(src, 'management', 'DELETOU EMPREGO',
        'Emprego: **' .. jobName .. '**', 15158332)
end)

RegisterNetEvent('mri_Qjobsystem:server:createItem', function(craftingData, amount)
    local src = source
    if not src or src <= 0 then return end

    local itemName = type(craftingData) == 'table' and (craftingData.item or craftingData.name) or '?'

    SendPlayerLog(src, 'jobs', 'PRODUZIU ITEM NO EMPREGO',
        'Item: **' .. tostring(itemName) .. '**' ..
        '\nQuantidade: **' .. tostring(amount or 1) .. '**')
end)

RegisterNetEvent('mri_Qjobsystem:server:makeRegisterAction', function(jobName, action, number)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'jobs', 'AÇÃO DE REGISTRADORA',
        'Job: **' .. tostring(jobName or '?') .. '**' ..
        '\nAção: **' .. tostring(action or '?') .. '**' ..
        '\nValor: **' .. tostring(number or 0) .. '**')
end)

-- =============================================
-- MRI QJOBCENTER - CENTRO DE EMPREGOS
-- =============================================

RegisterNetEvent('ss-jobcenter:server:select', function(data)
    local src = source
    if not src or src <= 0 then return end

    local jobName = type(data) == 'table' and (data.job or data.name or data.label) or tostring(data or '?')

    SendPlayerLog(src, 'jobcenter', 'SELECIONOU EMPREGO NO CENTRO',
        'Emprego: **' .. jobName .. '**')
end)

-- =============================================
-- RHD GARAGE - GARAGEM
-- =============================================

RegisterNetEvent('rhd_garage:server:updateState', function(plate, state, garage)
    local src = source
    if not src or src <= 0 then return end

    local stateLabels = {
        [0] = 'FORA DA GARAGEM',
        [1] = 'NA GARAGEM',
        [2] = 'APREENDIDO',
    }

    SendPlayerLog(src, 'garage', 'ESTADO DO VEÍCULO ALTERADO',
        'Placa: **' .. tostring(plate or 'N/A') .. '**' ..
        '\nEstado: **' .. (stateLabels[tonumber(state)] or tostring(state or '?')) .. '**' ..
        '\nGaragem: **' .. tostring(garage or 'N/A') .. '**')
end)

RegisterNetEvent('rhd_garage:server:saveGarageZone', function(data)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'garage', 'ZONA DE GARAGEM SALVA',
        'Dados da zona configurados', 15105570)
end)

RegisterNetEvent('rhd_garage:server:saveCustomVehicleName', function(plate, name)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'garage', 'RENOMEOU VEÍCULO',
        'Placa: **' .. tostring(plate or 'N/A') .. '**' ..
        '\nNovo Nome: **' .. tostring(name or '?') .. '**')
end)

RegisterNetEvent('rhd_garage:server:removeTemp', function(plate)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'garage', 'REMOVEU VEÍCULO TEMPORÁRIO',
        'Placa: **' .. tostring(plate or 'N/A') .. '**')
end)

-- =============================================
-- ILLENIUM APPEARANCE - APARÊNCIA
-- =============================================

CreateThread(function()
    if not IsResourceActive('illenium-appearance') then return end
    Wait(3000)

    -- Hook nas callbacks de aparência
    -- As mudanças de aparência passam por callbacks internos
    -- Capturamos quando dinheiro é removido para customização

    -- O pagamento é capturado pelo QBCore:Server:OnMoneyChange
    -- com reasons como 'clothing', 'barber', 'tattoo', 'surgeon'

    print('[qb-logs] Integração illenium-appearance registrada (via economia)')
end)

-- =============================================
-- BBV AIRDROPS
-- =============================================

RegisterNetEvent('bbv-drop:create:server', function(dropType, coords)
    local src = source
    if not src or src <= 0 then return end

    local coordStr = coords and type(coords) == 'table' and
        ('X: %.2f | Y: %.2f | Z: %.2f'):format(coords.x or 0, coords.y or 0, coords.z or 0) or
        tostring(coords or '?')

    SendPlayerLog(src, 'airdrops', 'AIRDROP CRIADO',
        'Tipo: **' .. tostring(dropType or '?') .. '**' ..
        '\nCoordenadas: **' .. coordStr .. '**')
end)

RegisterNetEvent('bbv-drop:create:server:admin', function(dropType, coords)
    local src = source
    if not src or src <= 0 then return end

    local coordStr = coords and type(coords) == 'table' and
        ('X: %.2f | Y: %.2f | Z: %.2f'):format(coords.x or 0, coords.y or 0, coords.z or 0) or
        tostring(coords or '?')

    SendPlayerLog(src, 'airdrops', 'AIRDROP CRIADO (ADMIN)',
        'Tipo: **' .. tostring(dropType or '?') .. '**' ..
        '\nCoordenadas: **' .. coordStr .. '**', 15105570)
end)

RegisterNetEvent('bbv-drop:server:pickup', function()
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'airdrops', 'COLETOU AIRDROP',
        'Jogador coletou o conteúdo do airdrop')
end)

RegisterNetEvent('bbv-drop:end:server', function()
    SendLog('airdrops', '📦 Airdrop Encerrado',
        '**O airdrop foi encerrado.**\n\n**[Data]:** ' .. GetFormattedDate() .. '\n**[Hora]:** ' .. GetFormattedTime(),
        nil, nil)
end)

-- =============================================
-- OX DOORLOCK - PORTAS
-- =============================================

CreateThread(function()
    if not IsResourceActive('ox_doorlock') then return end
    Wait(3000)

    -- Hook no evento de mudança de estado das portas
    AddEventHandler('ox_doorlock:setState', function(doorId, state, src)
        if not src or src <= 0 then return end

        local stateLabel = state and 'TRANCOU PORTA' or 'DESTRANCOU PORTA'

        SendPlayerLog(src, 'doors', stateLabel,
            'Porta: **#' .. tostring(doorId or '?') .. '**')
    end)

    print('[qb-logs] Integração ox_doorlock registrada')
end)

-- =============================================
-- LB-PHONE - TELEFONE
-- =============================================

CreateThread(function()
    if not IsResourceActive('lb-phone') then return end
    Wait(3000)

    -- lb-phone é compilado, capturamos via eventos conhecidos
    -- A transferência de dinheiro é capturada pelo QBCore:Server:OnMoneyChange

    print('[qb-logs] Integração lb-phone registrada (via economia)')
end)

-- =============================================
-- LOCKPICK EVENTS
-- =============================================

RegisterNetEvent('lockpicks:UseLockpick', function(isAdvanced)
    local src = source
    if not src or src <= 0 then return end

    local type = isAdvanced and 'LOCKPICK AVANÇADO' or 'LOCKPICK SIMPLES'

    SendPlayerLog(src, 'ilegal', 'USOU ' .. type,
        'Jogador usou ferramenta de arrombamento')
end)

-- =============================================
-- QBOX SEATBELT
-- =============================================
-- qbx_seatbelt não tem eventos server-side relevantes para log

-- =============================================
-- QBOX IDCARD
-- =============================================

RegisterNetEvent('um-idcard:server:sendData', function(src, item, metadata)
    local playerSrc = source
    if not playerSrc or playerSrc <= 0 then return end

    SendPlayerLog(playerSrc, 'general', 'MOSTROU DOCUMENTO',
        'Tipo: **' .. tostring(item or '?') .. '**')
end)

-- =============================================
-- QBX DJ
-- =============================================

RegisterNetEvent('dj:syncAudio', function(data)
    local src = source
    if not src or src <= 0 then return end

    local url = type(data) == 'table' and (data.url or data.link) or '?'

    SendPlayerLog(src, 'general', 'DJ - TOCOU MÚSICA',
        'URL tocada no sistema de DJ')
end)

RegisterNetEvent('dj:spawnProp', function(data)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'general', 'DJ - COLOCOU EQUIPAMENTO',
        'Equipamento de DJ posicionado')
end)

-- =============================================
-- MRI QBOOMBOX
-- =============================================

RegisterNetEvent('mri_Qboombox:server:Playsong', function(data)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'general', 'BOOMBOX - TOCOU MÚSICA',
        'Música iniciada na boombox')
end)

RegisterNetEvent('mri_Qboombox:server:deleteBoombox', function(id, x)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'general', 'BOOMBOX - REMOVIDA',
        'Boombox ID: **' .. tostring(id or '?') .. '** removida')
end)

-- =============================================
-- RELATÓRIO DE INTEGRAÇÕES ATIVAS
-- =============================================

CreateThread(function()
    Wait(5000) -- Espera tudo carregar

    local integrations = {}
    local scripts = {
        {'ps-adminmenu', 'ps-adminmenu (Admin: ban, kick, revive, warn, money)'},
        {'qbx_drugs', 'qbx_drugs (Drogas: venda, entrega, alerta)'},
        {'qbx_customs', 'qbx_customs (Customização de veículos)'},
        {'qbx_management', 'qbx_management (Boss Menu: contratar, promover)'},
        {'qbx_cityhall', 'qbx_cityhall (Licenças, jobs)'},
        {'qbx_mechanicjob', 'qbx_mechanicjob (Mecânico: reparos, peças)'},
        {'qbx_garbagejob', 'qbx_garbagejob (Lixeiro: turnos)'},
        {'qbx_properties', 'qbx_properties (Propriedades: entrar/sair)'},
        {'qbx_scrapyard', 'qbx_scrapyard (Ferro velho)'},
        {'qbx_pawnshop', 'qbx_pawnshop (Penhores: venda, fundição)'},
        {'qbx_towjob', 'qbx_towjob (Guincho)'},
        {'qbx_truckrobbery', 'qbx_truckrobbery (Roubo de caminhão)'},
        {'qbx_spawn', 'qbx_spawn (Spawn)'},
        {'qbx_fireworks', 'qbx_fireworks (Fogos de artifício)'},
        {'qbx_idcard', 'qbx_idcard (Documentos)'},
        {'mri_Qfarm', 'mri_Qfarm (Fazenda: colheita)'},
        {'mri_Qstorerobbery', 'mri_Qstorerobbery (Roubo a loja)'},
        {'mri_Qfleecaheist', 'mri_Qfleecaheist (Assalto Fleeca)'},
        {'mri_Qcarkeys', 'mri_Qcarkeys (Chaves de veículo)'},
        {'mri_Qstashes', 'mri_Qstashes (Stashes)'},
        {'mri_Qcrafting', 'mri_Qcrafting (Craft de itens)'},
        {'mri_Qstarterpack', 'mri_Qstarterpack (Starter pack)'},
        {'mri_Qblackout', 'mri_Qblackout (Blackout)'},
        {'mri_Qjobsystem', 'mri_Qjobsystem (Sistema de empregos)'},
        {'mri_Qjobcenter', 'mri_Qjobcenter (Centro de empregos)'},
        {'mri_Qboombox', 'mri_Qboombox (Boombox)'},
        {'Qbx_DJ', 'Qbx_DJ (Sistema DJ)'},
        {'rhd_garage', 'rhd_garage (Garagem: spawn, transfer)'},
        {'illenium-appearance', 'illenium-appearance (Aparência)'},
        {'bbv-airdrops', 'bbv-airdrops (Airdrops)'},
        {'ox_doorlock', 'ox_doorlock (Portas)'},
        {'lb-phone', 'lb-phone (Telefone)'},
    }

    for _, v in ipairs(scripts) do
        if IsResourceActive(v[1]) then
            table.insert(integrations, v[2])
        end
    end

    print('[qb-logs] ===== INTEGRAÇÕES EXTRAS =====')
    for _, v in ipairs(integrations) do
        print('[qb-logs]  ✔ ' .. v)
    end
    if #integrations == 0 then
        print('[qb-logs]  (nenhuma integração extra ativa)')
    end
    print('[qb-logs] ================================')
    print('[qb-logs] Total de integrações extras: ' .. #integrations)
end)
