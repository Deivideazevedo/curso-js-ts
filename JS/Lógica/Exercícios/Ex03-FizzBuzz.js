/*
    Função que recebe um numero e retorna:
    Divisivel por:
        3 = Fizz
        5 = Buzz
        3 e 5 = FizzBuzz
        !3 e !5 = Retorna o proprio número
    Checar se é um número: se nao for, retornar o numero
    Usar função com números de 0 a 100
*/

const fizzBuzz = (x) => {
    if (typeof x != 'number') return x;
    if (!(x >= 0 && x <= 100)) return 'Use valor de 0 a 100';
    if (x % 3 == 0 && x % 5 == 0) return 'FizzBuzz';
    if (!(x % 3 == 0) && !(x % 5 == 0)) return x;
    if (x % 3 == 0) return 'Fizz';
    if (x % 5 == 0) return 'Buzz';    
}
// Exercício Real do Fizz
for (let i = 1; i < 102; i++){
    console.log(i,fizzBuzz(i));
}



/*
// Exercício Real do FizzBuzz
for (let i = 1; i < 101; i++){
    if (i % 3 == 0 && i % 5 == 0) {
        console.log('FizzBuzz',i);
    }else if (i % 3 == 0) {
        console.log('Fizz',i)
    }else if (i % 5 == 0) {
        console.log('Buzz',i)
    }
}
*/
