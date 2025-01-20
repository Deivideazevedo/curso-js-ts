
import requests
import pyodbc
import pandas as pd
import numpy as np
import datetime as dt

pd.set_option('display.max_columns', None)

lista_empresas = ['Plataforma', 'Litoral', 'VCI', 'Expresso']

lista_empresas_cod = [10, 25, 26, 30]

url = 'http://servicos.cittati.com.br/WSIntegracaoCittati/Autenticacao/AutenticarUsuario'

empresa = 10


base64user = 'Basic V1NJbnRlZ3JhY2FvUExUOndzcGx0'

dia_dt = dt.datetime.now()

if dia_dt.hour <= 6 and dia_dt.minute < 30:
   dia_dt = dia_dt + dt.timedelta(days = -1)

dia = dia_dt.strftime("%d/%m/%Y")
#dia = '31/12/2024'
print(dia)

flag_insert = 0
while flag_insert == 0:
	try:
		response = requests.post(url = url,
			    headers = {'Authorization': base64user})

		jsonResponse = response.json()

		#print(response.text)
		#print(jsonResponse)
		print(jsonResponse)
		token = jsonResponse["token"]
		#print(token)


		url_viagem = 'http://servicos.cittati.com.br/WSIntegracaoCittati/' + \
			     'Operacional/ConsultarViagens?data=' + dia + \
			     '&empresa=regimilson.silva@axe.gevan.com.br'

		response_viagem = requests.post(url = url_viagem, headers = {"Authorization": "Bearer "+token})

		jsonViagem = response_viagem.json()

		dfv = pd.DataFrame.from_dict(jsonViagem["viagens"])

		dfv = dfv.sort_values(by = ['veiculo', 'inicioRealizado', 'fimRealizado'])
		dfv.reset_index(drop=True, inplace=True)
		testedf = dfv[['linha', 'veiculo', 'atividade', 'inicioRealizado', 'fimRealizado', 'sentido',
		     'tabela', 'inicioProgramado', 'fimProgramado', 'motorista', 'cobrador',
		     'codPontoInicio', 'nomePontoInicio', 'codPontoFim', 'nomePontoFim',
		     'kmProgramado', 'kmRealizado']].copy()
		#testedf.reset_index(drop=True, inplace=True)
		#testedf.fillna(value="''", inplace=True)
		testedf.columns = ['linha', 'veiculo', 'tipo_viagem', 'inicio', 'fim', 'sentido_vgm',
				   'nu_pos', 'inicio_prev', 'fim_prev', 'matriculaMotorista', 'matriculaCobrador',
				   'codPontoInicio', 'nomePontoInicio', 'codPontoFim', 'nomePontoFim',
				   'kmProgramado', 'kmRealizado']
		testedf.replace(['Viagem Normal', 'Recolhe', 'Saída de Garagem',
				 'Viagem Extra', 'Transferência'], [1, 3, 5, 6, 0], inplace=True)
		testedf.insert(0, 'reg', testedf.index+1)
		testedf.insert(0, 'dt_ope', dia)
		testedf.insert(0, 'cd_emp', empresa)
		testedf.update("'" + testedf[['dt_ope', 'linha', 'veiculo', 'inicio', 'fim', 'sentido_vgm',
							     'nu_pos', 'inicio_prev', 'fim_prev',
					      'codPontoInicio', 'nomePontoInicio', 'codPontoFim', 'nomePontoFim']].astype(str) + "'")
		testedf.replace(["'None'"], ["''"], inplace=True)
		testedf.fillna(value="''", inplace=True)

		#testedf.tail()
		#Converting to datetime
		#testedf['inicio'].replace(["''"], np.nan, inplace=True)
		#testedf['fim'].replace(["''"], np.nan, inplace=True)
		# PURE PYTHON: testedf[testedf['inicio'].isin(["''"])].inicio
		#Padas:
		testedf.loc[(testedf.inicio == "''"), 'inicio'] = ''
		testedf.loc[(testedf.fim == "''"), 'fim'] = ''
		testedf.loc[(testedf.inicio_prev == "''"), 'inicio_prev'] = ''
		testedf.loc[(testedf.fim_prev == "''"), 'fim_prev'] = ''
		testedf['inicio'] = pd.to_datetime(testedf['inicio'], dayfirst = True)
		testedf['fim'] = pd.to_datetime(testedf['fim'], dayfirst = True)
		testedf['inicio_prev'] = pd.to_datetime(testedf['inicio_prev'], dayfirst = True)
		testedf['fim_prev'] = pd.to_datetime(testedf['fim_prev'], dayfirst = True)
		testedf = testedf.assign(inicio=testedf.inicio.dt.floor('min'))
		testedf = testedf.assign(fim=testedf.fim.dt.floor('min'))
		testedf = testedf.assign(inicio_prev=testedf.inicio_prev.dt.floor('min'))
		testedf = testedf.assign(fim_prev=testedf.fim_prev.dt.floor('min'))

		#Formatando o tempo antes de substituir
		#testedf.inicio[testedf.inicio != "''"] = "'" + testedf.inicio[testedf.inicio != "''"].dt.strftime("%d/%m/%Y %H:%M:%S") + "'"
		#testedf.fim[testedf.fim != "''"] = "'" + testedf.fim[testedf.fim != "''"].dt.strftime("%d/%m/%Y %H:%M:%S") + "'"
		#testedf.inicio_prev[testedf.inicio_prev != "''"] = "'" + testedf.inicio_prev[testedf.inicio_prev != "''"].dt.strftime("%d/%m/%Y %H:%M:%S") + "'"
		#testedf.fim_prev[testedf.fim_prev != "''"] = "'" + testedf.fim_prev[testedf.fim_prev != "''"].dt.strftime("%d/%m/%Y %H:%M:%S") + "'"

		testedf.loc[testedf.inicio != "''", 'inicio'] = "'" + testedf.loc[testedf.inicio != "''", 'inicio'].dt.strftime("%d/%m/%Y %H:%M:%S") + "'"
		testedf.loc[testedf.fim != "''", 'fim'] = "'" + testedf.loc[testedf.fim != "''", 'fim'].dt.strftime("%d/%m/%Y %H:%M:%S") + "'"
		testedf.loc[testedf.inicio_prev != "''", 'inicio_prev'] = "'" + testedf.loc[testedf.inicio_prev != "''", 'inicio_prev'].dt.strftime("%d/%m/%Y %H:%M:%S") + "'"
		testedf.loc[testedf.fim_prev != "''", 'fim_prev'] = "'" + testedf.loc[testedf.fim_prev != "''", 'fim_prev'].dt.strftime("%d/%m/%Y %H:%M:%S") + "'"


		testedf['inicio'].fillna(value='None', inplace=True)
		testedf['fim'].fillna(value='None', inplace=True)
		testedf.loc[(testedf.matriculaMotorista == "''"), 'matriculaMotorista'] = None
		testedf.loc[(testedf.matriculaCobrador == "''"), 'matriculaCobrador'] = None

		testedf = testedf[testedf['veiculo'] != "''"]
		#testedf.nu_pos.replace(' - TROCA', '', regex=True, inplace=True)
		#testedf.nu_pos.replace(' [a-zA-Z]+', '', regex=True, inplace=True)
		testedf.veiculo.replace('[T]+', '', regex=True, inplace=True)
		testedf.nu_pos.replace('[\\sa-zA-Z]+', '', regex=True, inplace=True)

		#testedf = testedf[testedf['veiculo'] != "'VNR'"]
		#testedf = testedf[testedf['fim'].notnull().values]
		#testedf.fillna(value='', inplace=True)

		#testedf.inicio[testedf.inicio != "''"] = "'" + testedf.inicio[testedf.inicio != "''"].dt.strftime("%d/%m/%Y %H:%M:%S") + "'"
		#testedf.fim[testedf.fim != "''"] = "'" + testedf.fim[testedf.fim != "''"].dt.strftime("%d/%m/%Y %H:%M:%S") + "'"
		#testedf.inicio_prev[testedf.inicio_prev != "''"] = "'" + testedf.inicio_prev[testedf.inicio_prev != "''"].dt.strftime("%d/%m/%Y %H:%M:%S") + "'"
		#testedf.fim_prev[testedf.fim_prev != "''"] = "'" + testedf.fim_prev[testedf.fim_prev != "''"].dt.strftime("%d/%m/%Y %H:%M:%S") + "'"

		#testedf = testedf[(testedf['inicio'] != "''") | (testedf['fim'] != "''") | (testedf['veiculo'] != "''")]

		any(testedf['inicio'] == '01/01/1900 00:00:00')
		any(testedf['fim'] == '01/01/1900 00:00:00')
		
		flag_insert = 1
		#testedf.loc[(testedf.inicio != "''"), 'inicio'] = testedf.inicio.strftime("%d/%m/%Y %H:%M:%S")
		#testedf.iloc[0,6].strftime("%d/%m/%Y %H:%M:%S")
		#testedf.loc[(testedf.inicio != "''"), 'inicio'].dt.strftime("%d/%m/%Y %H:%M:%S")
		# testedf.loc[(pd.isnull(testedf.inicio)), 'inicio'] = ''
		# Slicing strings without converting to datetime
		#testedf['inicio'] = testedf['inicio'].str.slice(start=0, stop=18) + '00'
		#testedf['inicio'].fillna('None')
		#testedf['fim'] = testedf['fim'].str.slice(start=1, stop=17) + '00'
		#testedf['fim'].fillna('None')
		#%d-%m-%Y
	except KeyError:
		print("KeyError")
		flag_insert = 2

if flag_insert != 2:
    cols = ", ".join(str(i) for i in testedf.columns.tolist())
    conn = pyodbc.connect('DRIVER={/opt/microsoft/msodbcsql17/lib64/libmsodbcsql-17.10.so.4.1};' # {/opt/microsoft/msodbcsql17/lib64/libmsodbcsql-17.6.so.1.1}
                          'SERVER=10.6.2.5;'
                          'DATABASE=producao_pla;'
                          'UID=hallsoft;PWD=hall%*tec;Encrypt=no;')

    cursor = conn.cursor()
    # Deletando entradas anteriores na tmp
    cursor.execute("DELETE FROM tmp_int_sdo_gss WHERE dt_ope = ? and cd_emp = 10", dia)
    conn.commit()
    
    for i,row in testedf.iterrows():
        print(i)
        vals = row.to_string(index = False).split('\n')
        vals = ', '.join([x.lstrip() for x in vals])
   #sql = "INSERT INTO tmp_int_sdo_gss_testes (" + cols + ") VALUES (" +vals + ")" 
  # sql = "INSERT INTO tmp_int_sdo_gss_testes (" + cols + ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", vals) 
#cursor.executemany("insert into t(name, id) values (?, ?)", params)
#cursor.execute("select a from tbl where b=? and c=?", (x, y))
        cursor.execute("INSERT INTO tmp_int_sdo_gss (" + cols + ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", eval(vals)) 
   #print(vals)

# the connection is not autocommitted by default, so we must commit to save our # changes 
#params = (10, 0, '13/08/2020')
    conn.commit()


    cursor.execute("INSERT INTO log_int_rov_gps (data_operacao, data_integracao) VALUES( ? ,GETDATE())", dia)
    conn.commit()

cursor.close()
conn.close()
