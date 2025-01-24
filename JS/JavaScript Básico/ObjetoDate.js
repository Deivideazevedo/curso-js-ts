// const data = new Date('2025-01-16 17:13:00');
const data = new Date();
const dataFormata = data.toLocaleString("pt-BR").replace(",","")
console.log(dataFormata,'\n')

console.log('Dia', data.getDate());
console.log('Mês', data.getMonth() + 1);
console.log('Ano', data.getFullYear());
console.log('Hora', data.getHours());
console.log('Minuto', data.getMinutes());
console.log('Segundo', data.getSeconds());
console.log('Milisegundo', data.getMilliseconds());
console.log('Dia da semana', data.getDay());
console.log(data.toString());

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