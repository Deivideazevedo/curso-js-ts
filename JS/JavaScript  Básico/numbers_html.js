const numero = Number(prompt('Digite um número').replace(/,/g,'.'));

const titulo = document.getElementById('numero');
const texto = document.getElementById('texto');

titulo.innerHTML = numero ;
texto.innerHTML = `
<p>Seu número +2 é ${numero + 2}</p>
<p>Inteiro: ${Number.isInteger(numero)}</p>
<p>NaN: ${Number.isNaN(numero)}</p>
<p>arredondar para baixo: ${Math.floor(numero)}</p>
<p>arredondar para cima: ${Math.ceil(numero)}</p>
<p>Duas casas decimais: ${numero.toFixed(2)}</p>
`;