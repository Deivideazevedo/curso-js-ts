// Primeiro tipo
function soma(x,y) {
    const resultado = x + y;
    return resultado;
}
console.log(soma(1,2))

// com valores default para x e y
function soma(x = 1,y = 1) {
    const resultado = x + y;
    return resultado;
}
console.log(soma(4))

// com constantes
const raiz = function (numero) {
    return numero ** 0.5
}
console.log(raiz(4))

// Arrow function
const raiz2 = (numero) => {
    return numero ** 0.5
}
console.log(raiz(16))

// Arrow function de uma linha
const raiz3 = numero => numero ** 0.5
console.log(raiz3(9))

// Função anônima
const intervalo = setInterval( function() {
    console.log('Pritando a cada 1 segundo')
}, 1000);

// Arrow function anônima
setTimeout(() => {
    clearInterval(intervalo) ;
    console.log('Encerrado após 5 segundos')
 }, 5000);