#%%
import tkinter as tk
from tkinter import Frame, Label, Button
from tkinter.ttk import Progressbar
import time
import threading

def tela(root):
    root.attributes('-topmost', True)
    root.title("Integração Gevito - Frequencia") 

    largura, altura = (350),(140)
    screen_x, screen_y = (root.winfo_screenwidth()),(root.winfo_screenheight())
    posx, posy = (screen_x/2 - largura/2), (screen_y/2 - altura/2)

    root.geometry('%dx%d+%d+%d' % (largura, altura, posx, posy))

class Application:
    def __init__(self, master=None):
        self.fontePadrao = ("Arial", 10)

        self.primeiroContainer = Frame(master)
        self.primeiroContainer["pady"] = 10
        self.primeiroContainer.pack()

        self.segundoContainer = Frame(master)
        self.segundoContainer["padx"] = 20
        self.segundoContainer["pady"] = 10   
        self.segundoContainer.pack()

        self.terceiroContainer = Frame(master)   
        self.terceiroContainer.pack()

        self.titulo = Label(self.primeiroContainer, text="Dados do usuário:")
        self.titulo["font"] = ("Arial", 10, "bold")
        self.titulo.pack(side=tk.LEFT)

        self.nomeLabel = Label(self.primeiroContainer, text="Nome", font=self.fontePadrao)
        self.nomeLabel.pack()

        self.autenticar = Button(self.segundoContainer, text="Iniciar", font=self.fontePadrao, width=12)    
        self.autenticar["command"] = self.iniciar
        self.autenticar.pack()


    def iniciar(self):
        inicio = time.strftime("%H:%M:%S", time.localtime())
        self.start_time = time.time()  
    
        self.autenticar.destroy()
        self.mensagem = Label(self.segundoContainer, text="Progresso", font=self.fontePadrao)
        self.mensagem.pack()
        
        self.progress = Progressbar(self.segundoContainer, value=0, orient=tk.HORIZONTAL, length=100, mode='determinate', maximum=100)
        self.progress.pack()

       
       

        self.esquerdo = Label(self.terceiroContainer, text="Inicio: " + str(inicio) +"", font=self.fontePadrao)
        self.esquerdo.pack(side=tk.LEFT)

        self.centro = Label(self.terceiroContainer, text="meio", font=self.fontePadrao)
        self.centro.pack(side=tk.LEFT)
        self.centro["padx"] = 45

        self.running = True        
        self.update_clock()  # Inicia a atualização do cronômetro

        self.direito = Label(self.terceiroContainer, text="Fim: -- : -- : --", font=self.fontePadrao)
        self.direito.pack(side=tk.RIGHT)

    
        thread = threading.Thread(target=self.rodar)
        thread.start()

    def update_clock(self):
        if self.running:
            elapsed_time = int(time.time() - self.start_time)

            hours, remainder = divmod(elapsed_time, 3600)
            minutes, seconds = divmod(remainder, 60)
            self.centro["text"] = f"{hours:02}:{minutes:02}:{seconds:02}"
            self.centro.update_idletasks()
            self.centro.after(1000, self.update_clock)


    def rodar(self):
        repeticoes = 10
        for i in range(repeticoes):
            time.sleep(0.5)  # Simula uma tarefa longa
            self.progress['value'] += 100 / repeticoes
            self.progress.update_idletasks()
        
        
        self.mensagem["text"] = "Finalizado com sucesso"  
        self.running = False
        self.direito["text"] = "Fim: "+ str(time.strftime("%H:%M:%S", time.localtime()))
        
        self.progress.destroy()
        self.segundoContainer["pady"] = 5
        self.autenticar = Button(self.segundoContainer, text="Ok", font=('Arial',8), width=12, command=self.encerrar)
        self.autenticar.pack(pady=3)
    
    def encerrar(self):
        root.destroy()

root = tk.Tk()
tela(root)
Application(root)
root.mainloop()

