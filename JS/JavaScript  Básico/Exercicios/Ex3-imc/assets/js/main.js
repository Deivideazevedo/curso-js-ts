function escopo() {
    const container = document.querySelector('.container');
    const resultado = document.querySelector('.resultado');

    container.addEventListener('submit', calculaImc);

    function calculaImc(evento) {
        evento.preventDefault();
        const peso = +container.querySelector('#peso').value;
        const altura = +container.querySelector('#altura').value;
        const imc = (peso / (altura**2)).toFixed(1)
        let descricao 
        if (imc < 18.5) {
            descricao = 'Abaixo do peso'
        }else if (imc >= 18.5 && imc < 25) {
            descricao = 'Peso normal'
        }else if (imc >= 25 && imc < 29.9) {
            descricao = 'sobrepeso'
        }else if (imc >= 30 && imc < 34,9) {
            descricao = 'Obesidade grau 1'
        }else if (imc >= 35 && imc < 40) {
            descricao = 'Obesidade grau 2'
        }else {
            descricao = 'Obesidade grau 3'
        }

        resultado.innerHTML = `<p>Seu IMC é ${imc} (${descricao})</p>`
    }
}
escopo()