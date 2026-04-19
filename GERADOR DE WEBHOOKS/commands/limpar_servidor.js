const { SlashCommandBuilder, PermissionFlagsBits } = require('discord.js');

// Delay para evitar rate limit
const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

// Tempo maximo por canal no modo mensagens (60 segundos)
const MAX_TIME_PER_CHANNEL = 60 * 1000;

/**
 * Deleta mensagens recentes (< 14 dias) usando bulkDelete
 */
async function deleteRecentMessages(channel, messages) {
    const recent = messages.filter((m) => Date.now() - m.createdTimestamp < 14 * 24 * 60 * 60 * 1000);
    if (recent.size === 0) return 0;
    const deleted = await channel.bulkDelete(recent, true);
    return deleted.size;
}

/**
 * Deleta mensagens antigas (> 14 dias) individualmente com limite de tempo
 */
async function deleteOldMessages(channel, messages, deadline) {
    const old = messages.filter((m) => Date.now() - m.createdTimestamp >= 14 * 24 * 60 * 60 * 1000);
    let count = 0;

    for (const [, msg] of old) {
        if (Date.now() >= deadline) break;

        let retries = 0;
        while (retries < 3) {
            try {
                await msg.delete();
                count++;
                await delay(300);
                break;
            } catch (err) {
                retries++;
                if (retries >= 3) {
                    console.error(`   ❌ Falha ao deletar msg ${msg.id}: ${err.message}`);
                } else {
                    await delay(800 * retries);
                }
            }
        }
    }
    return count;
}

/**
 * Limpa mensagens de um canal com tempo limite
 */
async function cleanChannel(channel, maxTime) {
    const deadline = Date.now() + maxTime;
    let totalDeleted = 0;
    let hasMore = true;

    while (hasMore && Date.now() < deadline) {
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
        const oldCount = await deleteOldMessages(channel, messages, deadline);
        totalDeleted += recentCount + oldCount;

        if (recentCount + oldCount === 0) hasMore = false;
        await delay(300);
    }

    if (Date.now() >= deadline && hasMore) {
        console.log(`   ⏰ Tempo limite atingido em #${channel.name} — ${totalDeleted} msgs apagadas`);
    }

    return totalDeleted;
}

/**
 * Recria o canal (clona + deleta original) — limpeza instantanea
 */
async function recreateChannel(channel) {
    const cloned = await channel.clone({
        reason: 'Limpeza instantanea — canal recriado pelo Gerador de Webhooks',
    });
    await cloned.setPosition(channel.position).catch(() => {});
    await channel.delete('Limpeza instantanea — substituido pelo clone');
    return cloned;
}

/**
 * Tenta responder na interacao, senao envia direto no canal
 */
async function safeSend(interaction, commandChannel, content) {
    try {
        if (interaction.replied || interaction.deferred) {
            await interaction.editReply(content);
        } else {
            await interaction.reply(content);
        }
    } catch (_) {
        try {
            await commandChannel.send(content);
        } catch (__) {}
    }
}

module.exports = {
    data: new SlashCommandBuilder()
        .setName('limpar_servidor')
        .setDescription('Apaga TODAS as mensagens de todos os canais de texto do servidor')
        .setDefaultMemberPermissions(PermissionFlagsBits.Administrator)
        .addBooleanOption((option) =>
            option
                .setName('confirmar')
                .setDescription('Confirme com true para executar a limpeza')
                .setRequired(true)
        )
        .addStringOption((option) =>
            option
                .setName('modo')
                .setDescription('Modo de limpeza')
                .setRequired(false)
                .addChoices(
                    { name: '📨 Mensagens — Apaga mensagem por mensagem', value: 'mensagens' },
                    { name: '⚡ Recriar — Clona e deleta o canal (instantaneo)', value: 'recriar' },
                )
        ),

    async execute(interaction) {
        const confirmar = interaction.options.getBoolean('confirmar');
        const modo = interaction.options.getString('modo') || 'mensagens';

        if (!confirmar) {
            return interaction.reply({
                content: '⚠️ Esse comando apagara **TODAS** as mensagens do servidor.\nUse `/limpar_servidor confirmar:True` para continuar.',
                ephemeral: true,
            });
        }

        const botMember = interaction.guild.members.me;

        if (!botMember.permissions.has(PermissionFlagsBits.ManageMessages)) {
            return interaction.reply({
                content: '❌ Eu nao tenho permissao para **Gerenciar Mensagens**.',
                ephemeral: true,
            });
        }

        if (!botMember.permissions.has(PermissionFlagsBits.ViewChannel)) {
            return interaction.reply({
                content: '❌ Eu nao tenho permissao para **Ver Canais**.',
                ephemeral: true,
            });
        }

        if (modo === 'recriar' && !botMember.permissions.has(PermissionFlagsBits.ManageChannels)) {
            return interaction.reply({
                content: '❌ Eu nao tenho permissao para **Gerenciar Canais** (necessario para o modo recriar).',
                ephemeral: true,
            });
        }

        await interaction.deferReply();

        const guild = interaction.guild;
        const commandChannel = interaction.channel;
        await guild.channels.fetch();

        const textChannels = guild.channels.cache.filter(
            (ch) => ch.isTextBased() && !ch.isThread() && !ch.isVoiceBased() && ch.type !== 4
        );

        if (textChannels.size === 0) {
            return interaction.editReply('⚠️ Nenhum canal de texto encontrado.');
        }

        const totalChannels = textChannels.size;
        let channelsDone = 0;
        let totalMessages = 0;
        let channelErrors = 0;
        const modoLabel = modo === 'recriar' ? '⚡ RECRIAR CANAIS' : '📨 DELETAR MENSAGENS';

        console.log('');
        console.log('═══════════════════════════════════════════');
        console.log(`   🧹 LIMPEZA DE SERVIDOR — ${modoLabel}`);
        console.log(`   📊 Total de canais: ${totalChannels}`);
        console.log('═══════════════════════════════════════════');
        console.log('');

        if (modo === 'recriar') {
            const commandChannelId = interaction.channelId;
            const sorted = [...textChannels.values()].sort((a, b) => {
                // Canal do comando sempre por último
                if (a.id === commandChannelId) return 1;
                if (b.id === commandChannelId) return -1;
                // Ordem visual de cima para baixo
                const catA = a.parent ? a.parent.rawPosition : -1;
                const catB = b.parent ? b.parent.rawPosition : -1;
                if (catA !== catB) return catA - catB;
                return a.rawPosition - b.rawPosition;
            });

            for (const channel of sorted) {
                const permissions = channel.permissionsFor(botMember);
                if (!permissions || !permissions.has(PermissionFlagsBits.ManageChannels)) {
                    console.log(`⚠️  Sem permissao no canal: #${channel.name}`);
                    channelErrors++;
                    channelsDone++;
                    continue;
                }

                const percent = Math.round((channelsDone / totalChannels) * 100);
                console.log(`[${percent}%] ⚡ Recriando: #${channel.name}`);

                try {
                    const isCommandChannel = channel.id === commandChannelId;

                    if (isCommandChannel) {
                        await safeSend(interaction, commandChannel,
                            `✅ **Limpeza concluida (modo recriar)!**\n\n` +
                            `⚡ **Canais recriados:** ${channelsDone}/${totalChannels}\n` +
                            `❌ **Erros:** ${channelErrors}\n\n` +
                            `🔄 Este canal sera recriado agora...`
                        );
                        await delay(1000);
                    }

                    const newChannel = await recreateChannel(channel);
                    console.log(`   ✅ #${newChannel.name} — recriado com sucesso`);
                    channelsDone++;
                    await delay(500);
                } catch (err) {
                    console.error(`   ❌ Erro em #${channel.name}: ${err.message}`);
                    channelErrors++;
                    channelsDone++;
                }
            }

            console.log('');
            console.log('═══════════════════════════════════════════');
            console.log('   ✅ LIMPEZA CONCLUIDA (RECRIAR)');
            console.log(`   ⚡ Canais recriados: ${channelsDone - channelErrors}/${totalChannels}`);
            console.log(`   ❌ Erros: ${channelErrors}`);
            console.log('═══════════════════════════════════════════');
            console.log('');

        } else {
            // Modo mensagens com tempo limite por canal e progresso
            // Ordena na ordem visual do Discord (de cima para baixo)
            const sortedChannels = [...textChannels.values()].sort((a, b) => {
                const catA = a.parent ? a.parent.rawPosition : -1;
                const catB = b.parent ? b.parent.rawPosition : -1;
                if (catA !== catB) return catA - catB;
                return a.rawPosition - b.rawPosition;
            });
            for (const channel of sortedChannels) {
                const permissions = channel.permissionsFor(botMember);
                if (!permissions || !permissions.has(PermissionFlagsBits.ViewChannel) || !permissions.has(PermissionFlagsBits.ManageMessages)) {
                    console.log(`⚠️  Sem permissao no canal: #${channel.name}`);
                    channelErrors++;
                    channelsDone++;
                    continue;
                }

                const percent = Math.round((channelsDone / totalChannels) * 100);
                console.log(`[${percent}%] 🧹 Limpando: #${channel.name}`);

                try {
                    const deleted = await cleanChannel(channel, MAX_TIME_PER_CHANNEL);
                    totalMessages += deleted;
                    console.log(`   ✅ #${channel.name} — ${deleted} mensagem(ns) apagada(s)`);
                } catch (err) {
                    console.error(`   ❌ Erro em #${channel.name}: ${err.message}`);
                    channelErrors++;
                }

                channelsDone++;

                // Envia progresso a cada 10 canais
                if (channelsDone % 10 === 0 && channelsDone < totalChannels) {
                    const pct = Math.round((channelsDone / totalChannels) * 100);
                    await safeSend(interaction, commandChannel,
                        `⏳ **Limpeza em andamento...**\n\n` +
                        `📊 Progresso: **${channelsDone}/${totalChannels}** canais (${pct}%)\n` +
                        `🗑️ Mensagens deletadas: ${totalMessages} | ❌ Erros: ${channelErrors}`
                    );
                }

                await delay(300);
            }

            console.log('');
            console.log('═══════════════════════════════════════════');
            console.log('   ✅ LIMPEZA CONCLUIDA');
            console.log(`   📊 Canais limpos: ${channelsDone - channelErrors}/${totalChannels}`);
            console.log(`   🗑️  Mensagens deletadas: ${totalMessages}`);
            console.log(`   ❌ Erros: ${channelErrors}`);
            console.log('═══════════════════════════════════════════');
            console.log('');

            await safeSend(interaction, commandChannel,
                `✅ **Limpeza concluida!**\n\n` +
                `📊 **Canais limpos:** ${channelsDone - channelErrors}/${totalChannels}\n` +
                `🗑️ **Mensagens deletadas:** ${totalMessages}\n` +
                `❌ **Erros:** ${channelErrors}`
            );
        }
    },
};
