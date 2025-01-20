// Array em js é um objeto

const alunos = ['Pessoa1','Pessoa2','Pessoa3'];
console.log(alunos, '\n');

alunos.unshift('PessoaA');   // Adicionar item no começo
alunos.shift();              // Remove item no começo
alunos.push('PessoaZ');      // Adicionar item no fim 

const valor = alunos.pop();         // Remove item do fim (retorna oque foi removido)
const inicio2 = alunos.slice(0,2);  // Selecionar um intervalo (os dois primeiros)
const tudo_2 = alunos.slice(0,-2);  // Selecionar um intervalo (tudo menos os dois ultimos)
const fim2 = alunos.slice(-2);     // Selecionar um intervalo (os dois ultimos)

console.log('os dois primeiros',inicio2);
console.log('tudo menos 2',     tudo_2);   
console.log('os dois ultimos',  fim2,'\n');           

delete alunos[2] // Apagar os dados de um indice
console.log(alunos)

console.log(typeof alunos) // objeto
console.log(alunos instanceof Array, '\n') // objeto de array

const data = new Date();
// Criação de uma lista ordenada
const listaData = [
    data.getDate(),         // Dia
    data.getMonth() + 1,    // Mês (adicionamos +1 porque começa em 0)
    data.getFullYear(),     // Ano
    data.getHours(),        // Hora
    data.getMinutes(),      // Minutos
    data.getSeconds(),      // Segundos
    data.getMilliseconds()  // Milissegundos
];
listaData.push(data.getDay()); // Dia da semana (0 = Domingo, 6 = Sábado)

// Acessando elementos da lista por índice
console.log('Lista:', listaData,'\n')
console.log(
    `Dia: ${listaData[0]}\n` +
    `Dia da semana: ${listaData[7]}`
);




