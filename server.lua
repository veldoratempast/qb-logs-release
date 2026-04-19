--[[
    =============================================
    SERVIDOR DE LOGS - QB-LOGS
    =============================================
    Handlers de eventos e integração com QBCore/QBOX.
    Todos os eventos importantes são capturados aqui.
]]

-- =============================================
-- CONEXÃO E DESCONEXÃO
-- =============================================

-- Jogador conectando
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local src = source
    local identifiers = GetPlayerIdentifiers(src)
    local steamHex = GetSteamHex(src)
    local discordId = GetDiscordId(src)
    local ip = GetPlayerIP(src)
    local license = GetLicense(src)

    local msg = ''
    msg = msg .. '**[ID]:** ' .. src .. '\n'
    msg = msg .. '**[Nome]:** ' .. name .. '\n'
    msg = msg .. '**[License]:** ' .. license .. '\n'

    if Config.ShowSteam then
        msg = msg .. '**[Steam]:** ' .. steamHex .. '\n'
    end
    if Config.ShowDiscord then
        msg = msg .. '**[Discord]:** ' .. discordId .. '\n'
    end
    if Config.ShowIP then
        msg = msg .. '**[IP]:** ' .. ip .. '\n'
    end

    msg = msg .. '========================\n'
    msg = msg .. '**AÇÃO:** CONECTANDO AO SERVIDOR\n'
    msg = msg .. '\n**[Data]:** ' .. GetFormattedDate()
    msg = msg .. '\n**[Hora]:** ' .. GetFormattedTime()

    SendLog('login', '🟢 Jogador Conectando', msg, nil, nil)
end)

-- Jogador carregou (QBCore/QBOX)
RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local src = source
    SendPlayerLog(src, 'login', 'ENTROU NO SERVIDOR', 'Personagem carregado com sucesso')
end)

-- Jogador desconectou
AddEventHandler('playerDropped', function(reason)
    local src = source
    local name = GetPlayerName(src) or 'Desconhecido'
    local char = GetCharacterData(src)

    local msg = ''
    msg = msg .. '**[ID]:** ' .. src .. '\n'
    msg = msg .. '**[Nome]:** ' .. char.name .. '\n'
    msg = msg .. '**[CitizenID]:** ' .. char.citizenid .. '\n'

    if Config.ShowSteam then
        msg = msg .. '**[Steam]:** ' .. GetSteamHex(src) .. '\n'
    end
    if Config.ShowDiscord then
        msg = msg .. '**[Discord]:** ' .. GetDiscordId(src) .. '\n'
    end
    if Config.ShowIP then
        msg = msg .. '**[IP]:** ' .. GetPlayerIP(src) .. '\n'
    end

    msg = msg .. '========================\n'
    msg = msg .. '**AÇÃO:** SAIU DO SERVIDOR\n'
    msg = msg .. '**MOTIVO:** ' .. (reason or 'Desconhecido') .. '\n'
    msg = msg .. '\n**[Data]:** ' .. GetFormattedDate()
    msg = msg .. '\n**[Hora]:** ' .. GetFormattedTime()

    SendLog('disconnect', '🔴 Jogador Desconectou', msg, nil, nil)
end)

-- Jogador descarregando (QBCore/QBOX)
RegisterNetEvent('QBCore:Server:OnPlayerUnload', function()
    local src = source
    SendPlayerLog(src, 'disconnect', 'PERSONAGEM DESCARREGADO', 'Dados do personagem salvos')
end)

-- =============================================
-- MORTES
-- =============================================

-- Tabela de hashes de armas comuns para nomes legíveis
local WeaponNames = {
    -- Corpo a corpo
    [`WEAPON_UNARMED`]       = 'Mãos',
    [`WEAPON_KNIFE`]         = 'Faca',
    [`WEAPON_NIGHTSTICK`]    = 'Cassetete',
    [`WEAPON_HAMMER`]        = 'Martelo',
    [`WEAPON_BAT`]           = 'Taco de Baseball',
    [`WEAPON_CROWBAR`]       = 'Pé de Cabra',
    [`WEAPON_GOLFCLUB`]      = 'Taco de Golf',
    [`WEAPON_BOTTLE`]        = 'Garrafa',
    [`WEAPON_DAGGER`]        = 'Adaga',
    [`WEAPON_HATCHET`]       = 'Machadinha',
    [`WEAPON_KNUCKLE`]       = 'Soco Inglês',
    [`WEAPON_MACHETE`]       = 'Facão',
    [`WEAPON_SWITCHBLADE`]   = 'Canivete',
    [`WEAPON_WRENCH`]        = 'Chave Inglesa',
    [`WEAPON_BATTLEAXE`]     = 'Machado de Batalha',
    [`WEAPON_POOLCUE`]       = 'Taco de Sinuca',
    [`WEAPON_STONE_HATCHET`] = 'Machadinha de Pedra',
    -- Pistolas
    [`WEAPON_PISTOL`]        = 'Pistola',
    [`WEAPON_PISTOL_MK2`]    = 'Pistola MK2',
    [`WEAPON_COMBATPISTOL`]  = 'Pistola de Combate',
    [`WEAPON_APPISTOL`]      = 'Pistola AP',
    [`WEAPON_PISTOL50`]      = 'Pistola .50',
    [`WEAPON_SNSPISTOL`]     = 'Pistola SNS',
    [`WEAPON_SNSPISTOL_MK2`] = 'Pistola SNS MK2',
    [`WEAPON_HEAVYPISTOL`]   = 'Pistola Pesada',
    [`WEAPON_VINTAGEPISTOL`] = 'Pistola Vintage',
    [`WEAPON_MARKSMANPISTOL`]= 'Pistola Marksman',
    [`WEAPON_REVOLVER`]      = 'Revólver',
    [`WEAPON_REVOLVER_MK2`]  = 'Revólver MK2',
    [`WEAPON_DOUBLEACTION`]  = 'Revólver Dupla Ação',
    [`WEAPON_CERAMICPISTOL`] = 'Pistola Cerâmica',
    [`WEAPON_NAVYREVOLVER`]  = 'Revólver Navy',
    [`WEAPON_GADGETPISTOL`]  = 'Pistola Perico',
    -- SMGs
    [`WEAPON_MICROSMG`]      = 'Micro SMG',
    [`WEAPON_SMG`]           = 'SMG',
    [`WEAPON_SMG_MK2`]       = 'SMG MK2',
    [`WEAPON_ASSAULTSMG`]    = 'SMG de Assalto',
    [`WEAPON_COMBATPDW`]     = 'PDW de Combate',
    [`WEAPON_MACHINEPISTOL`] = 'Pistola Automática',
    [`WEAPON_MINISMG`]       = 'Mini SMG',
    -- Espingardas
    [`WEAPON_PUMPSHOTGUN`]   = 'Escopeta Pump',
    [`WEAPON_PUMPSHOTGUN_MK2`]= 'Escopeta Pump MK2',
    [`WEAPON_SAWNOFFSHOTGUN`]= 'Escopeta Serrada',
    [`WEAPON_ASSAULTSHOTGUN`]= 'Escopeta de Assalto',
    [`WEAPON_BULLPUPSHOTGUN`]= 'Escopeta Bullpup',
    [`WEAPON_MUSKET`]        = 'Mosquete',
    [`WEAPON_HEAVYSHOTGUN`]  = 'Escopeta Pesada',
    [`WEAPON_DBSHOTGUN`]     = 'Escopeta Dupla',
    [`WEAPON_AUTOSHOTGUN`]   = 'Escopeta Automática',
    [`WEAPON_COMBATSHOTGUN`] = 'Escopeta de Combate',
    -- Rifles
    [`WEAPON_ASSAULTRIFLE`]  = 'Fuzil de Assalto',
    [`WEAPON_ASSAULTRIFLE_MK2`]= 'Fuzil de Assalto MK2',
    [`WEAPON_CARBINERIFLE`]  = 'Carabina',
    [`WEAPON_CARBINERIFLE_MK2`]= 'Carabina MK2',
    [`WEAPON_ADVANCEDRIFLE`] = 'Fuzil Avançado',
    [`WEAPON_SPECIALCARBINE`]= 'Carabina Especial',
    [`WEAPON_SPECIALCARBINE_MK2`]= 'Carabina Especial MK2',
    [`WEAPON_BULLPUPRIFLE`]  = 'Fuzil Bullpup',
    [`WEAPON_BULLPUPRIFLE_MK2`]= 'Fuzil Bullpup MK2',
    [`WEAPON_COMPACTRIFLE`]  = 'Fuzil Compacto',
    [`WEAPON_MILITARYRIFLE`] = 'Fuzil Militar',
    [`WEAPON_HEAVYRIFLE`]    = 'Fuzil Pesado',
    [`WEAPON_TACTICALRIFLE`] = 'Fuzil Tático',
    -- Metralhadoras
    [`WEAPON_MG`]            = 'Metralhadora',
    [`WEAPON_COMBATMG`]      = 'Metralhadora de Combate',
    [`WEAPON_COMBATMG_MK2`]  = 'Metralhadora de Combate MK2',
    [`WEAPON_GUSENBERG`]     = 'Metralhadora Gusenberg',
    -- Snipers
    [`WEAPON_SNIPERRIFLE`]   = 'Sniper',
    [`WEAPON_HEAVYSNIPER`]   = 'Sniper Pesado',
    [`WEAPON_HEAVYSNIPER_MK2`]= 'Sniper Pesado MK2',
    [`WEAPON_MARKSMANRIFLE`] = 'Fuzil Marksman',
    [`WEAPON_MARKSMANRIFLE_MK2`]= 'Fuzil Marksman MK2',
    [`WEAPON_PRECISIONRIFLE`]= 'Fuzil de Precisão',
    -- Lançadores
    [`WEAPON_RPG`]           = 'RPG',
    [`WEAPON_GRENADELAUNCHER`]= 'Lança-Granadas',
    [`WEAPON_MINIGUN`]       = 'Minigun',
    [`WEAPON_FIREWORK`]      = 'Lança-Fogos',
    [`WEAPON_RAILGUN`]       = 'Railgun',
    [`WEAPON_HOMINGLAUNCHER`]= 'Lança-Mísseis',
    [`WEAPON_COMPACTLAUNCHER`]= 'Lança-Granadas Compacto',
    -- Explosivos / Outros
    [`WEAPON_GRENADE`]       = 'Granada',
    [`WEAPON_BZGAS`]         = 'Gás Lacrimogêneo',
    [`WEAPON_MOLOTOV`]       = 'Molotov',
    [`WEAPON_STICKYBOMB`]    = 'Bomba Adesiva',
    [`WEAPON_PROXMINE`]      = 'Mina Proximidade',
    [`WEAPON_PIPEBOMB`]      = 'Bomba Caseira',
    [`WEAPON_SMOKEGRENADE`]  = 'Granada de Fumaça',
    [`WEAPON_PETROLCAN`]     = 'Galão de Gasolina',
    [`WEAPON_FIREEXTINGUISHER`]= 'Extintor',
    [`WEAPON_STUNGUN`]       = 'Taser',
    [`WEAPON_FLAREGUN`]      = 'Pistola Sinalizadora',
    -- Veículos / Ambiente
    [`WEAPON_RUN_OVER_BY_CAR`] = 'Atropelamento',
    [`WEAPON_RAMMED_BY_CAR`]   = 'Atropelamento',
    [`WEAPON_FALL`]            = 'Queda',
    [`WEAPON_DROWNING`]        = 'Afogamento',
    [`WEAPON_DROWNING_IN_VEHICLE`] = 'Afogamento (Veículo)',
    [`WEAPON_BLEEDING`]        = 'Sangramento',
    [`WEAPON_ELECTRIC_FENCE`]  = 'Cerca Elétrica',
    [`WEAPON_EXPLOSION`]       = 'Explosão',
    [`WEAPON_FIRE`]            = 'Fogo',
    [`WEAPON_HIT_BY_WATER_CANNON`] = 'Canhão de Água',
    [`WEAPON_EXHAUSTION`]      = 'Exaustão',
    [`WEAPON_VEHICLE_ROCKET`]  = 'Míssil de Veículo',
}

-- Resolve hash de arma para nome legível
local function GetWeaponName(weaponHash)
    if not weaponHash then return 'Desconhecida' end
    local hash = tonumber(weaponHash)
    if not hash then return tostring(weaponHash) end
    return WeaponNames[hash] or ('Hash: ' .. hash)
end

-- Jogador morreu (sem assassino - queda, afogamento, NPC, etc.)
RegisterNetEvent('baseevents:onPlayerDied', function(killerType, deathCoords)
    local src = source
    local coords = ResolveCoords(deathCoords, src)

    -- killerType pode ser um hash de arma ou ID de tipo
    local causa = GetWeaponName(killerType)
    if causa == ('Hash: ' .. tostring(killerType)) then
        causa = 'Tipo: ' .. tostring(killerType)
    end

    SendPlayerLog(src, 'kill', 'MORREU', 'Causa: **' .. causa .. '**\nCoordenadas: ' .. coords)
end)

-- Jogador foi morto por outro jogador (PvP)
RegisterNetEvent('baseevents:onPlayerKilled', function(killerId, deathData)
    local src = source
    local killerSrc = tonumber(killerId)

    -- Resolver coordenadas (baseevents: killerpos = coords da VÍTIMA, nome confuso)
    local coords = 'Desconhecido'
    if deathData and type(deathData) == 'table' then
        coords = ResolveCoords(deathData.killerpos, src)
    end
    if coords == 'Desconhecido' then
        coords = ResolveCoords(nil, src)
    end

    -- Resolver arma (campo correto do baseevents: weaponhash)
    local weaponHash = deathData and (deathData.weaponhash or deathData.killedByWeapon or deathData.killerweapon)
    local weapon = GetWeaponName(weaponHash)

    -- Info extra do veículo do assassino
    local extraInfo = ''
    if deathData and deathData.killerinveh then
        extraInfo = '\n**Veículo do Assassino:** ' .. (deathData.killervehname or 'Desconhecido')
    end

    -- Montar bloco da vítima
    local msg = '**--- VÍTIMA ---**\n'
    msg = msg .. BuildPlayerBlock(src) .. '\n\n'

    -- Montar bloco do assassino
    msg = msg .. '**--- ASSASSINO ---**\n'
    if killerSrc and killerSrc > 0 and GetPlayerName(killerSrc) then
        msg = msg .. BuildPlayerBlock(killerSrc) .. '\n\n'
    else
        -- Assassino não é um jogador válido (NPC, veículo, ou não resolvido)
        msg = msg .. '**[ID]:** ' .. tostring(killerId or '?') .. '\n'
        msg = msg .. '**[Info]:** Não é um jogador (NPC ou não identificado)\n\n'
    end

    msg = msg .. '========================\n'
    msg = msg .. '**AÇÃO:** JOGADOR MORTO POR OUTRO JOGADOR\n'
    msg = msg .. '**Arma:** ' .. weapon .. '\n'
    msg = msg .. '**Coordenadas:** ' .. coords .. '\n'
    msg = msg .. extraInfo
    msg = msg .. '\n**[Data]:** ' .. GetFormattedDate()
    msg = msg .. '\n**[Hora]:** ' .. GetFormattedTime()

    SendLog('pvp', '💀 PvP Kill', msg, nil, nil)
end)

-- =============================================
-- ECONOMIA / DINHEIRO (via trigger manual)
-- =============================================
-- NOTA: Mudanças automáticas de dinheiro são capturadas
-- por server_hooks.lua via QBCore:Server:OnMoneyChange.
-- Os eventos abaixo são para uso manual por outros scripts.

-- =============================================
-- INVENTÁRIO (via trigger manual)
-- =============================================
-- NOTA: Ações de inventário são capturadas automaticamente
-- por server_hooks.lua via hooks do ox_inventory.
-- Os eventos abaixo são para uso manual por outros scripts
-- que não usam ox_inventory.

RegisterNetEvent('qb-logs:server:itemAdd', function(source, item, amount, slot)
    local src = source
    SendPlayerLog(src, 'inventory', 'ITEM ADICIONADO (Manual)',
        'Item: ' .. (item or 'Desconhecido') ..
        '\nQuantidade: ' .. (amount or 1) ..
        '\nSlot: ' .. (slot or '?'))
end)

RegisterNetEvent('qb-logs:server:itemRemove', function(source, item, amount, slot)
    local src = source
    SendPlayerLog(src, 'inventory', 'ITEM REMOVIDO (Manual)',
        'Item: ' .. (item or 'Desconhecido') ..
        '\nQuantidade: ' .. (amount or 1) ..
        '\nSlot: ' .. (slot or '?'))
end)

-- =============================================
-- VEÍCULOS
-- =============================================

-- Veículo spawnado
RegisterNetEvent('qb-logs:server:vehicleSpawn', function(source, model, plate)
    local src = source
    SendPlayerLog(src, 'vehicles', 'VEÍCULO SPAWNADO',
        'Modelo: ' .. (model or 'Desconhecido') ..
        '\nPlaca: ' .. (plate or 'N/A'))
end)

-- Veículo deletado
RegisterNetEvent('qb-logs:server:vehicleDelete', function(source, model, plate, reason)
    local src = source
    SendPlayerLog(src, 'vehicles', 'VEÍCULO DELETADO',
        'Modelo: ' .. (model or 'Desconhecido') ..
        '\nPlaca: ' .. (plate or 'N/A') ..
        '\nMotivo: ' .. (reason or 'Não especificado'))
end)

-- Veículo guardado na garagem
RegisterNetEvent('qb-logs:server:vehicleGarage', function(source, model, plate, garage, action)
    local src = source
    local actionLabel = action == 'store' and 'GUARDOU VEÍCULO' or 'RETIROU VEÍCULO'
    SendPlayerLog(src, 'vehicles', actionLabel,
        'Modelo: ' .. (model or 'Desconhecido') ..
        '\nPlaca: ' .. (plate or 'N/A') ..
        '\nGaragem: ' .. (garage or 'N/A'))
end)

-- =============================================
-- POLÍCIA
-- =============================================

-- Jogador preso
RegisterNetEvent('qb-logs:server:arrest', function(source, targetId, reason, time)
    local src = source
    local msg = '**--- POLICIAL ---**\n'
    msg = msg .. BuildPlayerBlock(src) .. '\n\n'
    msg = msg .. '**--- PRESO ---**\n'
    msg = msg .. BuildPlayerBlock(targetId) .. '\n\n'
    msg = msg .. '========================\n'
    msg = msg .. '**AÇÃO:** PRENDEU JOGADOR\n'
    msg = msg .. '**Motivo:** ' .. (reason or 'Não especificado') .. '\n'
    msg = msg .. '**Tempo:** ' .. (time or '?') .. ' meses\n'
    msg = msg .. '\n**[Data]:** ' .. GetFormattedDate()
    msg = msg .. '\n**[Hora]:** ' .. GetFormattedTime()

    SendLog('police', '🚔 Prisão', msg, nil, nil)
end)

-- Multa aplicada
RegisterNetEvent('qb-logs:server:fine', function(source, targetId, amount, reason)
    local src = source
    local msg = '**--- POLICIAL ---**\n'
    msg = msg .. BuildPlayerBlock(src) .. '\n\n'
    msg = msg .. '**--- MULTADO ---**\n'
    msg = msg .. BuildPlayerBlock(targetId) .. '\n\n'
    msg = msg .. '========================\n'
    msg = msg .. '**AÇÃO:** MULTA APLICADA\n'
    msg = msg .. '**Valor:** $' .. (amount or 0) .. '\n'
    msg = msg .. '**Motivo:** ' .. (reason or 'Não especificado') .. '\n'
    msg = msg .. '\n**[Data]:** ' .. GetFormattedDate()
    msg = msg .. '\n**[Hora]:** ' .. GetFormattedTime()

    SendLog('multar', '🔔 Multa', msg, nil, nil)
end)

-- =============================================
-- PRISÃO
-- =============================================

-- Entrou na prisão
RegisterNetEvent('qb-logs:server:prison', function(source, time, reason)
    local src = source
    SendPlayerLog(src, 'prisao', 'ENTROU NA PRISÃO',
        'Tempo: ' .. (time or '?') .. ' meses\nMotivo: ' .. (reason or 'Não especificado'))
end)

-- Saiu da prisão
RegisterNetEvent('qb-logs:server:prisonRelease', function(source)
    local src = source
    SendPlayerLog(src, 'prisao', 'LIBERADO DA PRISÃO', 'Cumpriu a pena')
end)

-- =============================================
-- ADMINISTRAÇÃO
-- =============================================

-- Comando admin genérico
RegisterNetEvent('qb-logs:server:admin', function(source, action, details)
    local src = source
    SendAdminLog(src, nil, action or '?', details or 'Sem detalhes', 'admin', 15105570)
end)

-- Kick de admin
RegisterNetEvent('qb-logs:server:adminKick', function(source, targetId, reason)
    local src = source
    SendAdminLog(src, targetId, '/kick', 'Kickou jogador\nMotivo: ' .. (reason or 'Não especificado'), 'kick', 15158332)
end)

-- Ban de admin
RegisterNetEvent('qb-logs:server:adminBan', function(source, targetId, reason, duration)
    local src = source
    SendAdminLog(src, targetId, '/ban', 'Baniu jogador\nMotivo: ' .. (reason or 'Não especificado') .. '\nDuração: ' .. (duration or 'Permanente'), 'ban', 15158332)
end)

-- Revive de admin
RegisterNetEvent('qb-logs:server:adminRevive', function(source, targetId)
    local src = source
    SendAdminLog(src, targetId, '/revive', 'Reviveu o jogador', 'admin', 3066993)
end)

-- Fix de admin
RegisterNetEvent('qb-logs:server:adminFix', function(source, targetId)
    local src = source
    SendAdminLog(src, targetId, '/fix', 'Reparou veículo do jogador', 'fix', 3066993)
end)

-- Give item de admin
RegisterNetEvent('qb-logs:server:adminGiveItem', function(source, targetId, item, amount)
    local src = source
    SendAdminLog(src, targetId, '/giveitem', 'Deu item ao jogador\nItem: ' .. (item or '?') .. '\nQuantidade: ' .. (amount or 1), 'admin', 15105570)
end)

-- =============================================
-- ANTI-CHEAT
-- =============================================

-- Detecção suspeita
RegisterNetEvent('qb-logs:server:anticheatSuspect', function(source, reason, details)
    local src = source
    SendPlayerLog(src, 'suspeito', '⚠️ SUSPEITA DE CHEAT',
        'Motivo: ' .. (reason or 'Desconhecido') .. '\nDetalhes: ' .. (details or ''), 15844367)
end)

-- Ban por anti-cheat
RegisterNetEvent('qb-logs:server:anticheatBan', function(source, reason)
    local src = source
    SendPlayerLog(src, 'ban', '🔨 BAN POR ANTI-CHEAT',
        'Motivo: ' .. (reason or 'Detecção automática'), 15158332)
end)

-- Kick por anti-cheat
RegisterNetEvent('qb-logs:server:anticheatKick', function(source, reason)
    local src = source
    SendPlayerLog(src, 'kick', '⛔ KICK POR ANTI-CHEAT',
        'Motivo: ' .. (reason or 'Detecção automática'), 15158332)
end)

-- =============================================
-- AÇÕES ILEGAIS
-- =============================================

-- Ação ilegal genérica
RegisterNetEvent('qb-logs:server:illegal', function(source, action, details)
    local src = source
    SendPlayerLog(src, 'ilegal', 'AÇÃO ILEGAL: ' .. (action or '?'),
        details or 'Sem detalhes')
end)

-- =============================================
-- ROUBOS
-- =============================================

-- Roubo genérico
RegisterNetEvent('qb-logs:server:robbery', function(source, robberyType, details, reward)
    local src = source
    SendPlayerLog(src, 'robbery', 'ROUBO: ' .. (robberyType or 'Desconhecido'),
        'Detalhes: ' .. (details or 'Sem detalhes') ..
        '\nRecompensa: ' .. (reward or 'N/A'))
end)

-- =============================================
-- LOG GERAL (para uso em qualquer script)
-- =============================================

-- Evento genérico que outros scripts podem triggerar
RegisterNetEvent('qb-logs:server:log', function(logType, title, message, color)
    local src = source
    if src and src > 0 then
        local playerBlock = BuildPlayerBlock(src)
        message = playerBlock .. '\n========================\n' .. message
    end
    SendLog(logType or 'general', title or 'Log', message or '', color, src)
end)

-- Evento para log sem identificação de jogador (sistema)
RegisterNetEvent('qb-logs:server:systemLog', function(logType, title, message, color)
    SendLog(logType or 'general', title or 'Sistema', message or '', color, nil)
end)

-- =============================================
-- MENSAGEM DE INICIALIZAÇÃO
-- =============================================

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() ~= resource then return end

    -- Contar canais configurados
    local configured = 0
    local total = 0
    for k, v in pairs(Config.Channels) do
        total = total + 1
        if v and v ~= '' then
            configured = configured + 1
        end
    end

    print('========================================')
    print('[qb-logs] Sistema de Logs iniciado!')
    print('[qb-logs] Canais configurados: ' .. configured .. '/' .. total)
    print('[qb-logs] Anti-spam: ' .. Config.Cooldown .. 'ms')
    print('[qb-logs] Servidor: ' .. Config.ServerName)
    print('========================================')

    -- Enviar log de teste se webhook geral estiver configurada
    if IsLogEnabled('general') then
        SendLog('general', '🚀 Sistema Iniciado', '**O sistema de logs foi iniciado com sucesso!**\n\nCanais configurados: ' .. configured .. '/' .. total .. '\nData: ' .. GetFormattedDate() .. '\nHora: ' .. GetFormattedTime(), 3066993, nil)
    end
end)
