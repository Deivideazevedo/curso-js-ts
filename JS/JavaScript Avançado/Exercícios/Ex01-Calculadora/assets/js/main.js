function criaCalculadora() {
    return {
        display: document.querySelector('.display'), 

        inicia() {
            this.cliqueBotao();
            this.pressEnter();
        },

        clearDisplay() {
            this.display.value = ''
        },

        pressEnter(){
            document.addEventListener('keypress', (e) => {
                if (e.key === 'Enter') this.realizaConta();
            });
        },

        cliqueBotao: function() {
            // com arrow function, o this nao muda por causa da funcao que iniciou o evento
            document.addEventListener('click', (e) => {
                const elemento = e.target;
                if (elemento.classList.contains('btn-num')) this.btnParaDisplay(elemento.innerText);

                if (elemento.classList.contains('btn-clear')) this.clearDisplay();

                if (elemento.classList.contains('btn-del')) this.apagaUm(); 

                if (elemento.classList.contains('btn-eq')) this.realizaConta(); 
            })
        },

        btnParaDisplay(valor){
            this.display.value += valor;
            this.display.focus();
        },

        apagaUm(){
            this.display.value = this.display.value.slice(0,-1);
            this.display.focus();
        },

        realizaConta(){
            const listaPermitida = ['0','1','2','3','4','5','6','7','8','9','(',')','*','/','-','.','+']
            const valueDisplay = this.display.value.replaceAll(',','.')
            const arrayDisplay = valueDisplay.split('');
            // console.log(valueDisplay);

            const naoContido = arrayDisplay.filter(item => !listaPermitida.includes(item));    
            // console.log(naoContido.length)

            if (naoContido.length === 0) {
                try {
                    const conta = eval(valueDisplay);

                    if (!conta){
                        alert('Conta inválida');
                        return
                    }
                } catch (e) {
                    alert('Conta inválida');
                    return
                }

                this.display.value = String(conta);
            }else{
                alert(`Conta Inválida, valores nao permitidos:\n${naoContido}`,);
                return
            }

            this.display.focus();
        }
    };
}

const calculadora = criaCalculadora();
calculadora.inicia();