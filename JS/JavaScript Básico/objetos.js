const pessoa1 = {
    //ATRIBUTOS DO OBJETO
    nome: 'Luiz',
    sobrenome: 'santos',
    idade: 25,

    // METODO
    fala() {
        console.log(`A idade atual é ${this.idade}`);
    },
    incrementaIdade(){
        this.idade++;
    }
}; 
console.log(pessoa1)
pessoa1.fala()
pessoa1.incrementaIdade()
pessoa1.fala()

// CRIANDO VARIOS OBJETOS
function criaPessoa (nome, sobrenome, idade) {
    return {
        nome: nome,
        sobrenome: sobrenome,
        idade: idade
    };
}
const pessoaA = criaPessoa('lara','almeida',20)
const pessoaB = criaPessoa('milena','silva',21)
console.log(pessoaA)
console.log(pessoaB)