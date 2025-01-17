# Comandos git para revisar (ignore a extensão .t do arquivo)

# Configurar Git
git config --global user.name "Seu Nome"
git config --global user.email "seu-email@example.com"

# Gerar chave SSH e configurar (opcional, mas recomendado)
ssh-keygen -t ed25519 -C "seu-email@example.com"
ssh-add ~/.ssh/id_ed25519/

# Clonar repositório
git clone git@github.com:usuario/repositorio.git
cd repositorio

# Verificar/Adicionar remote (se necessário)
git remote -v
git remote add origin git@github.com:usuario/repositorio.git

# Criar branch, trabalhar e commitar
git checkout -b meu-branch
git add .
git commit -m "Descrição clara das alterações"

# Atualizar e enviar alterações
git pull origin main --rebase (opcional)
git push origin meu-branch
