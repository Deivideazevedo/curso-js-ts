// As funções podem usar varaiveis foram do seu escopo (escopo lexico)
const nome = 'Davi';

function falaNome(){
    // const nome = 'Copper'
    console.log(nome);
}

falaNome()