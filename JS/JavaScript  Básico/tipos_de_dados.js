/*
Primitivos (imutáveis) - string, number, boolean, undefined, null, bigint, symbool - VALORES COPIADOS

Referência (mutável) - array, object, function - PASSADOS POR REFERENCIA
*/

// PRIMITIVO       
let nome = 'nome'
console.log(nome[0])
nome[0] = 'A' // o valor da string é imutavel
console.log(nome)

// REFERENCIA
let a = [1,2,3]
let b = a // recebe a posição do valor na MEMORIA e nao o valor
console.log(a,b)

// oque for alterado na referencia, vai ser alterado no outro
a.push(4);
console.log(a,b)
b.pop()
console.log(a,b)


let z = [7,8,9];
let x = [...z] // Cópia de valores ao inves da referencia
let y = x // copia de referencia

console.log(z,x,y)
x.pop()
console.log(z,x,y)