const soma = (x,y) =>{
    if (typeof x !== 'number' || typeof y !== 'number') throw new Error("x e y precisam ser números");        
    return x + y;
}

try {
// Executada quando não há erros
    for (let index = 0; index < 2; index++) console.log(index);   

    console.log(soma(5,'2'));    
} catch (error) {
// Executada quando há erros    
    console.log(error);
} finally {
// Executada sempre  (Opcional)
    console.log('Bloco de instrução Finalizado')
}