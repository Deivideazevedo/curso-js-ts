const retornaHora = () => new Date().toLocaleTimeString('pt-BR');


// setInterval executa o procedimento a cada intervalo definido
const intervalo = setInterval(() => console.log(retornaHora()), 1000);

// setTimeout executa uma vez após o invervalo definido
setTimeout(() => {
    clearInterval(intervalo) 
    console.log('Encerrado após 5 segundos')
},5000)