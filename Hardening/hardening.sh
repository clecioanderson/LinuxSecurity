#!/bin/sh

#  hardening.sh
#  LinuxSecurity
#
#  Created by Clecio Ferreira on 15/06/2018.
#

####  Localizar Servicos Desnecessarios ####

dpkg -l | awk '{print $2,$3}' | sed "1,5d" > /tmp/servicosinstalados.lst

### Localizar arquivos com SUID, SGID e STICKY bit ativados ###

echo "Localizando arquivos..."
find / -perm 4000 > /tmp/listarquivos_suid.lst
find / -perm 2000 > /tmp/listarquivos_sgid.lst
find / -perm 1000 > /tmp/listarquivos_sticky.lst
read acao
case $acao in
s|S)
chmod -Rv -s /
echo "Permissoes suid bit removidas"
sleep 2
exit;;
N|n)
exit;;
*)
echo "Opcao Invalida!!"
sleep 3
exit;; esac

### Montar Disco com Opções seguras ###

case $1 in
start|Start|START)
mount -o remount,rw,exec /tmp
mount -o remount,rw,exec /var
echo "Partições /var /tmp com permissões de execução"
exit 0
;;
stop|Stop|STOP)
mount -o remount,rw,noexec,nosuid /tmp
mount -o remount,rw,noexec,nosuid /var
echo "Partições /var /tmp com permissões de execução"
exit 0
;;
*)
echo "Erro! Use $0 {start|stop}"
esac

### Editar inittab - Desabilitar opcoes inseguras [ /etc/inittab ]###

#Substituir essa linha
# ca:12345:ctrlaltdel:/sbin/shutdown -t1 -a -r now

#Por essa linha
# ca:12345:ctrlaltdel:/bin/echo "Opcao Desabilitada!"

#Para atualizar o inittab sem a necessidade de reinicializar executar o comando abaixo
# init q

### Limitar o tempo maximo da sessão no terminal variavel TMOUT ###

# Para habilitar essa variavel editamos o arquivo /etc/profile e adicionamos os comandos abaixo:
#
# TMOUT=10 #[Tempo em Segundos]
# export TMOUT
#
# Com isso apos 10 segundos de inatividade o terminal encerrara a sessao automaticamente
#
# Comando para reler a configuracao do arquivo /etc/profile
# source /etc/profile
#

### Restringir o login de root nos terminais locais ####

# Podemos editar o arquivo /etc/securetty e comentar todos os terminais onde não desejamos
# que o usuário root consiga fazer o login
#
#
# #tty1
# #tty2
# #tty3
# #tty4
# #tty5
# #tty6

### Controlar expiração de contas de usuários [ chage ] ######

# O comando chage -l lista informações da conta de usuário
# chage -M 30 -W 5 -I 2 usuario
#
# O comando acima mantem a conta valida por 30 dias, passado esse tempo, se a conta ficar sem utilização
# por 2 dias é automaticamente bloqueada. O usuario receberá 5 dias antes o aviso que sua senha expirará.
#
# Script para aplicar politica de senha a todos usuarios
#
for usuarios in $(getent passwd| awk -F: ' $3 >= 1000 {print $1}');
do
chage -M 30 -W 5 -I 2 $usuarios
done

### Restringir o acesso ao Shell para usuarios ###
#
# É uma boa prática procurar usuários que não precisam de shell e remover conforme necessário
# esse acesso a shell

for usuarios in $(getent passwd | awk -F: '{print $1}' | grep -v root | grep -v [outros usuarios])
do
usermod -s /bin/false $usuarios
done

# É possível automatizar o comportamento de não atribuição de Shell a todos usuários criados
# por adicionar essa configuração no arquivo /etc/adduser.conf
#
# DSHELL=/bin/false
#
# Podemos ainda limitar o acesso de todo usuario criado a apenas seu próprio diretório
# DIR_MODE=0750
#

### Usar PAM para gerenciar autenticação de usuários #####
#
# Os módulos PAM tornam a vida do administrador mais simples, por permitir que o uso de aplicações
# no sistema operacional seja restringido com base em regras específicas de complexidade de senha,
# entre outras opções, além de tirar a responsabilidade de autenticação e outras verificações das aplicações
# compatíveis.
#
# --- Se precisarmos por exemplo restringir o horário no qual o login num servidor é permitido podemos
# fazer isso usando o módulo pam_time.so . Precisamos editar o arquivo /etc/pam.d/login conforme abaixo:
#
# account requisite pam_time.so
#
# Precisamos ainda no arquivo /etc/security/time.conf alterar conforme abaixo:
#
# login;*;nomedousuario;Al0800-1800
# login;*;nomedousuario;!SaSu0000-2400
#
# Na configuração acima estamos restringindo o login do usuário em todos os terminais (*) para todos os dias
# de 08 as 18, exceto nos finais de semana, onde o login não será permitido.
#
#
# --- Podemos ainda por exemplo limitar a quantidade de logins simultâneos máximos para um determinado usuário
# Para isso precisamos editar o arquivo /etc/pam.d/login conforme abaixo:
#
# session required pam_limits.so
#
# Em seguida precisaremos editar o arquivo /etc/security/limits.conf conforme abaixo:
#
# nomedousuario hard maxlogins 2
#
# --- Podemos ainda limitar os usuários que poderão usar o comando su no sistema editando o arquivo
# /etc/pam.d/su conforme abaixo:
#
# auth required pam_wheel.so groups=admins
#
# Sempre que habilitamos o SU seria interessante deixamos o arquivo de log padrão do utilitário ativado
# como forma de rastreamento das atividades que são executadas nesse modo. Para habilitarmos o log do comando
# SU precisamos ativar no arquivo /etc/login.defs a variável SULOG_FILE conforme abaixo
#
# SULOG_FILE /var/log/sulog
#
# --- Podemos definir uma politica de complexidade de senha para todos os usuários conforme abaixo.
# Para isso precisamos instalar o módulo libpam-cracklib e em seguinda editar o arquivo /etc/pam.d/common-pass
# word conforme abaixo:
#
# password require pam_cracklib.so retry=3 minlen=8 difok=3
#
# Na configuração acima o usuário será forçado a criar uma senha com no mínimo 8 caracteres onde pelo menos 3
# caracteres diferentes dos usados na antiga senha e terá até 3 tentativas para concluir a alteração da senha
#
#### Implementar PortKnocking #####
#
# O Portknocking é uma técnica que permite validação de portas, como uma batida de portas, antes de liberar
# o acesso a um serviço especificado via firewall iptables.
#
# Por exemplo se eu desejo usar o SSH remotamente posso configurar uma combinação de portas que liberará o
# acesso SSH. Para realizar essas configurações podemos instalar o daemon knockd e em seguida realizar algumas
# configurações conforme abaixo:
#
# apt-get install knockd
#
# No arquivoo /etc/knockd.conf precisamos definir a combinação de portas que usaremos para habilitar o acesso
# a um determinado serviço:
#
# [OpenSSH]
# sequence = 5409,4930,6909
# sec_timeout = 5
# command = /sbin/iptables -A INPUT -s %IP% -p tcp --dport 55000 -j ACCEPT
# tcpflags = syn
#
# [CloseSSH]
# sequence = 6909,4930,5409
# sec_timeout = 5
# command = /sbin/iptables -D INPUT -s %IP% -p tcp --dport 55000 -j ACCEPT
# tcpflags = syn
#
# Será necessário ainda adicionar duas linhas no arquivo /etc/default/knockd
#
# START_KNOCKD=1
# KNOCKD_OPTS="-i eth0"
#
# Agora precisamos reiniciar o serviço knockd para carregar as configurações realizadas e recusar todas as
# conexões no firewall iptables. De agora em diante o knockd se encarregará de permitir ou não o acesso aos
# serviços via firewall.
#
# Na máquina cliente você precisará ainda instalar o agente knockd para que seja possível ativar as portas
# configuradas para liberação da conexão no servidor onde o knockd foi instalado
#
# knockd 192.168.200.5 5409 4930 6909
#
#### Localizar senhas fracas ######
#
# Podemos usar o programa John the Ripper para localizar senhas fracas então
# solicitar que os usuários alterem conforme necessário
#
# wget http://www.openwall.com/john/j/john-1.8.0-jumbo-1.tar.gz
#
# ./john /etc/shadow # para realizar um processamento de senhas fracas
# ./john --wordlist=lista /etc/shadow # para realizar um processamento de senhas fracas
# ./john --show /etc/shadow  # para exibir senhas fracas já encontradas
# ./john --restore  # Para continuar um processamento inacabado
#
# http://openwall.com/john/doc/EXAMPLES.shtml
#
##### Precisamos checar os serviços ativos na maquina ########
#
# cat /etc/services
# netstat -ntlp
# netstat -nulp
# netstat -an
#
# Precisamos ainda checar quais usuários estão executando os serviços que estão sendo usados
# precisamos instalar o pacote psmisc. Entre os serviços em execução podemos ter algum que não
# seja amplamente conhecido o que ensejaria a necessidade de checar se não é um serviço forjado
#
# apt-get install psmisc
#
# Podemos executar o comando abaixo que retornará o processo que executa o serviço relacionad
# fuser -v 65123/tcp
#
# Com a informação do processo relacionado podemos agora checar no /proc as informações do processo
# e assegurar de que não é um programa forjado
#
# cat /proc/3493/cmdline
#
# Para listar raw sockets podemos usar o comando abaixo
#
# netstat -nlpw
#
#### Verificar portas remotas de outros servidores #####
#
# nmap -sU endereçoIP # para listar/escanear portas UDP
# nmap -sT endereçoIP # para listar/escanear portas TCP
# nmap -sT -p porta endereçoIP # para listar/escanear porta TCP especifica
# nmap -O endereçoIP # para exibir informações do sistema operacional
#
#### Desativando serviços desnecessários ########
#
# Podemos inicialmente listar todos os serviços existentes sendo iniciados com o boot do sistema:
# ls -ls /etc/rc2.d/
#
# insserv -f nomedoservico remove
#
#### Configurações de Segurança para o GRUB #####
# Através do GRUB é possível alterar a senha do administrador do servidor
# Podemos evitar que usuários não autorizados tenham acesso a essa função ao implementar
# uma senha segura para o GRUB
#
# (echo senha ; echo senha) | grub-mkpasswd-pbkdf2 >> /etc/grub.d/00_header
# vim /etc/grub.d/00_header
#
# Após gerar a senha para o grub adicione as linhas abaixo no final de sua configuração do GRUB
#
# CAT << EOF
# set superusers="4linux"
# password_pbkdf2 4linux
# grub.pbkdf2.sha512.10000XXXXXXXXX.<hash>
# EOF
#
# Após finalizar as alterações no arquivo execute os comandos abaixo para validar as alterações
#
# update-grub
# reboot
#

