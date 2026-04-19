const { SlashCommandBuilder, PermissionFlagsBits, ChannelType } = require('discord.js');
const { webhookAvatarURL } = require('../config');

module.exports = {
    data: new SlashCommandBuilder()
        .setName('webhook')
        .setDescription('Cria uma webhook para um canal específico')
        .setDefaultMemberPermissions(PermissionFlagsBits.ManageWebhooks)
        .addChannelOption((option) =>
            option
                .setName('canal')
                .setDescription('O canal onde a webhook será criada')
                .setRequired(true)
                .addChannelTypes(ChannelType.GuildText, ChannelType.GuildAnnouncement)
        ),

    async execute(interaction) {
        const botMember = interaction.guild.members.me;

        // Verifica permissões do bot
        if (!botMember.permissions.has(PermissionFlagsBits.ManageWebhooks)) {
            return interaction.reply({
                content: '❌ Eu não tenho permissão para **Gerenciar Webhooks**. Por favor, conceda essa permissão ao meu cargo.',
                ephemeral: true,
            });
        }

        const channel = interaction.options.getChannel('canal');

        // Verifica permissões no canal específico
        const permissions = channel.permissionsFor(botMember);
        if (!permissions || !permissions.has(PermissionFlagsBits.ViewChannel) || !permissions.has(PermissionFlagsBits.ManageWebhooks)) {
            return interaction.reply({
                content: `❌ Eu não tenho permissão para gerenciar webhooks no canal <#${channel.id}>.`,
                ephemeral: true,
            });
        }

        await interaction.deferReply();

        try {
            // Busca webhooks existentes no canal
            const existingWebhooks = await channel.fetchWebhooks();

            // Verifica se já existe uma webhook criada por este bot
            const botWebhook = existingWebhooks.find(
                (wh) => wh.owner && wh.owner.id === interaction.client.user.id
            );

            if (botWebhook) {
                console.log(`♻️  Webhook já existe no canal: #${channel.name}`);
                await interaction.editReply(
                    `♻️ **Webhook já existente** no canal <#${channel.id}>!\n\n` +
                    `📛 **Nome:** ${botWebhook.name}\n` +
                    `🔗 **URL:** \`${botWebhook.url}\``
                );
            } else {
                console.log(`🔧 Criando webhook no canal: #${channel.name}`);

                const newWebhook = await channel.createWebhook({
                    name: channel.name,
                    avatar: webhookAvatarURL,
                    reason: 'Webhook criada pelo comando /webhook',
                });

                console.log(`✅ Webhook criada com sucesso no canal: #${channel.name}`);
                await interaction.editReply(
                    `✅ **Webhook criada** no canal <#${channel.id}>!\n\n` +
                    `📛 **Nome:** ${newWebhook.name}\n` +
                    `🔗 **URL:** \`${newWebhook.url}\``
                );
            }
        } catch (err) {
            console.error(`❌ Erro ao criar webhook no canal #${channel.name}:`, err.message);
            await interaction.editReply(`❌ Erro ao criar webhook no canal <#${channel.id}>: ${err.message}`);
        }
    },
};
