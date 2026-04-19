// Estado compartilhado entre comandos (em memória)
module.exports = {
    // Canal sendo processado no momento
    currentChannel: null,

    // Flag para pular o canal atual
    skipCurrent: false,

    // Flag para indicar se o mapeamento está rodando
    isMapping: false,
};
