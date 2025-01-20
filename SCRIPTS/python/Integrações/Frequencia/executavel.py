#%%
import os, requests, datetime as dt, pandas as pd, pyodbc, threading, time
import tkinter as tk
from tkinter import Frame, Label, Button
from tkinter.ttk import Progressbar
import json


with open('C:/Users/0172/Documents/Projetos/Python/Integrações/Frequencia/origem frequencia/Acessos/cd_emp.txt', 'r') as arquivo:
    cd_emp = int(arquivo.readline().strip())

def tela(root):
    root.attributes('-topmost', True)
    root.title("Integração Gevito - Frequencia") 

    largura, altura = (380),(140)
    screen_x, screen_y = (root.winfo_screenwidth()),(root.winfo_screenheight())
    posx, posy = (screen_x/2 - largura/2), (screen_y/2 - altura/2)

    root.geometry('%dx%d+%d+%d' % (largura, altura, posx, posy))

class Application:
    def __init__(self, master=None):
        self.fontePadrao = ("Arial", 10)

        self.primeiroContainer = Frame(master)
        self.primeiroContainer["pady"] = 15
        self.primeiroContainer.pack()

        self.segundoContainer = Frame(master)
        self.segundoContainer["padx"] = 20        
        self.segundoContainer.pack(pady=10)

        self.terceiroContainer = Frame(master)   
        self.terceiroContainer.pack()

        self.titulo = Label(self.primeiroContainer, text="Integração SDO - Gevito:")
        self.titulo["font"] = ("Arial", 10, "bold")
        self.titulo.pack(side=tk.LEFT)
        
        self.nomeLabel = Label(self.primeiroContainer, text="Frequência Operador", font=self.fontePadrao)
        self.nomeLabel.pack()

        self.autenticar = Button(self.segundoContainer, text=" --> Clique aqui para Iniciar <--", font=self.fontePadrao, width=23)    
        self.autenticar["command"] = self.iniciar
        self.autenticar.pack()

    def iniciar(self):
        self.start_time = time.time() 
        self.inicio = time.strftime("%H:%M:%S",  time.localtime(self.start_time))

        self.autenticar.destroy()
        self.mensagem = Label(self.segundoContainer, text="Progresso", font=self.fontePadrao)
        self.mensagem.pack(pady=0)
        
        self.progress = Progressbar(self.segundoContainer, value=0, orient=tk.HORIZONTAL, length=100, mode='determinate', maximum=100)
        self.progress.pack(pady=0)

        # TEMPORARIZADOR
        self.esquerdo = Label(self.terceiroContainer, text="Inicio: " + str(self.inicio) +"", font=self.fontePadrao)
        self.esquerdo.pack(side=tk.LEFT)

        self.centro = Label(self.terceiroContainer, text="meio", font=self.fontePadrao)
        self.centro.pack(side=tk.LEFT)
        self.centro["padx"] = 60
        
        self.direito = Label(self.terceiroContainer, text="Fim: -- : -- : --", font=self.fontePadrao)
        self.direito.pack(side=tk.RIGHT)

        self.running = True        
        self.update_clock()
    
        thread = threading.Thread(target=self.enviar_dados)
        thread.start()

    
    def update_clock(self):
        if self.running:
            self.elapsed_time = int(time.time() - self.start_time)

            self.hours, self.remainder = divmod(self.elapsed_time, 3600)
            self.minutes, self.seconds = divmod(self.remainder, 60)
            self.centro["text"] = f"{self.hours:02}:{self.minutes:02}:{self.seconds:02}"
            self.centro.update_idletasks()
            self.centro.after(1000, self.update_clock)

    def encerrar(self):
        root.destroy()

    def verificar(self, headerAut):
        
        urlfreq = "http://hml.folhapontoaponto.com.br/api/v2/frequencias"
        payload = {}
        resposta = requests.request("POST", urlfreq, json=payload, headers=headerAut).status_code

        if resposta == 401:
            print("Usuario nao autenticado")

            # urlLogin = "https://folhapontoaponto.com.br/api/v2/login"
            # payloadLogin = {
            #     "email": "integracao@gevan.com.br",
            #     "password": "xLUG@oaYP82$xWxx7XkS8@Mf"
            # }
            
            urlLogin = "http://hml.folhapontoaponto.com.br/api/v2/login"
            
            dados=[]
            with open("./Acessos/logingo.txt",'r') as arquivo:
                linhas = arquivo.readlines()
                for linha in linhas:
                    dados.append(linha.strip().split('\n'))

            logingo = str(dados[cd_emp]).replace("']",'').replace("['",'').replace("'{",'').replace("}'",'')
            print(logingo)
            payloadLogin = json.loads(logingo)
            header = {
                "Content-Type": "application/json",
                "X-CSRF-TOKEN": "",
                "accept": "application/json"
            }
            token = requests.request("POST", urlLogin, json=payloadLogin, headers=header).json()['data']['token']      
            
            if cd_emp == 0:
                nome_arquivo = 'C:/Users/0172/Documents/Projetos/Python/Integrações/Frequencia/origem frequencia/Acessos/token-pla.txt'
            elif cd_emp == 1: 
                nome_arquivo = 'C:/Users/0172/Documents/Projetos/Python/Integrações/Frequencia/origem frequencia/Acessos/token-ln.txt'
            elif cd_emp == 2:
                nome_arquivo = 'C:/Users/0172/Documents/Projetos/Python/Integrações/Frequencia/origem frequencia/Acessos/token-exp.txt'

            with open(nome_arquivo, 'w') as arquivo:
                arquivo.write(token)

            print("Corrigido")
        
        elif resposta != 200 and resposta != 401:
            print(f"Problemas com a api, Status: '{resposta}'")
        
        return resposta

    def enviar_dados(self):
        
        dados=[]

        with open("C:/Users/0172/Documents/Projetos/Python/Integrações/Frequencia/origem frequencia/Acessos/bancobd.txt",'r') as arquivo:
            linhas = arquivo.readlines()
            for linha in linhas:
                dados.append(linha.strip().split('\n'))
            bancobd = str(dados[cd_emp]).replace("']",'').replace("['",'')
            print(bancobd)
            
        conn = pyodbc.connect('DRIVER={SQL Server};'
                            'SERVER=10.6.2.5;'
                            'DATABASE='+str(bancobd)+';'
                            'UID=hallsoft;PWD=hall%*tec')

        df = pd.read_sql('SELECT freq_tp_operacao, freq_cd_fnc, freq_dt_frequencia, freq_dt_competencia, freq_hr_inicial, freq_hr_fim, freq_hr_extra, freq_hr_adicional_noturno, freq_hr_intervalo, freq_hr_bonificacao, freq_hr_atraso, freq_hr_trabalhadas_total, freq_hr_normal, freq_hr_noturnas, freq_dt_remuneracao, freq_hr_extras_50, freq_hr_extras_100, freq_hr_desloca, freq_hr_adic_noturno, freq_qtd_ticket, freq_hr_ini_int4, freq_hr_fim_int4, freq_dsc_item, freq_nu_ordem, freq_hr_trabalhada, freq_hr_desconto, freq_dt_insert, freq_st_status, freq_dt_hr_envio FROM dbo.freq_int_gevito WHERE freq_st_status = 0', conn)
        df = df.sort_values(by='freq_cd_fnc', ascending=False)

        falha_matriculas = ""

        if len(df.index) > 0:       

            if cd_emp == 0:
                nome_arquivo = 'C:/Users/0172/Documents/Projetos/Python/Integrações/Frequencia/origem frequencia/Acessos/token-pla.txt'
            elif cd_emp == 1: 
                nome_arquivo = 'C:/Users/0172/Documents/Projetos/Python/Integrações/Frequencia/origem frequencia/Acessos/token-ln.txt'
            elif cd_emp == 2:
                nome_arquivo = 'C:/Users/0172/Documents/Projetos/Python/Integrações/Frequencia/origem frequencia/Acessos/token-exp.txt'

            if not os.path.exists(nome_arquivo):
                with open(nome_arquivo, 'w') as arquivo:
                    arquivo.write('')
            
            with open(nome_arquivo, 'r') as arquivo:
                token = arquivo.readline().strip()

            headersrov = {
                "Content-Type": "application/json",
                "X-CSRF-TOKEN": "",
                "accept": "application/json",
                "Authorization":  "Bearer " + token
            }
            
            self.verificar(headersrov) 

            with open(nome_arquivo, 'r') as arquivo:
                token = arquivo.readline().strip()
                
            headersrov['Authorization'] = "Bearer " + token

            urlfreq = "http://hml.folhapontoaponto.com.br/api/v2/frequencias"

            self.progress['value'] += 10
            self.progress.update_idletasks()

            y = int(len(df.index) / 300) + 1
    
            for x in range(y):
                dffreq = pd.read_sql('SELECT top 300 freq_tp_operacao, freq_cd_fnc, freq_dt_frequencia, freq_dt_competencia, freq_hr_inicial, freq_hr_fim, freq_hr_extra, freq_hr_adicional_noturno, freq_hr_intervalo, freq_hr_bonificacao, freq_hr_atraso, freq_hr_trabalhadas_total, freq_hr_normal, freq_hr_noturnas, freq_dt_remuneracao, freq_hr_extras_50, freq_hr_extras_100, freq_hr_desloca, freq_hr_adic_noturno, freq_qtd_ticket, freq_hr_ini_int4, freq_hr_fim_int4, freq_dsc_item, freq_nu_ordem, freq_hr_trabalhada, freq_hr_desconto, freq_dt_insert, freq_st_status, freq_dt_hr_envio FROM dbo.freq_int_gevito WHERE freq_st_status = 0', conn)
                dffreq = dffreq.sort_values(by='freq_cd_fnc', ascending=False)
                payloads = {}

                for index, row in dffreq.iterrows():
                    tp_ope          = row['freq_tp_operacao']
                    cd_fnc          = str(row['freq_cd_fnc'])
                    dt_freq         = row['freq_dt_frequencia'].strftime("%Y-%m-%d")
                    dt_comp         = row['freq_dt_competencia'].strftime("%Y-%m-%d")
                    hr_ini          = row['freq_hr_inicial'].strftime("%Y-%m-%d %H:%M:%S")
                    hr_fim          = row['freq_hr_fim'].strftime("%Y-%m-%d %H:%M:%S")
                    hr_ext          = row['freq_hr_extra'].strftime("%H:%M:%S")
                    hr_adic_not     = row['freq_hr_adicional_noturno'].strftime("%H:%M:%S")
                    hr_int          = row['freq_hr_intervalo'].strftime("%H:%M:%S")
                    hr_boni         = row['freq_hr_bonificacao'].strftime("%H:%M:%S")
                    hr_atraso       = row['freq_hr_atraso'].strftime("%H:%M:%S")
                    hr_trab_total   = row['freq_hr_trabalhadas_total'].strftime("%H:%M:%S")
                    hr_normal       = row['freq_hr_normal'].strftime("%H:%M:%S")
                    hr_not          = row['freq_hr_noturnas'].strftime("%H:%M:%S")
                    hr_remuneracao  = row['freq_dt_remuneracao'].strftime("%H:%M:%S")
                    hr_ext_50       = row['freq_hr_extras_50'].strftime("%H:%M:%S")
                    hr_ext_100      = row['freq_hr_extras_100'].strftime("%H:%M:%S")
                    hr_desloc       = row['freq_hr_desloca'].strftime("%H:%M:%S")
                    hr_hr_not       = row['freq_hr_adic_noturno'].strftime("%H:%M:%S")
                    hr_qtd_ticket   = str(row['freq_qtd_ticket'])
                    hr_ini_int4     = row['freq_dt_frequencia'].strftime("%H:%M:%S")
                    hr_fim_int4     = row['freq_dt_frequencia'].strftime("%H:%M:%S")
                    desc_item       = row['freq_dsc_item']
                    veiculo         = row['freq_nu_ordem']
                    hr_trab         = row['freq_hr_trabalhada'].strftime("%H:%M:%S")
                    hr_descont      = row['freq_hr_desconto'].strftime("%H:%M:%S")

                    ano = row['freq_dt_frequencia'].strftime("%Y")
                    mes = row['freq_dt_frequencia'].strftime("%m")
                    dia = row['freq_dt_frequencia'].strftime("%d")

                    freq_hr_envio = dt.datetime.now().strftime("%d/%m/%Y %H:%M:%S")
                    dt_freq_upd = row['freq_dt_frequencia'].strftime("%d/%m/%Y")
                    attflag = f"UPDATE dbo.freq_int_gevito SET freq_st_status = 1, freq_dt_hr_envio = '{freq_hr_envio}' WHERE freq_cd_fnc = {cd_fnc} and freq_dt_frequencia = '{dt_freq_upd}'"
                    
                    if tp_ope == "D":
                        urldel = f"https://folhapontoaponto.com.br/api/v2/frequencias/{cd_fnc}/{ano}/{mes}/{dia}"
                        resposta = requests.request("POST", urldel, headers=headersrov)

                    payload = {
                        'codigo_funcionario':       cd_fnc,
                        'data_frequencia':          dt_freq,
                        'data_competencia':         dt_comp,
                        'hora_inicial':             hr_ini,
                        'hora_final':               hr_fim,
                        'hora_extra':               hr_ext,
                        'hora_adicional_noturno':   hr_adic_not,
                        'hora_intervalo':           hr_int,
                        'hora_bonificacao':         hr_boni,
                        'hora_atraso':              hr_atraso,
                        'horas_trabalhadas_total':  hr_trab_total,
                        'horas_normal':             hr_normal,
                        'remuneracao':              hr_remuneracao,
                        'horas_extras_50':          hr_ext_50,
                        'horas_extras_100':         hr_ext_100,
                        'desloca':                  hr_desloc,
                        'adicional_noturno':        hr_hr_not,
                        'ticket':                   hr_qtd_ticket,
                        'hora_inicio_intervalo4':   hr_ini_int4,
                        'hora_fim_intervalo4':      hr_fim_int4,
                        'item':                     desc_item,
                        'veiculo':                  veiculo,
                        'horas_trabalhadas':        hr_trab,
                        'hora_desconto':            hr_descont
                    }
                    # conn.cursor().execute(attflag).commit()
                    payloads[index] = payload

                resposta = requests.request("POST", urlfreq, json=payloads, headers=headersrov)

                if resposta.status_code != 200:
                    falha_matriculas += str(cd_fnc) + ", "
                    attflag2 = f"UPDATE dbo.freq_int_gevito SET freq_st_status = 99 WHERE freq_st_status = 1"
                    # conn.cursor().execute(attflag2).commit()
                    
                else:
                    updfim = "UPDATE dbo.freq_int_gevito SET freq_st_status = 2 WHERE freq_st_status = 1"
                    # conn.cursor().execute(updfim).commit()

                    updrefresh = "UPDATE dbo.freq_int_gevito SET freq_st_status = 0 WHERE freq_st_status = 99"
                    # conn.cursor().execute(updrefresh).commit()

                self.progress['value'] += 90 / y
                self.progress.update_idletasks()

            conn.close()
            if falha_matriculas != "":
                falha_matriculas = falha_matriculas.rstrip(", ")
                self.mensagem["text"] = "Falha na matrícula: "  + falha_matriculas
            else:
                self.mensagem["text"] = "Todos os dados foram enviados com sucesso."  
        else:           
            conn.close() 
            for c in range(2):
                self.progress['value'] += 50
                self.progress.update_idletasks()
                time.sleep(0.2)                

            self.mensagem["text"] = "Não foi encontrado dados"  

        

        self.mensagem["font"] = ("Arial", 10, "bold")
        self.running = False
        self.direito["text"] = "Fim: "+ str(time.strftime("%H:%M:%S", time.localtime(self.elapsed_time + self.start_time)))
        self.direito.update_idletasks()
        self.progress.destroy()
        self.autenticar = Button(self.segundoContainer, text="Ok", font=('Arial',8), width=12, command=self.encerrar)
        self.autenticar.pack(pady=0)
        
root = tk.Tk()
tela(root)
Application(root)
root.mainloop()

# %%
