function random(min,max) {
    const r = Math.random() * (max - min) + min;
    return Math.round(r);
}

const min = 10, max = 20;
let rand = random(min,max);

// Verifica e depois executa
while (rand !== 15) {
    rand = random(min,max);
    console.log(rand);
}

do {
    console.log(rand);
    rand = random(min,max);
} while (rand !== 10);