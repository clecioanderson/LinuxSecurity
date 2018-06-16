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
find / -perm 4000 > /tmp/listarquivos_sbit.lst




