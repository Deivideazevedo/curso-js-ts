// const data = new Date('2025-01-16 17:13:00');
const data = new Date();

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




