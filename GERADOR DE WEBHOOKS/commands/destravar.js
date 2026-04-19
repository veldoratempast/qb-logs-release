const { SlashCommandBuilder, PermissionFlagsBits } = require('discord.js');
const state = require('../state');

module.exports = {
    data: new SlashCommandBuilder()
        .setName('destravar')
        .setDescription('Destrava o mapeamento pulando o canal atual e continuando o processo')
        .setDefaultMemberPermissions(PermissionFlagsBits.ManageWebhooks),

    async execute(interaction) {
        if (!state.isMapping) {
            return interaction.reply({
                content: '⚠️ Nenhum mapeamento em andamento no momento.',
                ephemeral: true,
            });
        }

        const channelName = state.currentChannel || 'desconhecido';
        state.skipCurrent = true;

        console.log(`🔓 DESTRAVAR: Pulando canal #${channelName} por comando do usuario`);

        await interaction.reply(
            `🔓 **Destravando mapeamento!**\n\n` +
            `⏭️ Pulando o canal: **#${channelName}**\n` +
            `▶️ O processo continuara com o proximo canal.`
        );
    },
};
