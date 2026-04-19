const { SlashCommandBuilder, PermissionFlagsBits, AttachmentBuilder } = require('discord.js');
const { webhookAvatarURL } = require('../config');
const state = require('../state');
const fs = require('fs');
const path = require('path');

// Delay para evitar rate limit
const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

// Caminho do arquivo de salvamento
const SAVE_PATH = path.join(__dirname, '..', 'webhooks.json');

/**
 * Carrega webhooks.json existente ou retorna objeto vazio
 */
function loadSavedWebhooks() {
    try {
        if (fs.existsSync(SAVE_PATH)) {
            return JSON.parse(fs.readFileSync(SAVE_PATH, 'utf-8'));
        }
    } catch (_) {}
    return {};
}

/**
 * Salva o objeto no webhooks.json
 */
function saveWebhooks(data) {
    fs.writeFileSync(SAVE_PATH, JSON.stringify(data, null, 2), 'utf-8');
}

module.exports = {
    data: new SlashCommandBuilder()
        .setName('mapear')
        .setDescription('Mapeia todos os canais de texto e recria webhooks automaticamente')
        .setDefaultMemberPermissions(PermissionFlagsBits.ManageWebhooks)
        .addBooleanOption((option) =>
            option
                .setName('recriar_tudo')
                .setDescription('Ignorar progresso anterior e recriar todas as webhooks do zero')
                .setRequired(false)
        ),

    async execute(interaction) {
        const forceReset = interaction.options.getBoolean('recriar_tudo') || false;

        // Verifica se já tem um mapeamento rodando
        if (state.isMapping) {
            return interaction.reply({
                content: '⚠️ Já existe um mapeamento em andamento. Use `/destravar` se estiver travado.',
                ephemeral: true,
            });
        }

        // Verifica permissões do bot
        const botMember = interaction.guild.members.me;

        if (!botMember.permissions.has(PermissionFlagsBits.ManageWebhooks)) {
            return interaction.reply({
                content: '❌ Eu não tenho permissão para **Gerenciar Webhooks**. Por favor, conceda essa permissão ao meu cargo.',
                ephemeral: true,
            });
        }

        if (!botMember.permissions.has(PermissionFlagsBits.ViewChannel)) {
            return interaction.reply({
                content: '❌ Eu não tenho permissão para **Ver Canais**. Por favor, conceda essa permissão ao meu cargo.',
                ephemeral: true,
            });
        }

        // Defer para não dar timeout (pode demorar)
        await interaction.deferReply();

        const guild = interaction.guild;
        const commandChannel = interaction.channel;

        // Busca todos os canais atualizados
        await guild.channels.fetch();

        // Filtra apenas canais de texto (ignora categorias, voz, etc.)
        const textChannels = guild.channels.cache.filter(
            (ch) => ch.isTextBased() && !ch.isThread() && !ch.isVoiceBased() && ch.type !== 4 // 4 = GuildCategory
        );

        if (textChannels.size === 0) {
            return interaction.editReply('⚠️ Nenhum canal de texto encontrado neste servidor.');
        }

        // Carrega progresso anterior ou começa do zero
        const savedData = forceReset ? {} : loadSavedWebhooks();
        if (forceReset) {
            saveWebhooks(savedData);
            console.log('🔄 Modo recriar_tudo ativado — progresso anterior descartado');
        }
        const alreadyDone = new Set(Object.keys(savedData));

        const webhookList = [];
        let created = 0;
        let deleted = 0;
        let errors = 0;
        let skipped = 0;
        let processed = 0;
        const totalChannels = textChannels.size;

        if (alreadyDone.size > 0) {
            console.log(`♻️  Retomando mapeamento — ${alreadyDone.size} canal(is) já mapeado(s)`);
        }

        console.log('');
        console.log('═══════════════════════════════════════════');
        console.log('   🔄 MAPEAMENTO (RECRIAÇÃO) INICIADO');
        console.log(`   📊 Total de canais: ${totalChannels}`);
        if (alreadyDone.size > 0) {
            console.log(`   ♻️  Já mapeados: ${alreadyDone.size} (serão pulados)`);
        }
        console.log('═══════════════════════════════════════════');
        console.log('');

        // Converte para array e ordena na ordem visual do Discord (de cima para baixo)
        const channelsArray = [...textChannels.values()].sort((a, b) => {
            const catA = a.parent ? a.parent.rawPosition : -1;
            const catB = b.parent ? b.parent.rawPosition : -1;
            if (catA !== catB) return catA - catB;
            return a.rawPosition - b.rawPosition;
        });

        // Marca mapeamento como ativo
        state.isMapping = true;
        state.skipCurrent = false;
        state.currentChannel = null;

        for (let i = 0; i < channelsArray.length; i++) {
            const channel = channelsArray[i];
            processed++;

            // Atualiza estado com canal atual
            state.currentChannel = channel.name;
            state.skipCurrent = false;

            // Pula canais que já foram mapeados anteriormente
            if (alreadyDone.has(channel.name)) {
                webhookList.push({ name: channel.name, url: savedData[channel.name].url, id: channel.id });
                skipped++;
                console.log(`⏭️  Pulando canal já mapeado: #${channel.name} (${processed}/${totalChannels})`);
                continue;
            }

            try {
                // Verifica se o bot consegue ver e gerenciar webhooks neste canal
                const permissions = channel.permissionsFor(botMember);
                if (!permissions || !permissions.has(PermissionFlagsBits.ViewChannel) || !permissions.has(PermissionFlagsBits.ManageWebhooks)) {
                    console.log(`⚠️  Sem permissão no canal: #${channel.name}`);
                    webhookList.push({ name: channel.name, url: '⚠️ Sem permissão', id: channel.id });
                    errors++;
                    continue;
                }

                // 1. Buscar webhooks existentes no canal (com timeout de 15s)
                const fetchPromise = channel.fetchWebhooks();
                const timeoutPromise = new Promise((_, reject) =>
                    setTimeout(() => reject(new Error('Timeout ao buscar webhooks')), 15000)
                );

                let existingWebhooks;
                try {
                    existingWebhooks = await Promise.race([fetchPromise, timeoutPromise]);
                } catch (timeoutErr) {
                    console.warn(`⏰ Timeout em #${channel.name} — pulando`);
                    webhookList.push({ name: channel.name, url: '⏰ Timeout', id: channel.id });
                    errors++;
                    continue;
                }

                // Verifica se foi destravado
                if (state.skipCurrent) {
                    console.log(`🔓 Canal #${channel.name} pulado pelo /destravar`);
                    webhookList.push({ name: channel.name, url: '🔓 Pulado', id: channel.id });
                    errors++;
                    continue;
                }

                // 2. Filtrar e deletar TODAS as webhooks criadas por este bot
                const botWebhooks = existingWebhooks.filter(
                    (wh) => wh.owner && wh.owner.id === interaction.client.user.id
                );

                if (botWebhooks.size > 0) {
                    console.log(`🗑️  Limpando ${botWebhooks.size} webhook(s) do canal: #${channel.name}`);
                    for (const [, wh] of botWebhooks) {
                        await wh.delete('Recriação automática pelo Gerador de Webhooks');
                        deleted++;
                        await delay(300);
                    }
                }

                // Verifica se foi destravado antes de criar
                if (state.skipCurrent) {
                    console.log(`🔓 Canal #${channel.name} pulado pelo /destravar`);
                    webhookList.push({ name: channel.name, url: '🔓 Pulado', id: channel.id });
                    errors++;
                    continue;
                }

                // 3. Criar UMA nova webhook com o nome exato do canal
                console.log(`🔧 Criando webhook no canal: #${channel.name}`);

                const newWebhook = await channel.createWebhook({
                    name: channel.name,
                    avatar: webhookAvatarURL,
                    reason: 'Webhook criada automaticamente pelo Gerador de Webhooks',
                });

                webhookList.push({ name: channel.name, url: newWebhook.url, id: channel.id });
                created++;

                // Salva imediatamente no webhooks.json
                savedData[channel.name] = {
                    canalId: channel.id,
                    url: newWebhook.url,
                };
                saveWebhooks(savedData);

                console.log(`✅ Concluído canal: #${channel.name} (${processed}/${totalChannels})`);
                await delay(500);
            } catch (err) {
                if (state.skipCurrent) {
                    console.log(`🔓 Canal #${channel.name} pulado pelo /destravar`);
                    webhookList.push({ name: channel.name, url: '🔓 Pulado', id: channel.id });
                } else {
                    console.error(`❌ Erro no canal #${channel.name}:`, err.message);
                    webhookList.push({ name: channel.name, url: `❌ Erro: ${err.message}`, id: channel.id });
                }
                errors++;
            }

            // A cada 10 canais, envia progresso no Discord e atualiza a interação
            if (processed % 10 === 0 && processed < totalChannels) {
                const percent = Math.round((processed / totalChannels) * 100);
                console.log(`💾 Salvando progresso... (${processed}/${totalChannels} — ${percent}%)`);

                try {
                    await interaction.editReply(
                        `⏳ **Mapeamento em andamento...**\n\n` +
                        `📊 Progresso: **${processed}/${totalChannels}** canais (${percent}%)\n` +
                        `🔧 Criadas: ${created} | 🗑️ Deletadas: ${deleted} | ❌ Erros: ${errors}\n` +
                        `💾 webhooks.json atualizado com ${Object.keys(savedData).length} webhooks`
                    );
                } catch (_) {
                    // Token expirado — envia progresso direto no canal
                    try {
                        await commandChannel.send(
                            `⏳ **Progresso do mapeamento:** ${processed}/${totalChannels} (${percent}%) — ` +
                            `${created} criadas | ${Object.keys(savedData).length} salvas no webhooks.json`
                        );
                    } catch (__) {}
                }
            }
        }

        // Marca mapeamento como finalizado
        state.isMapping = false;
        state.currentChannel = null;
        state.skipCurrent = false;

        console.log('');
        console.log('═══════════════════════════════════════════');
        console.log('   ✅ MAPEAMENTO CONCLUÍDO');
        console.log(`   🔧 Criadas: ${created}`);
        console.log(`   ⏭️  Puladas: ${skipped}`);
        console.log(`   🗑️  Deletadas: ${deleted}`);
        console.log(`   ❌ Erros: ${errors}`);
        console.log(`   💾 Salvas: ${Object.keys(savedData).length}`);
        console.log('═══════════════════════════════════════════');
        console.log('');

        // Monta a lista formatada
        const lines = webhookList.map((w) => `#${w.name} → ${w.url}`);
        const summary = `\n\n📊 **Resumo:** ${created} criadas | ${skipped} puladas | ${deleted} deletadas | ${errors} erros | ${webhookList.length} total\n💾 Arquivo webhooks.json salvo com ${Object.keys(savedData).length} webhooks`;
        const fullText = lines.join('\n');

        // Tenta responder — se o token expirou (>15 min), envia direto no canal
        try {
            const messageContent = `✅ **Mapeamento concluído!**\n\n\`\`\`\n${fullText}\n\`\`\`${summary}`;

            if (messageContent.length <= 2000) {
                await interaction.editReply(messageContent);
            } else {
                const fileContent = `GERADOR DE WEBHOOKS - LISTA COMPLETA\n${'='.repeat(50)}\n\n${fullText}\n\n${'='.repeat(50)}\nCriadas: ${created} | Deletadas: ${deleted} | Erros: ${errors} | Total: ${webhookList.length}\nSalvas em webhooks.json: ${Object.keys(savedData).length}`;
                const buffer = Buffer.from(fileContent, 'utf-8');
                const attachment = new AttachmentBuilder(buffer, { name: 'webhooks.txt' });

                await interaction.editReply({
                    content: `✅ **Mapeamento concluído!**${summary}\n\n📎 A lista completa foi enviada como arquivo anexo.`,
                    files: [attachment],
                });
            }
        } catch (replyErr) {
            console.warn('⚠️  Token de interação expirado. Enviando resultado direto no canal...');

            const fileContent = `GERADOR DE WEBHOOKS - LISTA COMPLETA\n${'='.repeat(50)}\n\n${fullText}\n\n${'='.repeat(50)}\nCriadas: ${created} | Deletadas: ${deleted} | Erros: ${errors} | Total: ${webhookList.length}\nSalvas em webhooks.json: ${Object.keys(savedData).length}`;
            const buffer = Buffer.from(fileContent, 'utf-8');
            const attachment = new AttachmentBuilder(buffer, { name: 'webhooks.txt' });

            await commandChannel.send({
                content: `✅ **Mapeamento concluído!**${summary}\n\n📎 A lista completa foi enviada como arquivo anexo.`,
                files: [attachment],
            });
        }
    },
};
