# 📋 qb-logs — Sistema Completo de Logs para Discord

Sistema avançado de logs para **FiveM** com suporte a **QBCore** e **QBOX (qbx_core)**, enviando embeds formatados para canais do Discord via webhooks.

> Desenvolvido por **Veldora**.

---

## ✨ Funcionalidades

- **Detecção automática de framework** — compatível com QBCore e QBOX (qbx_core) sem nenhuma configuração extra
- **Identificação completa do jogador** em todas as logs: Nome RP, CitizenID, Job, Steam Hex, Discord, IP e License
- **3 camadas de fallback** para busca de dados do jogador (nunca mostra "Desconhecido")
- **72+ canais** do Discord configuráveis
- **85+ tipos de log** mapeados para canais
- **100+ armas** traduzidas para PT-BR
- **Anti-spam** com cooldown configurável por jogador/categoria
- **Anti-spam de boot** — acumula resources iniciados durante o boot e envia um único relatório
- **Rate limit handling** — reprocessa automaticamente quando o Discord retorna 429
- **Hooks automáticos** — captura eventos sem precisar modificar outros scripts
- **Exports** — qualquer script pode enviar logs via `exports['qb-logs']`
- **30+ integrações** com scripts populares
- **17 hooks do ps-adminmenu** para ações administrativas

---

## 📁 Estrutura de Arquivos

```
qb-logs/
├── fxmanifest.lua           # Manifest do resource
├── config.lua               # Configuração: webhooks, mapeamentos, cores, flags
├── utils.lua                # Funções auxiliares: identificação, envio, cooldown
├── server.lua               # Handlers principais: connect, kill, inventory, police, admin
├── server_hooks.lua         # Hooks automáticos: money, job, duty, ox_inventory, robberies
└── server_integrations.lua  # Integrações: ps-adminmenu, 30+ scripts da base
```

---

## ⚡ Instalação

1. Copie a pasta `qb-logs` para sua pasta `resources/[seuframework]/`
2. Adicione `ensure qb-logs` no seu `server.cfg` (após `qbx_core`/`qb-core` e `ox_inventory`)
3. Configure os webhooks em `config.lua` (veja abaixo)
4. Reinicie o servidor

### Ordem de ensure recomendada

```cfg
ensure qbx_core       # ou qb-core
ensure ox_inventory
ensure ox_lib
ensure qb-logs         # <-- após o framework e inventário
```

---

## ⚙️ Configuração

### 1. Criar Webhooks no Discord

Para cada canal que deseja receber logs:

1. Acesse o canal no Discord → **Configurações** → **Integrações** → **Webhooks**
2. Clique em **Novo Webhook** e copie a URL
3. Cole a URL no canal correspondente em `Config.Channels`

### 2. Configurar `config.lua`

```lua
-- Nome do servidor (aparece no footer dos embeds)
Config.ServerName = 'Meu Servidor RP'

-- Nome e avatar do bot no Discord
Config.BotName = 'Meu Servidor Logs'
Config.BotAvatar = 'https://i.imgur.com/SUA_IMAGEM.png'

-- Webhooks por canal
Config.Channels = {
    ['🔑-login']    = 'https://discord.com/api/webhooks/SEU_ID/SEU_TOKEN',
    ['💀-kill']     = 'https://discord.com/api/webhooks/SEU_ID/SEU_TOKEN',
    -- ... adicione os demais canais
}

-- Flags de privacidade
Config.ShowIP      = true   -- Mostrar IP nos logs (LGPD: considere false)
Config.ShowSteam   = true   -- Mostrar Steam Hex
Config.ShowDiscord = true   -- Mostrar Discord ID

-- Anti-spam: intervalo mínimo em ms entre logs do mesmo jogador/categoria
Config.Cooldown = 2000

-- Log no console do servidor
Config.ConsoleLog = false
```

### 3. Mapeamento de Tipos de Log

`Config.Logs` mapeia tipos de log para canais. Múltiplos tipos podem apontar para o mesmo canal:

```lua
Config.Logs = {
    login      = '🔑-login',       -- Tipo 'login' → canal '🔑-login'
    disconnect = '🖥️-registros',
    kill       = '💀-kill',
    pvp        = '⚰️-kill',         -- 'pvp' e 'kill' vão para o mesmo canal
    money      = '💵-money',
    -- ...
}
```

### 4. Cores dos Embeds

`Config.Colors` define a cor da barra lateral do embed por tipo:

```lua
Config.Colors = {
    login      = 3066993,   -- Verde
    disconnect = 15158332,  -- Vermelho
    kill       = 10038562,  -- Vermelho escuro
    money      = 15844367,  -- Dourado
    -- ...
}
```

> Use https://www.spycolor.com para converter hex → decimal.

---

## 📡 Exports Disponíveis

Qualquer script pode enviar logs usando os exports abaixo:

### `SendLog` — Log simples

```lua
exports['qb-logs']:SendLog(logType, title, message, color)
```

| Parâmetro | Tipo     | Descrição                               |
|-----------|----------|-----------------------------------------|
| logType   | string   | Tipo do log (deve existir em Config.Logs) |
| title     | string   | Título do embed                         |
| message   | string   | Corpo da mensagem (suporta Markdown)    |
| color     | number?  | Cor do embed (usa Config.Colors se nil) |

**Exemplo:**
```lua
exports['qb-logs']:SendLog('economy', '💰 Pagamento', '**Jogador X** recebeu $5000', 3066993)
```

### `SendPlayerLog` — Log com identificação do jogador

```lua
exports['qb-logs']:SendPlayerLog(source, logType, action, details, color)
```

Automaticamente inclui: ID, Nome RP, CitizenID, Job, Steam, Discord e IP.

**Exemplo:**
```lua
exports['qb-logs']:SendPlayerLog(source, 'economy', 'VENDEU ITEM', 'Item: Diamante\nPreço: $5000')
```

### `SendAdminLog` — Log administrativo (staff + alvo)

```lua
exports['qb-logs']:SendAdminLog(staffSrc, targetSrc, command, result, logType, color)
```

Mostra informações tanto do staff quanto do alvo.

**Exemplo:**
```lua
exports['qb-logs']:SendAdminLog(source, targetId, '/ban', 'Motivo: Cheating\nDuração: 7d', 'ban')
```

### `GetPlayerInfo` — Informações do jogador

```lua
local info = exports['qb-logs']:GetPlayerInfo(source)
-- info.id, info.name, info.citizenid, info.job, info.steam, info.discord, info.ip, info.license
```

### `BuildPlayerBlock` — Bloco de identificação formatado

```lua
local block = exports['qb-logs']:BuildPlayerBlock(source)
-- Retorna string formatada com todas as informações do jogador
```

### `GetCharacterData` — Dados do personagem

```lua
local char = exports['qb-logs']:GetCharacterData(source)
-- char.name, char.citizenid, char.job, char.jobGrade
```

### `ResolveCoords` — Resolver coordenadas (multi-formato)

```lua
local coords = exports['qb-logs']:ResolveCoords(coordsData, fallbackSource)
-- Aceita vector3, {x,y,z}, {[1],[2],[3]} ou source como fallback
```

### Outros exports

```lua
exports['qb-logs']:GetWebhookByChannelName(channelName)  -- URL do webhook
exports['qb-logs']:IsLogEnabled(logType)                  -- bool: log ativo?
exports['qb-logs']:GetSteamHex(source)                    -- Steam Hex
exports['qb-logs']:GetDiscordId(source)                   -- Discord ID formatado
exports['qb-logs']:GetPlayerIP(source)                    -- IP do jogador
```

---

## 🔌 Integrações Automáticas

O script captura eventos automaticamente dos seguintes resources:

### Framework Core (server_hooks.lua)
| Resource | Eventos Capturados |
|---|---|
| qbx_core / qb-core | Dinheiro (add/remove/set), Job, Gang, Duty on/off, Metadata |
| ox_inventory | addItem, removeItem, usingItem, swapItems, buyItem, craftItem |
| qbx_vehicleshop | Compra, Venda, Test Drive |
| qbx_bankrobbery | Início, Loot, Alerta policial |
| qbx_jewelery | Vitrine, Hack porta |
| qbx_houserobbery | Entrada, Saída, Loot, Pickup |

### Admin (server_integrations.lua)
| Resource | Eventos Capturados |
|---|---|
| ps-adminmenu | Revive, ReviveAll, ReviveRadius, Ban, Kick, Warn, GiveMoney, GiveMoneyAll, TakeMoney, Unban (CID/RowID/Player), DeleteCID, SetBucket, Blackout, Cuff, Verify |

### Scripts Integrados (server_integrations.lua)
| Resource | O que é logado |
|---|---|
| qbx_drugs | Venda ao dealer, entrega, alerta policial |
| qbx_customs | Customização de veículos |
| qbx_management | Boss menu (via Job Update) |
| qbx_mechanicjob | Reparos, peças, plataforma |
| qbx_garbagejob | Pagamento de turno |
| qbx_properties | Entrar/sair/campainha |
| qbx_scrapyard | Sucatear veículo |
| qbx_pawnshop | Venda, fundição, coleta |
| qbx_towjob | Reboque de veículos |
| qbx_truckrobbery | Início de roubo, bomba |
| qbx_spawn | Spawn do personagem |
| qbx_fireworks | Fogos de artifício |
| qbx_idcard | Mostrar documentos |
| Qbx_DJ | Tocar música, equipamento |
| mri_Qfarm | Colheita de itens |
| mri_Qstorerobbery | Registradora, alerta, hack cofre |
| mri_Qfleecaheist | Assalto ao Fleeca |
| mri_Qcarkeys | Chave permanente/temporária, lockpick, tranca |
| mri_Qstashes | Criar, deletar, atualizar, mover stash |
| mri_Qcrafting | Craft, mesa de craft, receitas |
| mri_Qstarterpack | Resgate de pack e veículo |
| mri_Qblackout | Blackout liga/desliga |
| mri_Qjobsystem | Criar/editar/deletar emprego |
| mri_Qjobcenter | Seleção de emprego |
| mri_Qboombox | Tocar/remover boombox |
| rhd_garage | Estado do veículo, zona, renomear |
| illenium-appearance | Via economia (pagamentos) |
| bbv-airdrops | Criar, coletar, encerrar airdrop |
| ox_doorlock | Trancar/destrancar portas |
| lb-phone | Via economia (transferências) |

---

## 🔧 Adicionar Novo Tipo de Log

1. **Adicione o canal** em `Config.Channels`:
   ```lua
   ['📦-novo-canal'] = 'https://discord.com/api/webhooks/SEU_ID/SEU_TOKEN',
   ```

2. **Mapeie o tipo** em `Config.Logs`:
   ```lua
   meuNovoLog = '📦-novo-canal',
   ```

3. **Defina a cor** em `Config.Colors`:
   ```lua
   meuNovoLog = 3066993,  -- Verde
   ```

4. **Use no código:**
   ```lua
   exports['qb-logs']:SendPlayerLog(source, 'meuNovoLog', 'AÇÃO', 'Detalhes aqui')
   ```

---

## 🔧 Adicionar Nova Integração

Para hookar um novo script, adicione no `server_integrations.lua`:

```lua
RegisterNetEvent('meu-script:server:meuEvento', function(param1, param2)
    local src = source
    if not src or src <= 0 then return end

    SendPlayerLog(src, 'general', 'MINHA AÇÃO',
        'Param1: **' .. tostring(param1 or '?') .. '**' ..
        '\nParam2: **' .. tostring(param2 or '?') .. '**')
end)
```

---

## 📋 Lista de Canais Pré-configurados

<details>
<summary>Ver todos os 72+ canais</summary>

| Categoria | Canal |
|---|---|
| Conexão | 🔑-login, 🆑-cl, 🖥️-registros, 📋-logs-geral |
| Admin | 🛡️-admin, 🔰-staff, 🥾-kick, 🔴-ban, 🚫-ban-thunder, 🟢-desban, ❗-suspeito, 🎥-freecam, 🧱-wall, 🛠️-fix |
| Economia | 💵-money, 💰-salary, 💰-dinheiro, 🪙-coins, 💎-gemstone, 🔹-gemas |
| Inventário | 📦-item, 📦-give, 📤-dropar-item, ℹ️-dropar-item, 📦-bau |
| Veículos | 🚗-addcar, 🚗-remcar, 🚗-car, 🚗-carro, 🚗-veiculo, 🚗-veiculos, 🚗-dv, 🏪-garage |
| Combate | ⚰️-kill, 💀-kill |
| Polícia | 🚔-police, 💸-multar, 🚨-prisao, ⛓️-detido, 📚-apreender, 📝-ocorrências, 📋-prontuario |
| Ilegal | 💲-roubos, 💀-ilegal-geral, 🔫-garmas |
| Propriedades | 🏠-homes, 🏠-baú-casas, 🚓-baú-policias, 🕵️-baú-facções, 🚗-baú-veículos, 🏥-baú-hospital, 🔧-baú-mecanica, 💀-baú-orgs-ilegais |
| Celular | 📱-messages, 📱-chamadas, 📱-instapic, 📱-birdy, 📱-darkchat, 📱-crypto, 📱-uploads |
| Lojas | 🛒-shop, 🏬-loja-em-gamer, 🏬-lojacoin-em-gamer, 💴-vendas-in-game |
| Diversos | 🧑‍🔧-mec, 🩺-paramedico, ⛽-posto-de-gas, 🕒-bate-ponto, 🕒-ponto-staff |

</details>

---

## 📝 Notas Importantes

- **LGPD/Privacidade:** O script pode exibir IPs de jogadores. Use `Config.ShowIP = false` se necessário.
- **Webhooks são secretas:** Nunca compartilhe suas URLs de webhook publicamente.
- **Rate limits:** O script lida automaticamente com rate limits do Discord (HTTP 429).
- **Lua 5.4:** O script usa `lua54 'yes'` no fxmanifest.
- **Dependências:** Requer `qbx_core` ou `qb-core`. O `ox_inventory` é opcional mas recomendado.

---

## 📜 Licença

Este projeto é disponibilizado como open-source. Você pode usar, modificar e distribuir livremente.

Credite o autor original se redistribuir.

---

## 🤝 Créditos

- **Veldora** — Desenvolvimento e arquitetura
- Baseado no ecossistema **QBOX/QBCore** para FiveM
