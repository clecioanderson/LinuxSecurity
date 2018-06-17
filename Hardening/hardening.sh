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
