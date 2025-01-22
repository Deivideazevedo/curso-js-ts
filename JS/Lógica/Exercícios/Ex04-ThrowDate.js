function retornaHora(data) {
    if (data && !(data instanceof Date)) throw new ReferenceError("Esperando instância de Date.");
    
    //Se não houver parametro, atribua um
    if (!data)  data = new Date();

    return data.toLocaleTimeString('pt-BR', {
        // hour: '2-digit',
        // minute: '2-digit',
        // second: '2-digit'
    });
}

try {
    const data = new Date('2025/01/31 12:12:12');
    const hora = retornaHora();
    console.log(retornaHora(hora));

} catch (e) {
    console.log(e);
} finally {
    console.log(retornaHora());
}