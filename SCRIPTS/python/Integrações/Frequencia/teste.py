#%%

import os
nome_arquivo = 'banco.txt'
token = nome_arquivo
if not os.path.exists(nome_arquivo):
    with open(nome_arquivo, 'a') as arquivo:
        arquivo.write('\nBanco_pla')
        
        open(nome_arquivo, 'a')
        arquivo.write('\nBanco_exp')
        
        open(nome_arquivo, 'a')
        arquivo.write('\nBanco_lt')
        arquivo.close()
         

with open(nome_arquivo,'r') as arquivo:
    token = arquivo.readlines()

if(token == []): 
        print("vazio")
else:
    if(token == []): 
        print("vazio")


valor1 = token [0]
valor2 = token [1]
valor3 = token [2]

print(valor1, valor2, valor3)