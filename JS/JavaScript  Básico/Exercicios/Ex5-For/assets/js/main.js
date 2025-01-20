const elementos = [
    {tag: 'p', texto: 'Frase 1'},
    {tag: 'div', texto: 'Frase 2'},
    {tag: 'section', texto: 'Frase 3'},
    {tag: 'footer', texto: 'Frase 4'}
];

const div = document.createElement('div');

for (let i = 0; i < elementos.length; i++) {
    const {tag, texto} = elementos[i];

    const newTag = document.createElement(tag);
    newTag.innerHTML = texto;

    div.appendChild(newTag);
}

const container = document.querySelector('.container');
container.appendChild(div);