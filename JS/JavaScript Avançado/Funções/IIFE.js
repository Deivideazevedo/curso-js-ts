/*
Uma IIFE (Immediately Invoked Function Expression) 
é uma função é definida e executada imediatamente após sua criação.
Possui encapsulamento de escopo (variaveis nao sao compartilhadas com o global)
*/

(function() {
    const nome = 'Davi'
    console.log(nome);
})();