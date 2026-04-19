const { SlashCommandBuilder, PermissionFlagsBits, ChannelType } = require('discord.js');

const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

async function deleteRecentMessages(channel, messages) {
    const recent = messages.filter((m) => Date.now() - m.createdTimestamp < 14 * 24 * 60 * 60 * 1000);
    if (recent.size === 0) return 0;
    const deleted = await channel.bulkDelete(recent, true);
    return deleted.size;
}

async function deleteOldMessages(channel, messages) {
    const old = messages.filter((m) => Date.now() - m.createdTimestamp >= 14 * 24 * 60 * 60 * 1000);
    let count = 0;

    for (const [, msg] of old) {
        let retries = 0;
        while (retries < 3) {
            try {
                await msg.delete();
                count++;
                await delay(400);
                break;
            } catch (err) {
                retries++;
                if (retries >= 3) {
                    console.error(`   ❌ Falha ao deletar msg ${msg.id}: ${err.message}`);
                } else {
                    await delay(1000 * retries);
                }
            }
        }
    }
    return count;
}

async function cleanChannel(channel) {
    let totalDeleted = 0;
    let hasMore = true;

    while (hasMore) {
        let messages;
        let retries = 0;

        while (retries < 3) {
            try {
                messages = await channel.messages.fetch({ limit: 100 });
                break;
            } catch (err) {
                retries++;
                if (retries >= 3) return totalDeleted;
                await delay(1000 * retries);
            }
        }

        if (!messages || messages.size === 0) {
            hasMore = false;
            break;
        }

        const recentCount = await deleteRecentMessages(channel, messages);
        const oldCount = await deleteOldMessages(channel, messages);
        totalDeleted += recentCount + oldCount;

        if (recentCount + oldCount === 0) hasMore = false;
        await delay(500);
    }

    return totalDeleted;
}

/**
 * Recria o canal (clona + deleta original) — limpeza instantânea
 */
async function recreateChannel(channel) {
    const cloned = await channel.clone({
        reason: 'Limpeza instantânea — canal recriado pelo Gerador de Webhooks',
    });
    await cloned.setPosition(channel.position).catch(() => {});
    await channel.delete('Limpeza instantânea — substituído pelo clone');
    return cloned;
}

module.exports = {
    data: new SlashCommandBuilder()
        .setName('limpar_canal')
        .setDescription('Apaga todas as mensagens de um canal específico')
        .setDefaultMemberPermissions(PermissionFlagsBits.Administrator)
        .addChannelOption((option) =>
            option
                .setName('canal')
                .setDescription('O canal para limpar')
                .setRequired(true)
                .addChannelTypes(ChannelType.GuildText, ChannelType.GuildAnnouncement)
        )
        .addStringOption((option) =>
            option
                .setName('modo')
                .setDescription('Modo de limpeza')
                .setRequired(false)
                .addChoices(
                    { name: '📨 Mensagens — Apaga mensagem por mensagem', value: 'mensagens' },
                    { name: '⚡ Recriar — Clona e deleta o canal (instantâneo)', value: 'recriar' },
                )
        ),

    async execute(interaction) {
        const channel = interaction.options.getChannel('canal');
        const modo = interaction.options.getString('modo') || 'mensagens';
        const botMember = interaction.guild.members.me;

        const permissions = channel.permissionsFor(botMember);
        if (!permissions || !permissions.has(PermissionFlagsBits.ViewChannel) || !permissions.has(PermissionFlagsBits.ManageMessages)) {
            return interaction.reply({
                content: `❌ Eu não tenho permissão para gerenciar mensagens em <#${channel.id}>.`,
                ephemeral: true,
            });
        }

        if (modo === 'recriar' && !permissions.has(PermissionFlagsBits.ManageChannels)) {
            return interaction.reply({
                content: `❌ Eu não tenho permissão para **Gerenciar Canais** em <#${channel.id}> (necessário para o modo recriar).`,
                ephemeral: true,
            });
        }

        await interaction.deferReply();

        if (modo === 'recriar') {
            console.log(`⚡ Recriando canal: #${channel.name}`);

            try {
                const isCommandChannel = channel.id === interaction.channelId;

                if (isCommandChannel) {
                    await interaction.editReply(
                        `🔄 Recriando o canal <#${channel.id}>... Este canal será substituído.`
                    );
                    await delay(1000);
                }

                const newChannel = await recreateChannel(channel);
                console.log(`✅ #${newChannel.name} — recriado com sucesso`);

                // Envia confirmação no novo canal (o original foi deletado)
                await newChannel.send(`✅ **Canal recriado com sucesso!** Todas as mensagens foram removidas.`);
            } catch (err) {
                console.error(`❌ Erro ao recriar #${channel.name}:`, err.message);
                // Se o canal original ainda existe, tenta responder
                try {
                    await interaction.editReply(`❌ Erro ao recriar o canal: ${err.message}`);
                } catch (_) {}
            }
        } else {
            console.log(`🧹 Limpando canal: #${channel.name}`);

            try {
                const deleted = await cleanChannel(channel);
                console.log(`✅ #${channel.name} — ${deleted} mensagem(ns) apagada(s)`);

                await interaction.editReply(
                    `✅ **Limpeza concluída** em <#${channel.id}>!\n\n🗑️ **Mensagens deletadas:** ${deleted}`
                );
            } catch (err) {
                console.error(`❌ Erro ao limpar #${channel.name}:`, err.message);
                await interaction.editReply(`❌ Erro ao limpar <#${channel.id}>: ${err.message}`);
            }
        }
    },
};
