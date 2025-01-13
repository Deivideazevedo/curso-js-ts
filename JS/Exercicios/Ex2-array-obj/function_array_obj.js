function escopo (){
    const form = document.querySelector('.form');
    const resultado = document.querySelector('.resultado')
    
    // form.onsubmit = function (evento) {
    //     
    //     alert(1);
    //     console.log("Enviado");
    // }

    form.addEventListener('submit', getmyfunction);
    const pessoas = []

    function getmyfunction (evento){
        evento.preventDefault();
        const Nome = form.querySelector('.nome')
        const Sobrenome = form.querySelector('.sobrenome')
        const Peso = form.querySelector('.peso')
        const Altura = form.querySelector('.altura')

        // o push retorna o tamanho do array, sempre que executar o i será -1*
        let i = -1
        i += pessoas.push ({
            Nome: Nome.value,
            Sobrenome: Sobrenome.value,
            Peso: Peso.value,
            Altura: Altura.value
        });
        console.log(pessoas[i])
        console.log(pessoas)
        resultado.innerHTML += `<p>${pessoas[i].Nome} ${Sobrenome.value} ${Peso.value} ${Altura.value}</p>`
    }


}  
escopo();