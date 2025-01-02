const nome = 'Deivide Azevedo Rodrigues'

console.log(`Seu nome é: ${nome}`)
console.log(`A segunda letra do seu nome é: ${nome.charAt(1)}`)
console.log(`Seu nome tem ${nome.length} letras`)
console.log(`A segunda letra do seu nome é: ${nome.charAt(1)}`)
console.log(`Qual o primeiro índice da letra 'a' no seu nome? ${nome.toLowerCase().indexOf('a')}`)
console.log(`Qual o último índice da letra 'a' no seu nome? ${nome.toLowerCase().lastIndexOf('a')}`)
console.log(`As últimas 3 letras do seu nome são: ${nome.slice(-3)}`)
console.log(`As palavras do seu nome são: ${nome.split(' ')}`)
console.log(`Seu nome com letras maiúsculas: ${nome.toUpperCase()}`)
console.log(`Seu nome com letras minúsculas: ${nome.toLowerCase()}`)
console.log(`Trocando o primeiro d por X: ${nome.replace(/d/,'X')}`)
console.log(`Trocando todos d por X: ${nome.replace(/d/g,'X')}`)
console.log(`Trocando o primeiro d/D por X: ${nome.replace(/d/i,'X')}`)
console.log(`Trocando todos d/D por X: ${nome.replace(/d/ig,'X')}`)
/*//--
document.body.innerHTML += ` <br />`;
document.body.innerHTML += ` <br />`;
document.body.innerHTML += ` <br />`;
document.body.innerHTML += ` <br />`;
document.body.innerHTML += ` <br />`;
document.body.innerHTML += ` ______<br />`;
document.body.innerHTML += ` ______<br />`;
document.body.innerHTML += ` ______<br />`;
*/
