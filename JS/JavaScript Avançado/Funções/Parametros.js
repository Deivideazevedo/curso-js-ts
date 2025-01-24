// Ao definir uma funcao com function, é possivel usar os arguments
function funcao(a,b,c) {
    console.log(arguments);
    console.log(arguments[0]);
    console.log(a,b,c);
}
funcao(1,2,3,4,5,6,7)

// nao gera erro com a + ou - parametros
function funcao2(a,b,c,d,e) {
    console.log('Função2:',a,b,c,d,e);
}
funcao2(1,2,3)


// valor padrao no parametro
function funcao3(a,b = 5) {
    console.log('Função3:',a + b);
}
funcao3(1)

// passando como undefined, ele pega o valor padrao
function funcao4(a,b = 1, c = 1) {
    console.log('Função4:',a + b + c);
}

funcao4(1,undefined,2)