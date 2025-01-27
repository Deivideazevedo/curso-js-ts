// closures ocorrem quando uma função é definida dentro de outra função
function falaFrase(comeco){
    function falaResto(resto) {
        return comeco + ' ' + resto;        
    }
    return falaResto
}

const funcaoFalaResto = falaFrase('Olá')
const olaMundo = funcaoFalaResto('Mundo')
console.log(funcaoFalaResto);
console.log(olaMundo);

console.log('###################');

// Explciação
function duplicaFunction (n){ return n * 2};
function triplicaFunction (n){ return n * 3};
function quadruplicaFunction (n){ return n * 4};

console.log(duplicaFunction(2));
console.log(triplicaFunction(2));
console.log(quadruplicaFunction(2));
// há repetição, então é possivel de fazer um closure

console.log('###################');

function criaMutiplicador(multiplicador){    
    return (n) => n * multiplicador;
}

const duplica = criaMutiplicador(2);
const triplica = criaMutiplicador(3);
const quadruplica = criaMutiplicador(4);

console.log(duplica(8))
console.log(triplica(4))
console.log(quadruplica(2))

