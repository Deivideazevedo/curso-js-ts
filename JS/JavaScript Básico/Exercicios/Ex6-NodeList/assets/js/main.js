const paragrafos = document.querySelector('.paragrafos');
const nodeList = paragrafos.querySelectorAll('p'); //Não é um array, mas se comporta como um.
// console.log('teste', nodeList[0].innerText)

const estilosBody = getComputedStyle(document.body);
const backgroundColor = estilosBody.backgroundColor
console.log(backgroundColor)

for (let p of nodeList){
    p.style.backgroundColor = backgroundColor;
    p.style.color = '#FFFFFF'
    console.log(p.innerText)
}
