const { SlashCommandBuilder, PermissionFlagsBits, PermissionsBitField, ChannelType } = require('discord.js');
const { webhookAvatarURL } = require('../config');
const fs = require('fs');
const path = require('path');

const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

const SAVE_PATH = path.join(__dirname, '..', 'webhooks.json');

function saveWebhooks(data) {
    fs.writeFileSync(SAVE_PATH, JSON.stringify(data, null, 2), 'utf-8');
}

// ═══════════════════════════════════════════
//   ESTRUTURA DE CARGOS
// ═══════════════════════════════════════════

const ROLES = [
    {
        name: '👑 Owner',
        color: 0xFFD700,
        permissions: new PermissionsBitField(PermissionsBitField.Flags.Administrator),
        hoist: true,
        mentionable: false,
    },
    {
        name: '🛡️ Adm',
        color: 0xE74C3C,
        permissions: new PermissionsBitField([
            PermissionsBitField.Flags.ManageGuild,
            PermissionsBitField.Flags.ManageChannels,
            PermissionsBitField.Flags.ManageRoles,
            PermissionsBitField.Flags.ManageMessages,
            PermissionsBitField.Flags.ManageWebhooks,
            PermissionsBitField.Flags.ManageNicknames,
            PermissionsBitField.Flags.KickMembers,
            PermissionsBitField.Flags.BanMembers,
            PermissionsBitField.Flags.ViewAuditLog,
            PermissionsBitField.Flags.MentionEveryone,
            PermissionsBitField.Flags.ViewChannel,
            PermissionsBitField.Flags.SendMessages,
            PermissionsBitField.Flags.ReadMessageHistory,
            PermissionsBitField.Flags.EmbedLinks,
            PermissionsBitField.Flags.AttachFiles,
            PermissionsBitField.Flags.UseExternalEmojis,
            PermissionsBitField.Flags.Connect,
            PermissionsBitField.Flags.Speak,
            PermissionsBitField.Flags.MuteMembers,
            PermissionsBitField.Flags.DeafenMembers,
            PermissionsBitField.Flags.MoveMembers,
        ]),
        hoist: true,
        mentionable: false,
    },
    {
        name: '🔰 Suporte',
        color: 0x2ECC71,
        permissions: new PermissionsBitField([
            PermissionsBitField.Flags.ViewChannel,
            PermissionsBitField.Flags.SendMessages,
            PermissionsBitField.Flags.ReadMessageHistory,
            PermissionsBitField.Flags.ManageMessages,
            PermissionsBitField.Flags.KickMembers,
            PermissionsBitField.Flags.ManageNicknames,
            PermissionsBitField.Flags.ViewAuditLog,
            PermissionsBitField.Flags.MuteMembers,
            PermissionsBitField.Flags.DeafenMembers,
            PermissionsBitField.Flags.MoveMembers,
            PermissionsBitField.Flags.EmbedLinks,
            PermissionsBitField.Flags.AttachFiles,
            PermissionsBitField.Flags.UseExternalEmojis,
            PermissionsBitField.Flags.Connect,
            PermissionsBitField.Flags.Speak,
        ]),
        hoist: true,
        mentionable: false,
    },
    {
        name: '🤖 Maquinas',
        color: 0x3498DB,
        permissions: new PermissionsBitField(PermissionsBitField.Flags.Administrator),
        hoist: false,
        mentionable: false,
    },
];

// ═══════════════════════════════════════════
//   ESTRUTURA DE CANAIS
// ═══════════════════════════════════════════

const SERVER_STRUCTURE = [
    {
        category: '🔐 Conexão / Sistema',
        channels: ['🔑-login', '🆑-cl', '🖥️-registros', '📋-logs-geral'],
    },
    {
        category: '👮 Administração / Staff',
        channels: ['🛡️-admin', '🔰-staff', '🥾-kick', '🔴-ban', '🚫-ban-thunder', '🟢-desban', '❗-suspeito', '🎥-freecam', '🧱-wall', '🛠️-fix'],
    },
    {
        category: '💰 Economia',
        channels: ['💵-money', '💰-salary', '💰-dinheiro', '🪙-coins', '💎-gemstone', '🔹-gemas'],
    },
    {
        category: '🎒 Inventário / Itens',
        channels: ['📦-item', '📦-give', '📤-dropar-item', 'ℹ️-dropar-item', '📦-bau'],
    },
    {
        category: '🚗 Veículos',
        channels: ['🚗-addcar', '🚗-remcar', '🚗-car', '🚗-carro', '🚗-veiculo', '🚗-veiculos', '🚗-dv', '🏪-garage'],
    },
    {
        category: '⚔️ Combate / Morte',
        channels: ['⚰️-kill', '💀-kill'],
    },
    {
        category: '🚔 Polícia / Legal',
        channels: ['🚔-police', '💸-multar', '🚨-prisao', '⛓️-detido', '📚-apreender', '📝-ocorrências', '📋-prontuario'],
    },
    {
        category: '💀 Ilegal',
        channels: ['💲-roubos', '💀-ilegal-geral', '🔫-garmas'],
    },
    {
        category: '🏠 Propriedades / Baús',
        channels: ['🏠-homes', '🏠-baú-casas', '🚓-baú-policias', '🕵️-baú-facções', '🚗-baú-veículos', '🏥-baú-hospital', '🔧-baú-mecanica', '💀-baú-orgs-ilegais'],
    },
    {
        category: '📱 Celular',
        channels: ['📱-messages', '📱-chamadas', '📱-instapic', '📱-birdy', '📱-darkchat', '📱-crypto', '📱-uploads'],
    },
    {
        category: '🛒 Lojas / Sistema',
        channels: ['🛒-shop', '🏬-loja-em-gamer', '🏬-lojacoin-em-gamer', '💴-vendas-in-game'],
    },
    {
        category: '⚙️ Diversos',
        channels: ['🧑‍🔧-mec', '🩺-paramedico', '⛽-posto-de-gas', '🕒-bate-ponto', '🕒-ponto-staff'],
    },
];

module.exports = {
    data: new SlashCommandBuilder()
        .setName('gerar_servidor')
        .setDescription('Deleta tudo e recria o servidor com a estrutura padrão + webhooks')
        .setDefaultMemberPermissions(PermissionFlagsBits.Administrator)
        .addStringOption((option) =>
            option
                .setName('confirmar')
                .setDescription('Digite CONFIRMAR para executar (isso apaga TUDO)')
                .setRequired(true)
        ),

    async execute(interaction) {
        const confirmacao = interaction.options.getString('confirmar');

        if (confirmacao !== 'CONFIRMAR') {
            return interaction.reply({
                content: '❌ Você precisa digitar exatamente `CONFIRMAR` para executar este comando.\n⚠️ **ATENÇÃO:** Isso vai deletar TODOS os canais e cargos do servidor e recriar do zero!',
                flags: 64,
            });
        }

        // deferReply IMEDIATO (tem 3s pra responder)
        try {
            await interaction.deferReply();
        } catch (_) {}

        const guild = interaction.guild;
        const botMember = guild.members.me;
        const botHighestRole = botMember.roles.highest;
        const savedData = {};

        // Função para enviar progresso de forma segura
        let statusChannelId = null;
        const sendProgress = async (msg) => {
            try { await interaction.editReply(msg); return; } catch (_) {}
            if (statusChannelId) {
                try {
                    const ch = guild.channels.cache.get(statusChannelId);
                    if (ch) { await ch.send(msg); return; }
                } catch (_) {}
            }
            console.log('[PROGRESSO]', msg.replace(/\*\*/g, '').replace(/\n/g, ' | '));
        };

        console.log('');
        console.log('═══════════════════════════════════════════');
        console.log('   🏗️  GERAÇÃO DE SERVIDOR INICIADA');
        console.log('═══════════════════════════════════════════');
        console.log('');

        // ═══════════════════════════════════════════
        //   FASE 1: DELETAR CARGOS EXISTENTES
        // ═══════════════════════════════════════════

        console.log('🗑️  FASE 1: Deletando cargos existentes...');
        await sendProgress('🗑️ **Fase 1/4** — Deletando cargos existentes...');

        await guild.roles.fetch();
        const existingRoles = guild.roles.cache.filter(
            (role) => !role.managed && role.id !== guild.id && role.position < botHighestRole.position
        );

        let rolesDeleted = 0;
        let rolesErrors = 0;

        for (const [, role] of existingRoles) {
            try {
                await role.delete('Recriação do servidor');
                rolesDeleted++;
                console.log(`   🗑️  Cargo deletado: ${role.name}`);
                await delay(500);
            } catch (err) {
                rolesErrors++;
                console.error(`   ❌ Erro ao deletar cargo ${role.name}: ${err.message}`);
            }
        }

        console.log(`   ✅ Cargos: ${rolesDeleted} deletados | ${rolesErrors} erros\n`);

        // ═══════════════════════════════════════════
        //   FASE 2: CRIAR NOVOS CARGOS
        // ═══════════════════════════════════════════

        console.log('🏷️  FASE 2: Criando novos cargos...');
        await sendProgress('🏷️ **Fase 2/4** — Criando cargos (Owner, Adm, Suporte, Maquinas)...');

        const createdRoles = {};

        for (let i = ROLES.length - 1; i >= 0; i--) {
            const roleDef = ROLES[i];
            try {
                const newRole = await guild.roles.create({
                    name: roleDef.name,
                    color: roleDef.color,
                    permissions: roleDef.permissions,
                    hoist: roleDef.hoist,
                    mentionable: roleDef.mentionable,
                    reason: 'Geração automática do servidor',
                });
                createdRoles[roleDef.name] = newRole;
                console.log(`   ✅ Cargo criado: ${roleDef.name} (${newRole.id})`);
                await delay(500);
            } catch (err) {
                console.error(`   ❌ Erro ao criar cargo ${roleDef.name}: ${err.message}`);
            }
        }

        // Posicionar hierarquia
        try {
            const positions = [];
            const basePosition = botHighestRole.position - 1;
            ROLES.forEach((roleDef, index) => {
                const role = createdRoles[roleDef.name];
                if (role) positions.push({ role: role.id, position: Math.max(1, basePosition - index) });
            });
            if (positions.length > 0) {
                await guild.roles.setPositions(positions);
                console.log('   📊 Hierarquia posicionada');
            }
        } catch (err) {
            console.error(`   ⚠️  Erro ao posicionar cargos: ${err.message}`);
        }

        console.log('');

        // ═══════════════════════════════════════════
        //   FASE 3: DELETAR TODOS OS CANAIS
        // ═══════════════════════════════════════════

        console.log('🗑️  FASE 3: Deletando todos os canais...');
        await sendProgress('🗑️ **Fase 3/4** — Deletando todos os canais existentes...');

        await guild.channels.fetch();

        // Separa canais normais e categorias para deletar na ordem certa
        const normalChannels = [];
        const categories = [];
        for (const [, ch] of guild.channels.cache) {
            if (ch.type === ChannelType.GuildCategory) {
                categories.push(ch);
            } else {
                normalChannels.push(ch);
            }
        }

        let channelsDeleted = 0;
        let channelsErrors = 0;

        // Deletar canais normais primeiro
        for (const channel of normalChannels) {
            try {
                await channel.delete('Recriação do servidor');
                channelsDeleted++;
                console.log(`   🗑️  Canal deletado: #${channel.name}`);
                await delay(500);
            } catch (err) {
                channelsErrors++;
                console.error(`   ❌ Erro ao deletar #${channel.name}: ${err.message}`);
            }
        }

        // Depois deletar categorias
        for (const cat of categories) {
            try {
                await cat.delete('Recriação do servidor');
                channelsDeleted++;
                console.log(`   🗑️  Categoria deletada: ${cat.name}`);
                await delay(500);
            } catch (err) {
                channelsErrors++;
                console.error(`   ❌ Erro ao deletar categoria ${cat.name}: ${err.message}`);
            }
        }

        console.log(`   ✅ Canais: ${channelsDeleted} deletados | ${channelsErrors} erros\n`);

        // ═══════════════════════════════════════════
        //   FASE 4: CRIAR ESTRUTURA NOVA
        // ═══════════════════════════════════════════

        console.log('🏗️  FASE 4: Criando nova estrutura de canais + webhooks...');

        // Criar canal de status DEPOIS de deletar tudo
        try {
            const statusCh = await guild.channels.create({
                name: '📊-status-geração',
                type: ChannelType.GuildText,
                reason: 'Canal temporário para progresso',
            });
            statusChannelId = statusCh.id;
            await statusCh.send('🏗️ **Fase 4/4** — Criando nova estrutura de canais e webhooks...');
            console.log('   📊 Canal de status criado');
            await delay(500);
        } catch (err) {
            console.error(`   ⚠️  Canal de status não criado: ${err.message}`);
        }

        let categoriesCreated = 0;
        let channelsCreated = 0;
        let webhooksCreated = 0;
        let structureErrors = 0;
        const totalCategories = SERVER_STRUCTURE.length;
        const totalChannelsToCreate = SERVER_STRUCTURE.reduce((sum, cat) => sum + cat.channels.length, 0);

        for (let catIndex = 0; catIndex < SERVER_STRUCTURE.length; catIndex++) {
            const section = SERVER_STRUCTURE[catIndex];

            // Criar categoria
            let category = null;
            try {
                category = await guild.channels.create({
                    name: section.category,
                    type: ChannelType.GuildCategory,
                    reason: 'Geração automática do servidor',
                });
                categoriesCreated++;
                console.log(`📁 Categoria criada: ${section.category}`);
                await delay(1000);
            } catch (err) {
                console.error(`❌ Erro ao criar categoria ${section.category}: ${err.message}`);
                structureErrors++;
                if (err.status === 429) {
                    console.log('   ⏳ Rate limit — esperando 10s...');
                    await delay(10000);
                }
                continue;
            }

            // Criar canais dentro da categoria
            for (let chIndex = 0; chIndex < section.channels.length; chIndex++) {
                const channelName = section.channels[chIndex];

                try {
                    const newChannel = await guild.channels.create({
                        name: channelName,
                        type: ChannelType.GuildText,
                        parent: category.id,
                        reason: 'Geração automática do servidor',
                    });
                    channelsCreated++;
                    console.log(`   📝 Canal criado: #${newChannel.name}`);
                    await delay(1000);

                    // Criar webhook
                    try {
                        const webhook = await newChannel.createWebhook({
                            name: newChannel.name,
                            avatar: webhookAvatarURL,
                            reason: 'Webhook automática na geração do servidor',
                        });

                        savedData[newChannel.name] = {
                            canalId: newChannel.id,
                            url: webhook.url,
                        };
                        webhooksCreated++;
                        saveWebhooks(savedData);
                        console.log(`   🔗 Webhook criada: #${newChannel.name}`);
                        await delay(1000);
                    } catch (whErr) {
                        console.error(`   ⚠️  Erro webhook #${newChannel.name}: ${whErr.message}`);
                        if (whErr.status === 429) {
                            console.log('   ⏳ Rate limit — esperando 10s...');
                            await delay(10000);
                        }
                    }
                } catch (err) {
                    console.error(`   ❌ Erro ao criar canal ${channelName}: ${err.message}`);
                    structureErrors++;
                    if (err.status === 429) {
                        console.log('   ⏳ Rate limit — esperando 10s...');
                        await delay(10000);
                    }
                }
            }

            // Progresso a cada categoria
            const percent = Math.round(((catIndex + 1) / totalCategories) * 100);
            console.log(`   📊 Progresso: ${catIndex + 1}/${totalCategories} categorias (${percent}%)`);

            await sendProgress(
                `📊 **Progresso:** ${catIndex + 1}/${totalCategories} categorias (${percent}%)\n` +
                `📝 Canais: ${channelsCreated}/${totalChannelsToCreate} | 🔗 Webhooks: ${webhooksCreated} | ❌ Erros: ${structureErrors}`
            );
        }

        console.log('');
        console.log('═══════════════════════════════════════════');
        console.log('   ✅ GERAÇÃO DO SERVIDOR CONCLUÍDA');
        console.log(`   🗑️  Cargos deletados: ${rolesDeleted}`);
        console.log(`   🏷️  Cargos criados: ${Object.keys(createdRoles).length}`);
        console.log(`   🗑️  Canais deletados: ${channelsDeleted}`);
        console.log(`   📁 Categorias criadas: ${categoriesCreated}`);
        console.log(`   📝 Canais criados: ${channelsCreated}`);
        console.log(`   🔗 Webhooks criadas: ${webhooksCreated}`);
        console.log(`   ❌ Erros: ${structureErrors}`);
        console.log(`   💾 webhooks.json: ${Object.keys(savedData).length} webhooks`);
        console.log('═══════════════════════════════════════════');
        console.log('');

        const resumo =
            `✅ **SERVIDOR GERADO COM SUCESSO!**\n\n` +
            `🗑️ Cargos deletados: **${rolesDeleted}**\n` +
            `🏷️ Cargos criados: **${Object.keys(createdRoles).length}** (👑 Owner, 🛡️ Adm, 🔰 Suporte, 🤖 Maquinas)\n` +
            `🗑️ Canais antigos deletados: **${channelsDeleted}**\n` +
            `📁 Categorias criadas: **${categoriesCreated}**\n` +
            `📝 Canais criados: **${channelsCreated}**\n` +
            `🔗 Webhooks criadas: **${webhooksCreated}**\n` +
            `❌ Erros: **${structureErrors}**\n\n` +
            `💾 Arquivo \`webhooks.json\` salvo com **${Object.keys(savedData).length}** webhooks.`;

        await sendProgress(resumo);

        // Deleta o canal de status após 30s
        if (statusChannelId) {
            try {
                await delay(30000);
                const ch = guild.channels.cache.get(statusChannelId);
                if (ch) await ch.delete('Geração concluída');
                console.log('🗑️  Canal de status deletado');
            } catch (_) {}
        }
    },
};
