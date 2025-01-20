// const data = new Date('2025-01-16 17:13:00');
const data = new Date();
const dataFormata = data.toLocaleString("pt-BR").replace(",","")
console.log('Data formata:',dataFormata);

console.log("==================================\n");
const opcoesDetalhadas = {
    weekday: 'long', // Exibe o dia da semana
    year: 'numeric', // Exibe o ano
    month: 'long',   // Exibe o mês por extenso (long/short/numeric)
    day: 'numeric',  // Exibe o dia
    hour: 'numeric', // Exibe a hora
    minute: 'numeric', // Exibe os minutos
    second: 'numeric'  // Exibe os segundos
};
console.log('Data completa:',new Date().toLocaleString('pt-BR', opcoesDetalhadas));

console.log("==================================\n");

const dictData =  {
    'Dia':          data.getDate(),
    'Mes':          data.getMonth() + 1,
    'Ano':          data.getFullYear(),
    'Hora':         data.getHours(),
    'Minuto':       data.getMinutes(),
    'Segundo':      data.getSeconds(),
    'Milisegundo':  data.getMilliseconds()
};
dictData['Semana'] = data.getDay(); //Adicionando uma nova chave

//Acessando dicionarios
console.log(
    'Dicionario:', dictData,'\n\n',
    'Dia:',dictData['Dia'],'\n',
    'Mes:',dictData.Mes
);
console.log("==================================\n");

// Criação de uma lista ordenada
const listaData = [
    data.getDate(),         // Dia
    data.getMonth() + 1,    // Mês (adicionamos +1 porque começa em 0)
    data.getFullYear(),     // Ano
    data.getHours(),        // Hora
    data.getMinutes(),      // Minutos
    data.getSeconds(),      // Segundos
    data.getMilliseconds()  // Milissegundos
];
listaData.push(data.getDay()); // Dia da semana (0 = Domingo, 6 = Sábado)

// Acessando elementos da lista por índice
console.log(
    'Lista:', listaData,'\n\n',
    'Dia:', listaData[0],'\n',
    'Dia da semana:', listaData[7]
);




