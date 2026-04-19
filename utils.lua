--[[
    =============================================
    FUNÇÕES AUXILIARES - QB-LOGS
    =============================================
    Funções reutilizáveis para coleta de dados
    e envio de webhooks ao Discord.
]]

-- =============================================
-- DETECÇÃO AUTOMÁTICA DE FRAMEWORK
-- =============================================
local QBCore = nil
local isQbox = false

CreateThread(function()
    if GetResourceState('qbx_core') == 'started' then
        isQbox = true
        -- qbx_core bridge registra GetCoreObject sob o nome 'qb-core', NÃO 'qbx_core'
        QBCore = exports['qb-core']:GetCoreObject()
        print('[qb-logs] Framework detectado: QBOX (via bridge qb-core)')
    elseif GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
        print('[qb-logs] Framework detectado: QBCore')
    end

    if not QBCore then
        print('[qb-logs] AVISO: Nenhum framework QBCore/QBOX detectado. Algumas funções terão dados limitados.')
    end
end)

-- Retorna o objeto do framework
function GetFramework()
    return QBCore
end

-- Retorna true se é QBOX
function IsQbox()
    return isQbox
end

-- =============================================
-- COLETA DE IDENTIFICADORES DO JOGADOR
-- =============================================

-- Retorna o Steam Hex do jogador
function GetSteamHex(source)
    local src = tonumber(source)
    if not src or src <= 0 then return 'Desconhecido' end
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if string.find(id, 'steam:') then
            return id
        end
    end
    return 'Não encontrado'
end

-- Retorna o Discord ID do jogador (formato mencionável)
function GetDiscordId(source)
    local src = tonumber(source)
    if not src or src <= 0 then return 'Desconhecido' end
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if string.find(id, 'discord:') then
            local discordId = string.gsub(id, 'discord:', '')
            return '<@' .. discordId .. '>'
        end
    end
    return 'Não vinculado'
end

-- Retorna o Discord ID puro (sem formatação)
function GetDiscordIdRaw(source)
    local src = tonumber(source)
    if not src or src <= 0 then return nil end
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if string.find(id, 'discord:') then
            return string.gsub(id, 'discord:', '')
        end
    end
    return nil
end

-- Retorna o License do jogador
function GetLicense(source)
    local src = tonumber(source)
    if not src or src <= 0 then return 'Desconhecido' end
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if string.find(id, 'license:') and not string.find(id, 'license2:') then
            return id
        end
    end
    return 'Não encontrado'
end

-- Retorna o IP do jogador (mascarado parcialmente para segurança)
function GetPlayerIP(source)
    local src = tonumber(source)
    if not src or src <= 0 then return 'Desconhecido' end
    local ep = GetPlayerEndpoint(src)
    if not ep then return 'Desconhecido' end
    -- Remove a porta
    local ip = string.match(ep, '(.+):%d+$') or ep
    return ip
end

-- =============================================
-- DADOS DO PERSONAGEM (QBCore/QBOX)
-- =============================================

-- Retorna dados completos do personagem
function GetCharacterData(source)
    local data = {
        name = 'Desconhecido',
        citizenid = 'N/A',
        job = 'Desempregado',
        jobGrade = 0,
    }

    local src = tonumber(source)
    if not src or src <= 0 then return data end

    local Player = nil

    -- 1. Tentar via framework compat layer
    local fw = GetFramework()
    if fw and fw.Functions and fw.Functions.GetPlayer then
        Player = fw.Functions.GetPlayer(src)
    end

    -- 2. Fallback: export direto do qbx_core (caso o compat layer não funcionou)
    if not Player and GetResourceState('qbx_core') == 'started' then
        local ok, result = pcall(exports['qbx_core'].GetPlayer, exports['qbx_core'], src)
        if ok and result then
            Player = result
        end
    end

    -- 3. Fallback: export direto do qb-core
    if not Player and GetResourceState('qb-core') == 'started' then
        local ok, result = pcall(exports['qb-core'].GetPlayer, exports['qb-core'], src)
        if ok and result then
            Player = result
        end
    end

    if not Player then
        data.name = GetPlayerName(src) or 'Desconhecido'
        return data
    end

    -- Extrair dados do personagem
    local pd = Player.PlayerData
    if not pd then
        data.name = GetPlayerName(src) or 'Desconhecido'
        return data
    end

    local charinfo = pd.charinfo
    if charinfo then
        local first = charinfo.firstname or ''
        local last = charinfo.lastname or ''
        if first ~= '' or last ~= '' then
            data.name = first .. ' ' .. last
        else
            data.name = GetPlayerName(src) or 'Desconhecido'
        end
    else
        data.name = GetPlayerName(src) or 'Desconhecido'
    end

    data.citizenid = pd.citizenid or 'N/A'

    local jobData = pd.job
    if jobData then
        data.job = (jobData.label or jobData.name or 'Desempregado')
        data.jobGrade = jobData.grade and jobData.grade.level or 0
    end

    return data
end

-- =============================================
-- DATA E HORA
-- =============================================

-- Retorna data formatada (DD/MM/AAAA)
function GetFormattedDate()
    return os.date('%d/%m/%Y')
end

-- Retorna hora formatada (HH:MM:SS)
function GetFormattedTime()
    return os.date('%H:%M:%S')
end

-- Retorna timestamp ISO 8601 para embed do Discord
function GetISO8601()
    return os.date('!%Y-%m-%dT%H:%M:%SZ')
end

-- =============================================
-- RESOLUÇÃO DE COORDENADAS (MULTI-FORMATO)
-- =============================================
-- Aceita vector3, tabela {x,y,z}, tabela {[1],[2],[3]} ou source como fallback

function ResolveCoords(coordsData, fallbackSource)
    if coordsData then
        -- vector3 ou tabela com .x/.y/.z
        if type(coordsData) == 'vector3' or (type(coordsData) == 'table' and coordsData.x) then
            return ('X: %.2f | Y: %.2f | Z: %.2f'):format(coordsData.x, coordsData.y, coordsData.z)
        end
        -- Índices numéricos (formato do baseevents: {table.unpack(vector3)})
        if type(coordsData) == 'table' and coordsData[1] then
            return ('X: %.2f | Y: %.2f | Z: %.2f'):format(coordsData[1], coordsData[2] or 0, coordsData[3] or 0)
        end
    end
    -- Fallback: pegar do ped no server
    if fallbackSource then
        local src = tonumber(fallbackSource)
        if src and src > 0 then
            local ped = GetPlayerPed(src)
            if ped and ped > 0 then
                local pos = GetEntityCoords(ped)
                if pos then
                    return ('X: %.2f | Y: %.2f | Z: %.2f'):format(pos.x, pos.y, pos.z)
                end
            end
        end
    end
    return 'Desconhecido'
end

-- =============================================
-- MONTAGEM DO BLOCO DE IDENTIFICAÇÃO
-- =============================================

-- Monta o bloco padrão de identificação do jogador
function BuildPlayerBlock(source)
    local src = tonumber(source)
    local char = GetCharacterData(src)
    local lines = {}

    table.insert(lines, '**[ID]:** ' .. (src or '?'))
    table.insert(lines, '**[Nome]:** ' .. char.name)
    table.insert(lines, '**[CitizenID]:** ' .. char.citizenid)
    table.insert(lines, '**[Job]:** ' .. char.job .. ' (Grade ' .. char.jobGrade .. ')')

    if Config.ShowSteam then
        table.insert(lines, '**[Steam]:** ' .. GetSteamHex(src))
    end
    if Config.ShowDiscord then
        table.insert(lines, '**[Discord]:** ' .. GetDiscordId(src))
    end
    if Config.ShowIP then
        table.insert(lines, '**[IP]:** ' .. GetPlayerIP(src))
    end

    return table.concat(lines, '\n')
end

-- =============================================
-- SISTEMA ANTI-SPAM (COOLDOWN)
-- =============================================

local cooldowns = {}

-- Verifica se o jogador pode enviar log desta categoria
-- Retorna true se permitido, false se em cooldown
function CheckCooldown(source, logType)
    local key = tostring(source) .. ':' .. logType
    local now = GetGameTimer()
    if cooldowns[key] and (now - cooldowns[key]) < Config.Cooldown then
        return false
    end
    cooldowns[key] = now
    return true
end

-- Limpa cooldowns antigos periodicamente (evita vazamento de memória)
CreateThread(function()
    while true do
        Wait(300000) -- A cada 5 minutos
        local now = GetGameTimer()
        for key, time in pairs(cooldowns) do
            if (now - time) > 60000 then -- Remove entradas com mais de 1 minuto
                cooldowns[key] = nil
            end
        end
    end
end)

-- =============================================
-- CACHE E LOOKUP DE WEBHOOKS
-- =============================================

local webhookCache = {}

-- Obtém webhook URL pelo nome do canal Discord
-- @param channelName string - Nome do canal (ex: '💀-kill')
-- @return string|nil - URL do webhook ou nil
function GetWebhookByChannelName(channelName)
    if webhookCache[channelName] then
        return webhookCache[channelName]
    end

    local url = Config.Channels[channelName]
    if url and url ~= '' then
        webhookCache[channelName] = url
        return url
    end

    return nil
end

-- Verifica se um tipo de log está ativo (tem canal + webhook configurados)
-- @param logType string - Tipo de log (ex: 'kill', 'money')
-- @return boolean
function IsLogEnabled(logType)
    local channelName = Config.Logs[logType]
    if not channelName then return false end
    return GetWebhookByChannelName(channelName) ~= nil
end

-- Resolve tipo de log → URL do webhook
-- @param logType string
-- @return string|nil
local function ResolveWebhook(logType)
    -- 1. Buscar canal no mapeamento Config.Logs
    local channelName = Config.Logs[logType]
    if channelName then
        return GetWebhookByChannelName(channelName)
    end

    -- 2. Fallback: tentar como nome de canal direto
    return GetWebhookByChannelName(logType)
end

-- =============================================
-- ENVIO DE WEBHOOK
-- =============================================

-- Função principal de envio ao Discord
-- @param logType string   - Tipo de log (deve existir em Config.Logs)
-- @param title   string   - Título do embed
-- @param message string   - Corpo da mensagem
-- @param color   number   - Cor do embed (opcional, usa Config.Colors se nil)
-- @param source  number   - ID do jogador (opcional, para anti-spam)
function SendLog(logType, title, message, color, source)
    -- Resolver webhook via Config.Logs → Config.Channels
    local webhook = ResolveWebhook(logType)
    if not webhook then
        return -- Canal não configurado ou webhook vazia
    end

    -- Anti-spam
    if source and not CheckCooldown(source, logType) then
        return
    end

    -- Cor do embed
    local embedColor = color or Config.Colors[logType] or 9807270

    -- Log no console se ativado
    if Config.ConsoleLog then
        print(('[qb-logs][%s] %s: %s'):format(logType, title, message))
    end

    -- Montar embed
    local embed = {
        {
            title = title,
            description = message,
            color = embedColor,
            footer = {
                text = Config.ServerName .. ' • ' .. GetFormattedDate() .. ' ' .. GetFormattedTime(),
                icon_url = Config.BotAvatar,
            },
            timestamp = GetISO8601(),
        }
    }

    local payload = json.encode({
        username = Config.BotName,
        avatar_url = Config.BotAvatar,
        embeds = embed,
    })

    -- Enviar HTTP POST
    PerformHttpRequest(webhook, function(statusCode, response, headers)
        -- Rate limit do Discord: aguardar e retentar
        if statusCode == 429 then
            local retryAfter = 2000
            if response then
                local decoded = json.decode(response)
                if decoded and decoded.retry_after then
                    retryAfter = math.ceil(decoded.retry_after * 1000)
                end
            end
            SetTimeout(retryAfter, function()
                SendLog(logType, title, message, color, nil) -- Retenta sem anti-spam
            end)
        end
    end, 'POST', payload, {['Content-Type'] = 'application/json'})
end

-- =============================================
-- FUNÇÃO COMPLETA: LOG COM IDENTIFICAÇÃO
-- =============================================

-- Envia log com bloco de identificação do jogador automaticamente
-- @param source  number - ID do jogador
-- @param logType string - Categoria do log
-- @param action  string - Descrição da ação
-- @param details string - Detalhes extras (opcional)
-- @param color   number - Cor customizada (opcional)
function SendPlayerLog(source, logType, action, details, color)
    local playerBlock = BuildPlayerBlock(source)
    local msg = playerBlock .. '\n========================\n'
    msg = msg .. '**AÇÃO:** ' .. action .. '\n'
    if details and details ~= '' then
        msg = msg .. '**DETALHES:** ' .. details .. '\n'
    end
    msg = msg .. '\n**[Data]:** ' .. GetFormattedDate()
    msg = msg .. '\n**[Hora]:** ' .. GetFormattedTime()

    SendLog(logType, '📋 ' .. action, msg, color, source)
end

-- =============================================
-- INFORMAÇÕES RESUMIDAS DO JOGADOR (SAFE)
-- =============================================

-- Retorna tabela com info do jogador (seguro contra nil)
-- @param source number - ID do jogador
-- @return table { id, name, citizenid, job, steam, discord, ip, license }
function GetPlayerInfo(source)
    local src = tonumber(source)
    local info = {
        id = src or '?',
        name = 'Desconhecido',
        citizenid = 'N/A',
        job = 'Desempregado',
        jobGrade = 0,
        steam = 'N/A',
        discord = 'N/A',
        ip = 'N/A',
        license = 'N/A',
    }

    if not src or src <= 0 then return info end

    local char = GetCharacterData(src)
    info.name = char.name
    info.citizenid = char.citizenid
    info.job = char.job
    info.jobGrade = char.jobGrade
    info.steam = GetSteamHex(src)
    info.discord = GetDiscordId(src)
    info.ip = GetPlayerIP(src)
    info.license = GetLicense(src)

    return info
end

-- =============================================
-- LOG ADMIN PADRONIZADO (STAFF + ALVO)
-- =============================================

-- Envia log admin com formato padronizado
-- @param staffSrc  number - ID do staff que executou
-- @param targetSrc number|nil - ID do alvo (pode ser nil)
-- @param command   string - Nome do comando/ação
-- @param result    string - Resultado da ação
-- @param logType   string - Tipo de log (ex: 'admin', 'fix', 'kick')
-- @param color     number|nil - Cor do embed
function SendAdminLog(staffSrc, targetSrc, command, result, logType, color)
    local staff = GetPlayerInfo(staffSrc)
    local msg = '**--- STAFF ---**\n'
    msg = msg .. '**[ID]:** ' .. staff.id .. '\n'
    msg = msg .. '**[Nome]:** ' .. staff.name .. '\n'
    msg = msg .. '**[CitizenID]:** ' .. staff.citizenid .. '\n'
    if Config.ShowDiscord then
        msg = msg .. '**[Discord]:** ' .. staff.discord .. '\n'
    end

    if targetSrc and tonumber(targetSrc) and tonumber(targetSrc) > 0 then
        local target = GetPlayerInfo(targetSrc)
        msg = msg .. '\n**--- ALVO ---**\n'
        msg = msg .. '**[ID]:** ' .. target.id .. '\n'
        msg = msg .. '**[Nome]:** ' .. target.name .. '\n'
        msg = msg .. '**[CitizenID]:** ' .. target.citizenid .. '\n'
        if Config.ShowDiscord then
            msg = msg .. '**[Discord]:** ' .. target.discord .. '\n'
        end
    end

    msg = msg .. '\n========================\n'
    msg = msg .. '**COMANDO:** ' .. (command or '?') .. '\n'
    msg = msg .. '**RESULTADO:** ' .. (result or 'Executado') .. '\n'
    msg = msg .. '\n**[Data]:** ' .. GetFormattedDate()
    msg = msg .. '\n**[Hora]:** ' .. GetFormattedTime()

    SendLog(logType or 'admin', '🛡️ ' .. (command or 'Admin'), msg, color, nil)
end

-- =============================================
-- EXPORTS PARA OUTROS RECURSOS
-- =============================================

-- Outros scripts podem chamar:
-- exports['qb-logs']:SendLog('economy', 'Título', 'Mensagem', 3066993)
-- exports['qb-logs']:SendPlayerLog(source, 'economy', 'Pagamento', 'R$ 5000')
-- exports['qb-logs']:SendAdminLog(staffSrc, targetSrc, '/god', 'Reviveu jogador', 'admin')
exports('SendLog', SendLog)
exports('SendPlayerLog', SendPlayerLog)
exports('SendAdminLog', SendAdminLog)
exports('GetPlayerInfo', GetPlayerInfo)
exports('BuildPlayerBlock', BuildPlayerBlock)
exports('GetCharacterData', GetCharacterData)
exports('GetWebhookByChannelName', GetWebhookByChannelName)
exports('IsLogEnabled', IsLogEnabled)
exports('GetSteamHex', GetSteamHex)
exports('GetDiscordId', GetDiscordId)
exports('GetPlayerIP', GetPlayerIP)
exports('ResolveCoords', ResolveCoords)
