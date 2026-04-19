const { Client, GatewayIntentBits, Collection, Events } = require('discord.js');
const { token } = require('./config');
const fs = require('fs');
const path = require('path');

// Cria o client do bot com as intents necessárias
const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildWebhooks,
    ],
});

// Carrega os comandos da pasta /commands
client.commands = new Collection();
const commandsPath = path.join(__dirname, 'commands');
const commandFiles = fs.readdirSync(commandsPath).filter((file) => file.endsWith('.js'));

for (const file of commandFiles) {
    const filePath = path.join(commandsPath, file);
    const command = require(filePath);

    if ('data' in command && 'execute' in command) {
        client.commands.set(command.data.name, command);
        console.log(`📦 Comando carregado: /${command.data.name}`);
    } else {
        console.warn(`⚠️  Comando em ${filePath} não possui "data" ou "execute".`);
    }
}

// Evento: bot pronto
client.once(Events.ClientReady, (readyClient) => {
    console.log('');
    console.log('═══════════════════════════════════════════');
    console.log('   🤖 GERADOR DE WEBHOOKS - ONLINE');
    console.log(`   👤 Logado como: ${readyClient.user.tag}`);
    console.log(`   🆔 ID: ${readyClient.user.id}`);
    console.log(`   📡 Servidores: ${readyClient.guilds.cache.size}`);
    console.log('═══════════════════════════════════════════');
    console.log('');
});

// Evento: interação (slash commands)
client.on(Events.InteractionCreate, async (interaction) => {
    if (!interaction.isChatInputCommand()) return;

    const command = client.commands.get(interaction.commandName);

    if (!command) {
        console.error(`❌ Comando não encontrado: ${interaction.commandName}`);
        return;
    }

    try {
        await command.execute(interaction);
    } catch (error) {
        console.error(`❌ Erro ao executar /${interaction.commandName}:`, error);

        const errorMessage = '❌ Ocorreu um erro ao executar este comando.';

        try {
            if (interaction.replied || interaction.deferred) {
                await interaction.followUp({ content: errorMessage, ephemeral: true });
            } else {
                await interaction.reply({ content: errorMessage, ephemeral: true });
            }
        } catch (_) {
            // Token de interação expirado — ignora
            console.warn('⚠️  Não foi possível responder (token expirado).');
        }
    }
});

// Previne crash por erros não tratados
process.on('unhandledRejection', (error) => {
    console.error('⚠️  Rejeição não tratada:', error);
});

// Login do bot
client.login(token);
