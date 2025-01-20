// Capturar evento de submit do formulário
const form = document.querySelector('#formulario');

form.addEventListener('submit', function (e) {
  e.preventDefault();
  
  const inputPeso = e.target.querySelector("#peso");
  const inputAltura = form.querySelector("#altura");

  const peso = Number(inputPeso.value);
  const altura = Number(inputAltura.value);

  if (!peso) {
    setparagrafo('Peso inválido', false);
    return;
  }
  if (!altura) {
    setparagrafo('Altura inválida', false);
    return;
  }

  const imc = getIMC(peso,altura);
  const nivel = getNivelImc(imc);
  const msg = `Seu IMC é ${imc} (${nivel})`;

  setparagrafo(msg,true);
});

function setparagrafo (msg, isvalid){
  const resultado = document.querySelector("#resultado");
  resultado.innerHTML = '';

  const p = paragrafo('') // ou const p = paragrafo('paragrafo-resultado')
  if (isvalid) {
    p.classList.add('paragrafo-resultado')
  }else{
    p.classList.add('bad')
  }

  
  p.innerHTML = msg;
  resultado.appendChild(p);
}

function paragrafo(nm_classe) {
  const p = document.createElement('p');
  
  if (nm_classe) {
    p.classList.add(nm_classe)
  }
  return p;
}

function getIMC(peso, altura) {
  const imc = peso / altura ** 2
  return imc.toFixed(2);
}

function getNivelImc(imc) {
  const nivel = ['Abaixo do peso','Peso normal', 'Sobrepeso', 'Obesidade grau 1', 'Obesidade grau 2', 'Obesidade grau 3'];

  if (imc > 40)     return nivel[5];
  if (imc >= 34.9)  return nivel[4];
  if (imc >= 29.9)  return nivel[3];
  if (imc >= 24.9)  return nivel[2];
  if (imc >= 18.5)  return nivel[1];
  if (imc < 18.5)   return nivel[0];
}