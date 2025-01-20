// const h1 = document.querySelector(".container h1")
// const data = new Date();

// const formatarNumero = (numero) => (numero < 10 ? `0${numero}` : numero);

// function diaDaSemana(diaSemana) {
//     let diaSemanaTexto = '';
//     switch (diaSemana) {
//         case 0:
//             diaSemanaTexto = 'Domingo'
//             break;
//         case 1:
//             diaSemanaTexto = 'Segunda-Feira'
//             break;
//         case 2:
//             diaSemanaTexto = 'Terça-Feira'
//             break;
//         case 3:
//             diaSemanaTexto = 'Quarta-Feira'
//             break;
//         case 4:
//             diaSemanaTexto = 'Quinta-Feira'
//             break;        
//         case 5:
//             diaSemanaTexto = 'Sexta-Feira'
//             break;                    
//         case 6:
//             diaSemanaTexto = 'Sabádo'
//             break;          
//         default:
//         diaSemanaTexto = ''
//             break;     
//     }
    
//     return diaSemanaTexto;
// }
// function nomeDoMes(data) {
//     let nomeMes = '';
//     switch (data.getMonth() + 1) {
//         case 1:
//             nomeMes = 'Janeiro'
//             break;
//         case 1:
//             nomeMes = 'Fevereiro'
//             break;
//         case 2:
//             nomeMes = 'Março'
//             break;
//         case 3:
//             nomeMes = 'Abril'
//             break;
//         case 4:
//             nomeMes = 'Maio'
//             break;        
//         case 5:
//             nomeMes = 'Junho'
//             break;                    
//         case 6:
//             nomeMes = 'Julho'
//             break;  
//         case 7:
//             nomeMes = 'Agosto'
//              break;   
//         case 8:
//             nomeMes = 'Setembro'
//             break;     
//         case 9:
//             nomeMes = 'Outubro'
//             break;  
//         case 11:
//             nomeMes = 'Novembro'
//             break;      
//         case 12:
//             nomeMes = 'Dezembro'
//             break;           
//         default:
//             nomeMes = ''
//             break;     
//     }

//     return nomeMes;
// }

// function criarData(data) {
    
//     const diaSemana = data.getDay();
//     const nomeDia = diaDaSemana(diaSemana);
//     const dia = data.getDate();
//     const Mes = nomeDoMes(data);
//     const ano = data.getFullYear();
//     const hora = data.getHours();
//     const minutos = data.getMinutes();

//     return (
//     `${nomeDia}, ${dia} de ${Mes} de ${ano} às ` +
//     `${formatarNumero(hora)}:${formatarNumero(minutos)}`
//     );
    
// }

// h1.innerHTML = criarData(data)

const data = new Date();
const h1 = document.querySelector(".container h1")
function atualizarHora() {
  const data = new Date();
  const opcoes = { dateStyle: 'full', timeStyle: 'medium' };
  h1.innerHTML = data.toLocaleString('pt-BR', opcoes);
}

 // Atualiza a cada 1 segundo (1000 milissegundos)
setInterval(atualizarHora,1000)
// full,long,medium,short
atualizarHora();

const opcoesDetalhadas = {
  weekday: 'long', // Exibe o dia da semana
  year: 'numeric', // Exibe o ano
  month: 'long',   // Exibe o mês por extenso (long/short/numeric)
  day: 'numeric',  // Exibe o dia
  hour: 'numeric', // Exibe a hora
  minute: 'numeric', // Exibe os minutos
  second: 'numeric'  // Exibe os segundos
};
console.log(new Date().toLocaleString('pt-BR', opcoesDetalhadas));