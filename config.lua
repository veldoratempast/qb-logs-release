--[[
    =============================================
    CONFIGURAÇÃO DO SISTEMA DE LOGS - QB-LOGS
    =============================================

    COMO CONFIGURAR:
    1. Crie canais no seu Discord (um para cada categoria)
    2. Em cada canal, vá em Configurações > Integrações > Webhooks
    3. Crie um webhook e copie a URL
    4. Cole a URL no canal correspondente em Config.Channels
    5. Mapeie tipos de log para canais em Config.Logs

    SISTEMA:
    - Config.Channels  → URL do webhook de cada canal (uma por canal)
    - Config.Logs      → Mapeia tipo de log → nome do canal
    - Config.Colors    → Cor do embed por tipo de log

    COMO ADICIONAR NOVO CANAL:
    1. Adicione a entrada em Config.Channels com a URL do webhook
       Ex: ['📦-novo-canal'] = 'https://discord.com/api/webhooks/...',

    COMO ADICIONAR NOVO TIPO DE LOG:
    1. Adicione em Config.Logs apontando para um canal existente
       Ex: meuNovoLog = '📦-novo-canal',
    2. Adicione a cor em Config.Colors
       Ex: meuNovoLog = 3066993,
    3. Use no código: SendLog('meuNovoLog', 'Título', 'Mensagem')

    IMPORTANTE:
    - Cada canal tem UMA webhook (sem duplicatas)
    - Múltiplos tipos de log podem apontar para o MESMO canal
    - Deixe '' vazio para desativar um canal
    - Não compartilhe suas webhooks publicamente
]]

Config = {}

-- =============================================
-- NOME DO SERVIDOR (aparece no footer dos embeds)
-- =============================================
Config.ServerName = 'Meu Servidor RP'

-- =============================================
-- WEBHOOKS POR CANAL DO DISCORD
-- Uma webhook por canal. Cole a URL do webhook.
-- Use o NOME EXATO do canal (incluindo emojis).
-- Nunca crie mais de uma webhook por canal.
-- =============================================
Config.Channels = {
    -- ======= CONEXÃO =======
    ['🔑-login']              = '',
    ['🆑-cl']                 = '',
    ['🖥️-registros']          = '',
    ['📋-logs-geral']         = '',

    -- ======= ADMIN =======
    ['🛡️-admin']              = '',
    ['🔰-staff']              = '',
    ['🥾-kick']               = '',
    ['🔴-ban']                = '',
    ['🚫-ban-thunder']        = '',
    ['🟢-desban']             = '',
    ['❗-suspeito']            = '',
    ['🎥-freecam']            = '',
    ['🧱-wall']               = '',
    ['🛠️-fix']                = '',

    -- ======= ECONOMIA =======
    ['💵-money']              = '',
    ['💰-salary']             = '',
    ['💰-dinheiro']           = '',
    ['🪙-coins']              = '',
    ['💎-gemstone']           = '',
    ['🔹-gemas']              = '',

    -- ======= INVENTÁRIO =======
    ['📦-item']               = '',
    ['📦-give']               = '',
    ['📤-dropar-item']        = '',
    ['ℹ️-dropar-item']        = '',
    ['📦-bau']                = '',

    -- ======= VEÍCULOS =======
    ['🚗-addcar']             = '',
    ['🚗-remcar']             = '',
    ['🚗-car']                = '',
    ['🚗-carro']              = '',
    ['🚗-veiculo']            = '',
    ['🚗-veiculos']           = '',
    ['🚗-dv']                 = '',
    ['🏪-garage']             = '',

    -- ======= COMBATE =======
    ['⚰️-kill']               = '',
    ['💀-kill']               = '',

    -- ======= POLÍCIA =======
    ['🚔-police']             = '',
    ['💸-multar']             = '',
    ['🚨-prisao']             = '',
    ['⛓️-detido']             = '',
    ['📚-apreender']          = '',
    ['📝-ocorrências']        = '',
    ['📋-prontuario']         = '',

    -- ======= ILEGAL =======
    ['💲-roubos']             = '',
    ['💀-ilegal-geral']       = '',
    ['🔫-garmas']             = '',

    -- ======= PROPRIEDADES =======
    ['🏠-homes']              = '',
    ['🏠-baú-casas']          = '',
    ['🚓-baú-policias']       = '',
    ['🕵️-baú-facções']        = '',
    ['🚗-baú-veículos']       = '',
    ['🏥-baú-hospital']       = '',
    ['🔧-baú-mecanica']       = '',
    ['💀-baú-orgs-ilegais']   = '',

    -- ======= CELULAR =======
    ['📱-messages']           = '',
    ['📱-chamadas']           = '',
    ['📱-instapic']           = '',
    ['📱-birdy']              = '',
    ['📱-darkchat']           = '',
    ['📱-crypto']             = '',
    ['📱-uploads']            = '',

    -- ======= LOJAS =======
    ['🛒-shop']               = '',
    ['🏬-loja-em-gamer']      = '',
    ['🏬-lojacoin-em-gamer']  = '',
    ['💴-vendas-in-game']     = '',

    -- ======= DIVERSOS =======
    ['🧑‍🔧-mec']               = '',
    ['🩺-paramedico']         = '',
    ['⛽-posto-de-gas']       = '',
    ['🕒-bate-ponto']         = '',
    ['🕒-ponto-staff']        = '',
}

-- =============================================
-- MAPEAMENTO: TIPO DE LOG → CANAL DO DISCORD
-- Cada tipo de log aponta para um canal em Config.Channels.
-- Múltiplos tipos podem apontar para o mesmo canal.
-- Para adicionar: Config.Logs['novoTipo'] = '📦-item'
-- =============================================
Config.Logs = {
    -- CONEXÃO
    login           = '🔑-login',
    disconnect      = '🖥️-registros',
    registros       = '🖥️-registros',
    cl              = '🆑-cl',

    -- ADMIN
    admin           = '🛡️-admin',
    staff           = '🔰-staff',
    kick            = '🥾-kick',
    ban             = '🔴-ban',
    banthunder      = '🚫-ban-thunder',
    desban          = '🟢-desban',
    suspeito        = '❗-suspeito',
    freecam         = '🎥-freecam',
    wall            = '🧱-wall',
    fix             = '🛠️-fix',
    noclip          = '🎥-freecam',
    anticheat       = '❗-suspeito',

    -- ECONOMIA
    money           = '💵-money',
    economy         = '💵-money',
    salary          = '💰-salary',
    dinheiro        = '💰-dinheiro',
    coins           = '🪙-coins',
    gemstone        = '💎-gemstone',
    gemas           = '🔹-gemas',
    pawnshop        = '💎-gemstone',

    -- INVENTÁRIO
    item            = '📦-item',
    inventory       = '📦-item',
    give            = '📦-give',
    drop            = '📤-dropar-item',
    bau             = '📦-bau',
    stashes         = '📦-bau',
    crafting        = '📦-item',

    -- VEÍCULOS
    addcar          = '🚗-addcar',
    remcar          = '🚗-remcar',
    car             = '🚗-car',
    carro           = '🚗-carro',
    veiculo         = '🚗-veiculo',
    veiculos        = '🚗-veiculos',
    vehicles        = '🚗-car',
    dv              = '🚗-dv',
    garage          = '🏪-garage',
    carkeys         = '🚗-veiculo',
    customs         = '🚗-carro',

    -- COMBATE
    kill            = '💀-kill',
    pvp             = '⚰️-kill',

    -- POLÍCIA
    police          = '🚔-police',
    multar          = '💸-multar',
    prisao          = '🚨-prisao',
    prison          = '🚨-prisao',
    detido          = '⛓️-detido',
    apreender       = '📚-apreender',
    ocorrencias     = '📝-ocorrências',
    prontuario      = '📋-prontuario',

    -- ILEGAL
    roubos          = '💲-roubos',
    robbery         = '💲-roubos',
    heist           = '💲-roubos',
    ilegal          = '💀-ilegal-geral',
    illegal         = '💀-ilegal-geral',
    drugs           = '💀-ilegal-geral',
    garmas          = '🔫-garmas',

    -- PROPRIEDADES
    homes           = '🏠-homes',
    property        = '🏠-homes',
    doors           = '🏠-homes',
    baucasas        = '🏠-baú-casas',
    baupolicias     = '🚓-baú-policias',
    baufaccoes      = '🕵️-baú-facções',
    bauveiculos     = '🚗-baú-veículos',
    bauhospital     = '🏥-baú-hospital',
    baumecanica     = '🔧-baú-mecanica',
    bauilegais      = '💀-baú-orgs-ilegais',

    -- CELULAR
    phone           = '📱-messages',
    messages        = '📱-messages',
    chamadas        = '📱-chamadas',
    instapic        = '📱-instapic',
    birdy           = '📱-birdy',
    darkchat        = '📱-darkchat',
    crypto          = '📱-crypto',
    uploads         = '📱-uploads',

    -- LOJAS
    shop            = '🛒-shop',
    shops           = '🛒-shop',
    lojaemgamer     = '🏬-loja-em-gamer',
    lojacoin        = '🏬-lojacoin-em-gamer',
    vendasingame    = '💴-vendas-in-game',

    -- DIVERSOS
    mechanic        = '🧑‍🔧-mec',
    mec             = '🧑‍🔧-mec',
    paramedico      = '🩺-paramedico',
    postogas        = '⛽-posto-de-gas',
    bateponto       = '🕒-bate-ponto',
    pontostaff      = '🕒-ponto-staff',
    general         = '📋-logs-geral',
    appearance      = '📋-logs-geral',
    airdrops        = '📋-logs-geral',
    starterpack     = '📋-logs-geral',
    jobcenter       = '📋-logs-geral',
    jobs            = '📋-logs-geral',
    management      = '🔰-staff',

    -- EMPREGOS (roteamento por job)
    job_ambulance   = '🩺-paramedico',
    job_mechanic    = '🧑‍🔧-mec',
    job_police      = '🚔-police',
    job_general     = '📋-logs-geral',
}

-- =============================================
-- CORES DOS EMBEDS POR TIPO DE LOG (decimal)
-- Conversor: https://www.spycolor.com
-- =============================================
Config.Colors = {
    -- Conexão
    login       = 3066993,   -- Verde
    disconnect  = 15158332,  -- Vermelho
    -- Admin
    admin       = 15105570,  -- Laranja
    staff       = 15105570,  -- Laranja
    kick        = 15158332,  -- Vermelho
    ban         = 15158332,  -- Vermelho
    banthunder  = 10038562,  -- Vermelho escuro
    desban      = 3066993,   -- Verde
    suspeito    = 15844367,  -- Dourado
    anticheat   = 15158332,  -- Vermelho
    freecam     = 15105570,  -- Laranja
    wall        = 15105570,  -- Laranja
    fix         = 3066993,   -- Verde
    noclip      = 15105570,  -- Laranja
    -- Combate
    kill        = 10038562,  -- Vermelho escuro
    pvp         = 15158332,  -- Vermelho
    -- Economia
    money       = 15844367,  -- Dourado
    economy     = 15844367,  -- Dourado
    salary      = 3066993,   -- Verde
    dinheiro    = 15844367,  -- Dourado
    coins       = 15105570,  -- Laranja
    gemstone    = 1752220,   -- Verde escuro
    gemas       = 3447003,   -- Azul
    pawnshop    = 12745742,  -- Dourado escuro
    -- Inventário
    item        = 3447003,   -- Azul escuro
    inventory   = 3447003,   -- Azul escuro
    give        = 15105570,  -- Laranja
    drop        = 15844367,  -- Dourado
    bau         = 7506394,   -- Roxo claro
    stashes     = 7506394,   -- Roxo claro
    crafting    = 1146986,   -- Teal
    -- Veículos
    vehicles    = 1752220,   -- Verde escuro
    car         = 1752220,   -- Verde escuro
    addcar      = 3066993,   -- Verde
    remcar      = 15158332,  -- Vermelho
    carro       = 2123412,   -- Verde jade
    veiculo     = 1752220,   -- Verde escuro
    dv          = 15158332,  -- Vermelho
    garage      = 2067276,   -- Verde azulado
    carkeys     = 3426654,   -- Azul esverdeado
    customs     = 2123412,   -- Verde jade
    mechanic    = 2899536,   -- Verde menta
    mec         = 2899536,   -- Verde menta
    -- Polícia
    police      = 3447003,   -- Azul escuro
    multar      = 15844367,  -- Dourado
    prisao      = 9807270,   -- Roxo
    prison      = 9807270,   -- Roxo
    detido      = 9807270,   -- Roxo
    apreender   = 3447003,   -- Azul
    prontuario  = 3447003,   -- Azul
    -- Ilegal
    robbery     = 11342935,  -- Cinza
    roubos      = 11342935,  -- Cinza
    heist       = 15158332,  -- Vermelho
    illegal     = 10038562,  -- Vermelho escuro
    ilegal      = 10038562,  -- Vermelho escuro
    drugs       = 8359053,   -- Roxo médio
    garmas      = 10038562,  -- Vermelho escuro
    -- Propriedades
    property    = 4886754,   -- Verde suave
    homes       = 4886754,   -- Verde suave
    doors       = 9807270,   -- Roxo
    -- Celular
    phone       = 5793266,   -- Verde celular
    messages    = 5793266,   -- Verde celular
    -- Lojas
    shop        = 15105570,  -- Laranja
    shops       = 15105570,  -- Laranja
    -- Diversos
    general     = 9807270,   -- Roxo
    appearance  = 15277667,  -- Rosa
    airdrops    = 1752220,   -- Verde escuro
    starterpack = 3066993,   -- Verde
    jobs        = 2067276,   -- Verde azulado
    jobcenter   = 3066993,   -- Verde
    management  = 15105570,  -- Laranja
    paramedico  = 15277667,  -- Rosa
    -- Empregos (job routing)
    job_ambulance = 15277667, -- Rosa
    job_mechanic  = 15105570, -- Laranja
    job_police    = 3447003,  -- Azul
    job_general   = 9807270,  -- Roxo
}

-- =============================================
-- CONFIGURAÇÕES GERAIS
-- =============================================

-- Anti-spam: tempo mínimo (em ms) entre logs do MESMO jogador na MESMA categoria
Config.Cooldown = 2000

-- Avatar do bot no Discord (URL de imagem)
Config.BotAvatar = 'https://i.imgur.com/IG3hg2t.png'

-- Nome do bot no Discord
Config.BotName = 'Server Logs'

-- Mostrar IP nos logs? (LGPD: considere desativar em produção)
Config.ShowIP = true

-- Mostrar Steam Hex nos logs?
Config.ShowSteam = true

-- Mostrar Discord ID nos logs?
Config.ShowDiscord = true

-- Ativar logs no console do servidor também?
Config.ConsoleLog = false
