 const timer = {
    'relogio': document.querySelector('#relogio'),
    'iniciar': document.querySelector('#iniciar'),
    'pausar': document.querySelector('#pausar'),
    'zerar': document.querySelector('#zerar')
 }

 const horario = (segundos) => new Date(segundos * 1000).toLocaleTimeString('pt-br', { timeZone: 'UTC' });
 let segundos = 0;
 let tempo;

 timer['iniciar'].addEventListener('click',() => {    
    timer['relogio'].classList.remove('pausar');
    
                                                
    if (!tempo) {                                  // se nao existir esse intervalo, crie
        tempo = setInterval(() => {
            segundos++;
            timer['relogio'].innerHTML = horario(segundos);
        }, 1000);
    }    
 })

 timer['pausar'].addEventListener('click',() => {
    clearInterval(tempo);                           // parando intervalo
    tempo = undefined;                              // resetando para ser criada novamente
    timer['relogio'].classList.add('pausar');
 })

 timer['zerar'].addEventListener('click',() => {
    clearInterval(tempo);                           // parando intervalo
    tempo = undefined;                              // resetando para ser criada novamente    
    segundos = 0;                                   // resetando variavel caso seja iniciado novamente.
    timer['relogio'].innerHTML = horario(segundos);
    timer['relogio'].classList.remove('pausar');
 })



const horario99 = (segundos) => {
    const horas = Math.trunc(segundos / 3600);          // Calcula as horas
    const minutos = Math.trunc((segundos % 3600) / 60); // Calcula os minutos restantes
    const seg = segundos % 60;                          // Calcula os segundos restantes

    // Formata para dois dígitos (99:59:59)
    return `${String(horas).padStart(2, '0')}:${String(minutos).padStart(2, '0')}:${String(seg).padStart(2, '0')}`;
};