const { REST, Routes } = require('discord.js');
const { token, clientId, guildId } = require('./config');
const fs = require('fs');
const path = require('path');

// Carrega todos os comandos da pasta /commands
const commands = [];
const commandsPath = path.join(__dirname, 'commands');
const commandFiles = fs.readdirSync(commandsPath).filter((file) => file.endsWith('.js'));

for (const file of commandFiles) {
    const filePath = path.join(commandsPath, file);
    const command = require(filePath);

    if ('data' in command) {
        commands.push(command.data.toJSON());
        console.log(`📦 Comando encontrado: /${command.data.name}`);
    }
}

// Registra os comandos no Discord
const rest = new REST({ version: '10' }).setToken(token);

(async () => {
    try {
        console.log('');
        console.log(`🔄 Registrando ${commands.length} comando(s) slash...`);

        // Registra no servidor específico (guild) - atualização instantânea
        const data = await rest.put(
            Routes.applicationGuildCommands(clientId, guildId),
            { body: commands },
        );

        console.log(`✅ ${data.length} comando(s) registrado(s) com sucesso!`);
        console.log('');
    } catch (error) {
        console.error('❌ Erro ao registrar comandos:', error);
    }
})();
