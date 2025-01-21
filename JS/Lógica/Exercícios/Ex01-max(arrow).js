// Retornar o maior valor entre dois numeros

function max(x,y){
    return x > y ? x : y;
}
console.log(max(10,5));

const max2 = (x,y) => {
    return x > y ? x : y;
}
console.log(max2(5,9));

const max3 = (x,y) => x > y ? x : y;
console.log(max3(8,5));