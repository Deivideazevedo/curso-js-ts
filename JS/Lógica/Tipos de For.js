const frutas = ['Maçã', 'Pera', 'Uva'];

// FOR CLASSÍCO - Iteraiveis (ARRAYS, STRINGS)
for (let i = 0; i<frutas.length; i++){
    console.log(`indice i: ${i}`,frutas[i]);
}

console.log("###########\nFOR IN")

// FOR IN - Retorna indice ou chave (string, array ou objetos)
for (let i in frutas) {
    console.log(frutas[i])
}

const pessoa = {nome:'Deivide', sobrenome:'Alves', idade:900};
for (let chave in pessoa) {
    console.log(chave, pessoa[chave])
}

console.log("###########\nFOR OF")

// FOR OF - Retona o valor (iteráveis, arrays ou string)
const nome = 'Deivide'
for (let valor of nome) {
    console.log(valor); 
}

console.log("###########\nFOR EACH")

// FOR EACH
frutas.forEach(function(valor,indice, array) {
    console.log(valor,indice,array);
})