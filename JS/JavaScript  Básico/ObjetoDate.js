// const data = new Date('2025-01-16 17:13:00');
const data = new Date();
const dataFormata = data.toLocaleString("pt-BR").replace(",","")
console.log(dataFormata)

console.log('Dia', data.getDate());
console.log('Mês', data.getMonth() + 1);
console.log('Ano', data.getFullYear());
console.log('Hora', data.getHours());
console.log('Minuto', data.getMinutes());
console.log('Segundo', data.getSeconds());
console.log('Milisegundo', data.getMilliseconds());
console.log('Dia da semana', data.getDay());
console.log(data.toString());


