 const inputTarefa = document.querySelector('.input-tarefa');
 const btnTarefa = document.querySelector('.btn-tarefa');
 const ulTarefas = document.querySelector('.tarefas');


 inputTarefa.addEventListener('keypress', (e) => {
    if (!inputTarefa.value) return 
    if (e.keyCode === 13) criarTarefa(inputTarefa.value);
 });

 btnTarefa.addEventListener('click', (e) => { 
    inputTarefa.focus();  
    if (!inputTarefa.value) return 
    criarTarefa(inputTarefa.value);
 });

 function limpaInput() {
    inputTarefa.value = '';
    inputTarefa.focus();
 }

 const criarTarefa = (texto) => {
    limpaInput();
    const li = document.createElement('li');
    li.innerText = texto;
    ulTarefas.appendChild(li);
    botaoApagar(li);

    salvarTarefa();
 }

 function botaoApagar(li) {
    li.innerText += " ";
    const botao = document.createElement('button');
    botao.setAttribute('class', 'apagar');
    botao.setAttribute('title', 'Apagar esta tarefa');
    botao.innerText = 'Apagar';
    li.appendChild(botao);
 }

//  Apagar tarefa
 document.addEventListener('click', (e) => {
    const elemento = e.target;
    if(elemento.classList.contains('apagar')){
        elemento.parentElement.remove();
        salvarTarefa()
    }
});

function salvarTarefa() {
    const liTarefas = ulTarefas.querySelectorAll('li')
    const listaDeTarefas = [];
    
    for(let tarefa of liTarefas) {
        const texto = tarefa.innerText.replace('Apagar','').trim();
        listaDeTarefas.push(texto);
    }
    const tarefasJSON = JSON.stringify(listaDeTarefas);

    // Salvar string JSON no navegador
    localStorage.setItem('tarefas',tarefasJSON);
}

function adicionaTarefasSalvas(){
    const tarefas = localStorage.getItem('tarefas');
    const tarefasObject = JSON.parse(tarefas); // convertendo para objeto original
    
    for(let tarefa of tarefasObject){
        criarTarefa(tarefa);
    }
}

adicionaTarefasSalvas();


//  document.addEventListener('click', function(e){
//     const el = e.target;
//     // console.log(el);
//     if (el.classList.contains('apagar')) {
//         // console.log(el.parentElement);
//         el.parentElement.remove()
//     }
//  });