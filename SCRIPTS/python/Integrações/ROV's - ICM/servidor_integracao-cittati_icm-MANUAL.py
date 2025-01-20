# %%
import datetime as dt
import pandas as pd
import numpy as np
import requests
import pyodbc
import sqlalchemy as sqla

# database = "producao_ho1"
database = "producao_pla"

# connection_string = "DRIVER={/opt/microsoft/msodbcsql17/lib64/libmsodbcsql-17.10.so.4.1};SERVER=10.6.2.5;DATABASE=producao_ho1;UID=hallsoft;PWD=hall%*tec"
connection_string = "DRIVER={SQL Server};SERVER=10.6.2.5;DATABASE="+database+";UID=hallsoft;PWD=hall%*tec"
connection_url = sqla.engine.URL.create("mssql+pyodbc", query={"odbc_connect": connection_string})
engine = sqla.engine.create_engine(connection_url)

with engine.begin() as conn:
   
   # IMPEDIR QUE EXECUTE NOVAMENTE ENQUANTO HOUVER UM PROCESSO EM EXECUÇÃO
   sql = "SELECT TOP 1 icm_id, icm_cd_empresa, icm_tipo, icm_data, icm_usuario, icm_dt_sdo, icm_dtime_sdo, icm_dt_ini_py, icm_dt_fim_py, icm_status FROM icm_int_cittati_manual " + \
         "WHERE icm_tipo = 'ROV''s' AND icm_dt_ini_py IS NULL AND NOT EXISTS ( SELECT 1 FROM icm_int_cittati_manual WHERE icm_status = 'Em execução') ORDER BY icm_dtime_sdo"
   df_icm = pd.read_sql(sql,conn)

   if not df_icm.empty:
      icm_id =  int(df_icm.loc[0,'icm_id'])
      data_hora = dt.datetime.now().strftime("%d/%m/%Y %H:%M:%S")
      
      sql = sqla.text("UPDATE icm_int_cittati_manual SET icm_dt_ini_py = :icm_dt_ini_py, icm_status = :icm_status WHERE icm_id = :icm_id")
      params1 = {
         "icm_status": 'Em execução',
         "icm_dt_ini_py": data_hora,  
         "icm_id": int(df_icm.loc[0,'icm_id'])                    
      }
      conn.execute(sql, params1)

if not df_icm.empty:

   # PROCEDIMENTO PYTHON (ALISSON)
   pd.set_option('display.max_columns', None)

   # lista_empresas = ['Plataforma', 'Litoral', 'VCI', 'Expresso']
   # lista_empresas_cod = [10, 25, 26, 30]

   empresa = int(df_icm.loc[0,'icm_cd_empresa'])
   dia = df_icm.loc[0,'icm_data'].strftime("%d/%m/%Y")
   # dia_dt = dt.datetime.now()
   # if dia_dt.hour < 4:
   #    dia_dt = dia_dt + dt.timedelta(days = -1)
   # dia = dia_dt.strftime("%d/%m/%Y")

   url = 'http://servicos.cittati.com.br/WSIntegracaoCittati/Autenticacao/AutenticarUsuario'
   base64user = 'Basic V1NJbnRlZ3JhY2FvUExUOndzcGx0'


   flag_insert = 0

   while flag_insert == 0:
      try:
         response = requests.post(url=url, headers={'Authorization': base64user})
         jsonResponse = response.json()
         token = jsonResponse["token"]

         url_viagem = 'http://servicos.cittati.com.br/WSIntegracaoCittati/' + \
                     'Operacional/ConsultarViagens?data=' + dia + \
                     '&empresa=regimilson.silva@axe.gevan.com.br'

         response_viagem = requests.post(url=url_viagem, headers = {"Authorization": "Bearer "+token})
         jsonViagem = response_viagem.json()

         dfv = pd.DataFrame.from_dict(jsonViagem["viagens"])

         dfv = dfv.sort_values(by = ['veiculo', 'inicioRealizado', 'fimRealizado'])
         dfv.reset_index(drop=True, inplace=True)
         testedf = dfv[['linha', 'veiculo', 'atividade', 'inicioRealizado', 'fimRealizado', 'sentido',
            'tabela', 'inicioProgramado', 'fimProgramado', 'motorista', 'cobrador',
            'codPontoInicio', 'nomePontoInicio', 'codPontoFim', 'nomePontoFim',
            'kmProgramado', 'kmRealizado']].copy()

         
         testedf.columns = ['linha', 'veiculo', 'tipo_viagem', 'inicio', 'fim', 'sentido_vgm',
                           'nu_pos', 'inicio_prev', 'fim_prev', 'matriculaMotorista', 'matriculaCobrador',
                           'codPontoInicio', 'nomePontoInicio', 'codPontoFim', 'nomePontoFim',
                           'kmProgramado', 'kmRealizado']
         
         # Configuração futura exigirá essa linha para continuar funcionando a conversao de str para int
         # pd.set_option('future.no_silent_downcasting', True)
         testedf['tipo_viagem'].replace(['Viagem Normal', 'Recolhe', 'Saída de Garagem','Viagem Extra', 'Transferência'], [1, 3, 5, 6, 0], inplace=True)
         

         # pd.set_option('future.no_silent_downcasting', True)
         testedf.insert(0, 'reg', testedf.index+1)
         testedf.insert(0, 'dt_ope', dia)
         testedf.insert(0, 'cd_emp', empresa)

         # Adicionando aspas simples ao redor dos valores das colunas
         cols = ['dt_ope', 'linha', 'veiculo', 'inicio', 'fim', 'sentido_vgm', 'nu_pos', 'inicio_prev', 'fim_prev',
        'codPontoInicio', 'nomePontoInicio', 'codPontoFim', 'nomePontoFim']
         testedf[cols] = "'" + testedf[cols].astype(str) + "'"

         testedf.replace(["'None'"], ["''"], inplace=True)
         testedf.fillna(value="''", inplace=True)


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
         testedf.inicio = "'" + testedf.inicio.dt.strftime("%d/%m/%Y %H:%M:%S") + "'"
         testedf.fim = "'" + testedf.fim.dt.strftime("%d/%m/%Y %H:%M:%S") + "'"
         testedf.inicio_prev = "'" + testedf.inicio_prev.dt.strftime("%d/%m/%Y %H:%M:%S") + "'"
         testedf.fim_prev = "'" + testedf.fim_prev.dt.strftime("%d/%m/%Y %H:%M:%S") + "'"
         testedf.fillna("''", inplace=True)

         
         testedf['inicio'] = testedf['inicio'].fillna(value='None')  
         testedf['fim'] = testedf['fim'].fillna(value='None')  

         testedf.loc[(testedf.matriculaMotorista == "''"), 'matriculaMotorista'] = None
         testedf.loc[(testedf.matriculaCobrador == "''"), 'matriculaCobrador'] = None

         testedf = testedf[testedf['veiculo'] != "''"]

         testedf.nu_pos = testedf.nu_pos.replace('[\\sa-zA-Z]+', '', regex=True)

         any(testedf['inicio'] == '01/01/1900 00:00:00')
         any(testedf['fim'] == '01/01/1900 00:00:00')
         flag_insert = 1
      except KeyError:
         print("KeyError")
         flag_insert = 2
         
         # ERRO NO PROCESSO
         data_hora = dt.datetime.now().strftime("%d/%m/%Y %H:%M:%S")
         sql = sqla.text("UPDATE icm_int_cittati_manual SET icm_dt_fim_py = :icm_dt_fim_py, icm_status = :icm_status WHERE icm_id = :icm_id")
         params6 = {
            "icm_status": 'Erro',
            "icm_dt_fim_py": data_hora,
            "icm_id": icm_id
         }
         retorno = conn.execute(sql, params6)


   if flag_insert != 2:
      try:
         with engine.begin() as conn:
            # Deletando entradas anteriores na tmp
            sql = sqla.text("DELETE FROM tmp_int_sdo_gss WHERE dt_ope = :dt_ope AND cd_emp = :cd_emp")
            params2 = {
               "dt_ope": dia,  
               "cd_emp": empresa                     
            }
            conn.execute(sql, params2)

            cols = ", ".join(str(i) for i in testedf.columns.tolist())

            for i, row in testedf.iterrows():  
               # pegando os values dinamicamente
               vals = row.tolist()  
               values = ", ".join( ":v"+str(i+1) for i in range(len(vals)))

               # INSERINDO LINHAS E REMOVENDO AS ASPAS EXCEDENTES DAS DATAS
               sql = sqla.text("INSERT INTO tmp_int_sdo_gss (" + cols + ") VALUES (" + values + ")")
               params3 = {f"v{i+1}": vals[i].strip(" '") if isinstance(vals[i],str) else vals[i] for i in range(len(vals))}
            
               conn.execute(sql, params3)


            # DELETANDO ROV
            sql = sqla.text("DELETE FROM rvv_rov_viagem WHERE rvv_cd_empresa = :rvv_cd_empresa AND rvv_dt_operacao = :rvv_dt_operacao")
            params4 = {
               "rvv_cd_empresa": empresa,
               "rvv_dt_operacao": dia
            }
            conn.execute(sql, params4)


            # EXECUTANDO PROCEDURES DE INTEGRAÇÃO
            sql = sqla.text(f"EXEC sp_sdo_ope_rov_int_gps_new {empresa}, {0}, '{dia}', {icm_id}")
            conn.execute(sql)


            # PROCESSO FINALIZADO
            data_hora = dt.datetime.now().strftime("%d/%m/%Y %H:%M:%S")
            sql = sqla.text("UPDATE icm_int_cittati_manual SET icm_dt_fim_py = :icm_dt_fim_py, icm_status = :icm_status WHERE icm_id = :icm_id")
            params6 = {
               "icm_status": 'Finalizado',
               "icm_dt_fim_py": data_hora,
               "icm_id": icm_id
            }
            retorno = conn.execute(sql, params6)
      except Exception as e:
         with engine.begin() as conn:

            # ERRO NO PROCESSO
            data_hora = dt.datetime.now().strftime("%d/%m/%Y %H:%M:%S")
            sql = sqla.text("UPDATE icm_int_cittati_manual SET icm_dt_fim_py = :icm_dt_fim_py, icm_status = :icm_status WHERE icm_id = :icm_id")
            params6 = {
               "icm_status": 'Erro',
               "icm_dt_fim_py": data_hora,
               "icm_id": icm_id
            }
            conn.execute(sql, params6)
         print(f"Erro ao executar o processo: {e}")
