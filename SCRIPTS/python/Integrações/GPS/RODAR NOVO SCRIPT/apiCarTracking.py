#%%
import requests
import pyodbc
import pandas as pd
from datetime import datetime, timedelta


all_values_to_insert_null   = []
all_values_to_insert        = []
num = 113

# Credenciais e tokens para autenticação 
tokenBasicOtt                       = 'Basic V1NJTlRFR1JBOmludDNnckAyMDIz' # auth=('WSINTEGRA', 'int3gr@2023') 
empresaPla                          = 'regimilson.silva@axe.gevan.com.br'
tokenBasicPla                       = 'Basic V1NJbnRlZ3JhY2FvUExUOndzcGx0' # auth=('WSIntegracaoPLT', 'wsplt') 
empresaOtt                          = 'ednilson@expressovitoriaba.com.br'

# REGISTRAR ERRO
def registrar_erro(linha, dataescala, exception):
    data = datetime.now().strftime('%d/%m/%Y %H:%M:%S')
    nome_arquivo = "erros.txt"
    modo_abertura = "a"  # Modo de abertura "append" para adicionar ao final do arquivo
    mensagem_erro = f"{data} - Ocorreu um erro para a data escala: {str(dataescala)}, linha: {str(linha)}, - ERRO: {str(exception)}\n"

    with open(nome_arquivo, modo_abertura) as arquivo:
        arquivo.write(mensagem_erro)

# Função para Obter informações de um WebService usando Autenticação
def obt_info_url(auth, url):
    data = requests.post(url, headers={'Authorization': auth})
    return data.json()

# Função para obter a data
def obt_info_data(d):
    data = datetime.now() - timedelta(days=d)
    #data = datetime(2024,1,1) + timedelta(days=d)
    return data.strftime('%d/%m/%Y')





# Obtém a data de operação, passa a quantidade de dias atrás
# 29 - 25/06/2024
dt_operation = obt_info_data(36)
print('Inicializou - ' + dt_operation)



# Seleciona a Empresa e token a ser usados 
empresa     = empresaPla
tokenBasic  = tokenBasicOtt 

# URLs para autenticação e consulta 
url_autenticar_usuario          = 'http://servicos.cittati.com.br/WSIntegracaoCittati/Autenticacao/AutenticarUsuario'
url_consultar_viagens           = 'http://servicos.cittati.com.br/WSIntegracaoCittati/Operacional/ConsultarViagens?data=' + dt_operation + '&empresa=' + empresa
url_consultar_viagens_deteccoes = 'https://servicos.cittati.com.br/WSIntegracaoCittati/Operacional/ConsultarViagensDeteccoes?data=' + dt_operation + '&empresa=' + empresa + '&linha='


# Consulta ws para pegar as linhas que rodaram em determinada data 
consultar_viagens = pd.DataFrame.from_dict(
    obt_info_url('Bearer ' + 
        obt_info_url(
                        tokenBasic, 
                        url_autenticar_usuario
                    )
                    ['token']
        , url_consultar_viagens
    )
    ['viagens']
)



# Pegas as linhas que existe no ws de consulta de viagem 
for lin in consultar_viagens.linha.unique():

    # Captura dados da linha 
    consultar_viagens_deteccoes = obt_info_url(tokenBasic, url_consultar_viagens_deteccoes + lin)


    # Verifica se existe dados para deterninada linha
    if consultar_viagens_deteccoes['viagens']:

        try:   
            # Captura dados de registros sem detecções
            dfViagemDeteccoesNull = (pd.DataFrame(consultar_viagens_deteccoes['viagens'])
                                    .loc[lambda x: x['deteccoes'].apply(lambda x: len(x) == 0)]
                                    [['dataEscala', 'codAtendimento', 'linha', 'posicao', 'prefixo', 'sentido', 'previstoInicioViagem', 'previstoFimViagem', 'realizadoInicioViagem', 'realizadoFimViagem']]
                                    .assign(idPonto=0))
            

            # Captura dados de registros com detecções
            dfViagemDeteccoes = pd.DataFrame(consultar_viagens_deteccoes['viagens']).loc[lambda x: x['deteccoes'].apply(lambda x: len(x) > 0)]

            # Verificar se tem informações 
            if not dfViagemDeteccoes.empty:

            
                detNormalize = (pd.concat({i: pd.json_normalize(x) for i, x in dfViagemDeteccoes.pop('deteccoes').items()})
                            .reset_index(level=1, drop=True)
                            .join(dfViagemDeteccoes)
                            .reset_index(drop=True)
                            .fillna(0))[['dataEscala','codAtendimento', 'linha', 'posicao', 'prefixo', 'sentido', 'previstoInicioViagem', 'previstoFimViagem', 'realizadoInicioViagem', 'realizadoFimViagem', 'idPonto', 'deteccaoDatahoraGps', 'entrada']]


                
            # Verificr se existe dados e armazena os dados criando uma trupla 
            if not dfViagemDeteccoesNull.empty:
                values_to_insert_null = dfViagemDeteccoesNull.values.tolist()
                all_values_to_insert_null.extend(values_to_insert_null)
                

            if not detNormalize.empty:
                values_to_insert = detNormalize.values.tolist()
                all_values_to_insert.extend(values_to_insert)

        except Exception as e:
            registrar_erro(lin, dt_operation, e) 

print('Fim do tratamento, Iniciando inserções no banco...')

# Conexão com o banco de dados
con = pyodbc.connect(
    'DRIVER={SQL Server};'
    'SERVER=10.6.2.80;'
    #'DATABASE=homologacao_rao;'
    'DATABASE=producao_rao;'
    'UID=consulta;'
    'PWD=gevan10'
)

crs = con.cursor()





if all_values_to_insert_null:
    # Insere viagens sem detecções no banco de dados
    crs.executemany('insert into gps_vgm_pnt (dataEscala, codAtendimento, linha, posicao, prefixo, sentido, previstoInicioViagem, previstoFimViagem, realizadoInicioViagem, realizadoFimViagem, idPonto) ' 
                    'values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', all_values_to_insert_null)
    

if all_values_to_insert:
    # Insere viagens com detecções no banco de dados
    crs.executemany('INSERT INTO gps_vgm_pnt (dataEscala, codAtendimento, linha, posicao, prefixo, sentido, previstoInicioViagem, previstoFimViagem, realizadoInicioViagem, realizadoFimViagem, idPonto, deteccaoDatahoraGps, entrada) '
                    'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', all_values_to_insert)





con.commit()



# Fecha as conexão 
if 'crs' in locals():
    crs.close()

if 'con' in locals():
    con.close()


print('Finalizou - ' + dt_operation)
num -= 1

# %%
