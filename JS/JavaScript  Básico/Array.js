/*
    Array em js é um objeto
*/

const alunos = ['Pessoa1','Pessoa2','Pessoa3'];
console.log(alunos);

/* Adicionar item no começo */
alunos.unshift('PessoaA')

/* Remove item no começo */
alunos.shift()

/* Adicionar item no fim */
alunos.push('PessoaZ')

/* Remove item do fim (retorna oque foi removido) */
const valor = alunos.pop()

/* Selecionar um intervalo (os dois primeiros) */
console.log(alunos.slice(0,2))

/* Selecionar um intervalo (tudo menos os dois ultimos) */
console.log(alunos.slice(0,-2))



/* Apagar os dados de um indice */
delete alunos[2]
console.log(alunos)

console.log(typeof alunos) // objeto
console.log(alunos instanceof Array) // objeto de array