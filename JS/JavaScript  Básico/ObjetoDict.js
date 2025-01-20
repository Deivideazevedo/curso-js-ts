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


const pessoa = {
    nome: 'Luiz',
    sobrenome: 'Miranda',
    idade: 30,
    endereco: {
        rua: 'av brasil',
        numero: 320
    }
};

console.log ('\n',pessoa)

// atribuição via desestruturação
const {nome, sobrenome, ...resto} = pessoa;
console.log(nome,sobrenome, resto,'\n')

const { endereco: {rua, numero}, endereco } = pessoa;
console.log(rua,numero, pessoa)

