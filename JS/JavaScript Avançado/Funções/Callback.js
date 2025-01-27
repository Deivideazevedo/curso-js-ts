// Executa a função passada como argumento
function saudacao(nome, callback) {
    console.log(`Olá, ${nome}!`);
    callback(); 
  }
  
  const despedida = () => 
    console.log("Até logo!");
  
  saudacao("João", despedida);