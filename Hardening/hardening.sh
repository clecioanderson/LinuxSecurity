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

for usuarios in $(getent passwd | awk -F: '{print $1}' | grep -v root | grep -v [outros usuarios]
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







