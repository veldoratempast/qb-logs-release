const { SlashCommandBuilder, PermissionFlagsBits, AttachmentBuilder } = require('discord.js');

module.exports = {
    data: new SlashCommandBuilder()
        .setName('exportar')
        .setDescription('Exporta todas as webhooks criadas pelo bot em um arquivo JSON')
        .setDefaultMemberPermissions(PermissionFlagsBits.ManageWebhooks),

    async execute(interaction) {
        const botMember = interaction.guild.members.me;

        if (!botMember.permissions.has(PermissionFlagsBits.ManageWebhooks)) {
            return interaction.reply({
                content: '❌ Eu não tenho permissão para **Gerenciar Webhooks**.',
                ephemeral: true,
            });
        }

        await interaction.deferReply();

        const guild = interaction.guild;
        await guild.channels.fetch();

        const textChannels = guild.channels.cache.filter(
            (ch) => ch.isTextBased() && !ch.isThread() && !ch.isVoiceBased() && ch.type !== 4
        );

        const result = {};
        let total = 0;

        for (const [, channel] of textChannels) {
            try {
                const permissions = channel.permissionsFor(botMember);
                if (!permissions || !permissions.has(PermissionFlagsBits.ViewChannel) || !permissions.has(PermissionFlagsBits.ManageWebhooks)) {
                    continue;
                }

                const webhooks = await channel.fetchWebhooks();
                const botWebhooks = webhooks.filter(
                    (wh) => wh.owner && wh.owner.id === interaction.client.user.id
                );

                for (const [, wh] of botWebhooks) {
                    result[channel.name] = {
                        canalId: channel.id,
                        webhookId: wh.id,
                        webhookToken: wh.token,
                        url: wh.url,
                    };
                    total++;
                }
            } catch (err) {
                console.error(`❌ Erro ao buscar webhooks em #${channel.name}:`, err.message);
            }
        }

        if (total === 0) {
            return interaction.editReply('⚠️ Nenhuma webhook criada por mim foi encontrada. Use `/mapear` primeiro.');
        }

        const json = JSON.stringify(result, null, 2);
        const buffer = Buffer.from(json, 'utf-8');
        const attachment = new AttachmentBuilder(buffer, { name: 'webhooks.json' });

        await interaction.editReply({
            content: `✅ **${total} webhook(s)** exportada(s) com sucesso!`,
            files: [attachment],
        });
    },
};
