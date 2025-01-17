// Capturar evento de submit do formulário
const form = document.querySelector('#formulario');

form.addEventListener('submit', function (e) {
  e.preventDefault();
  console.log('Evento')

  setparagrafo('Novo paragrafo')
});

function setparagrafo (msg){
  const resultado = document.querySelector("#resultado");
  resultado.innerHTML += '';

  const p = paragrafo('paragrafo-resultado')
  p.innerHTML = msg;
  resultado.appendChild(p);
}

function paragrafo(nm_classe) {
  const p = document.createElement('p');
  p.classList.add(nm_classe)
  return p;
}