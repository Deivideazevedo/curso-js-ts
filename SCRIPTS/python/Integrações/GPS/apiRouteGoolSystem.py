#%%
import requests
import pyodbc
import pandas as pd


# Credenciais e tokens para autenticação 
tk_basic                    = 'Basic V1NJbnRlZ3JhY2FvUExUOndzcGx0'
dt_operation                =  '19/07/2024'
url_consultar_atendimento   = 'https://servicos.cittati.com.br/WSIntegracaoCittati/Cadastro/ConsultarAtendimento?data=' + dt_operation + '&empresa=regimilson.silva@axe.gevan.com.br'


# Função para Obter informações de um WebService usando Autenticação
def obt_info_url(auth, url):
    data = requests.post(url, headers={'Authorization': auth})
    return data.json()

info_atendimento = pd.DataFrame(obt_info_url(tk_basic, url_consultar_atendimento))


# Conexão com o banco de dados
con = pyodbc.connect(
    'DRIVER={SQL Server};'
    'SERVER=10.6.2.80;'
    'DATABASE=producao_rao;'
    'UID=consulta;'
    'PWD=gevan10'
)


crs = con.cursor()


sql_codAtendimento = pd.read_sql('select distinct codAtendimento as codAtendimento from gps_pnt_atendimento', con)


dif = info_atendimento.merge(sql_codAtendimento, on='codAtendimento', how='left', indicator=True)
dif2 = dif[dif['_merge'] == 'left_only']

dif3 = (pd.concat({i: pd.json_normalize(x) for i, x in dif2.pop('linha').items()})
            .reset_index(level=1, drop=True)
            .join(dif2)
            .reset_index(drop=True))

dif4 = pd.DataFrame(dif3).loc[lambda x: x['itinerarios'].apply(lambda x: len(x) > 0)]

dif4 = dif4[dif4['numero']== '1603']

dif5 = (pd.concat({i: pd.json_normalize(x) for i, x in dif4.pop('itinerarios').items()})
            .reset_index(level=1, drop=True)
            .join(dif4)
            .reset_index(drop=True))

dif6 = pd.DataFrame(dif5).loc[lambda x: x['pontos'].apply(lambda x: len(x) > 0)]

dif7 = (pd.concat({i: pd.json_normalize(x) for i, x in dif6.pop('pontos').items()})
            .reset_index(level=1, drop=True)
            .join(dif6)
            .reset_index(drop=True))

dif8 = dif7[['linha', 'codAtendimento', 'linha', 'posicao', 'prefixo', 'sentido', 'previstoInicioViagem', 'previstoFimViagem', 'realizadoInicioViagem', 'realizadoFimViagem', 'idPonto', 'deteccaoDatahoraGps', 'entrada']]


# for l in info_atendimento:
     
#     for  i in l['pontos']:

#         crs.execute("insert into gps_pnt_atendimento values ( ?,?,?,?,?,?,?,?,?,?,?,?,? )",
#                      l['linha']['numero'], l['linha']['descricao'], l['codAtendimento'], l['nome'],l['tipo'], i['id'], i['nome'], i['nomeAbreviado'], i['sentido'], i['ordem'], i['tipo'], i['lat'], i['lng'] )

con.commit()

if 'crs' in locals():
    crs.close()

if 'con' in locals():
    con.close()




# %%
