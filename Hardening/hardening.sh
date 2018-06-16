#!/bin/sh

#  hardening.sh
#  LinuxSecurity
#
#  Created by Clecio Ferreira on 15/06/2018.
#

####  Localizar Servicos Desnecessarios ####

dpkg -l | awk '{print $2,$3}' | sed "1,5d" > /home/$USER/servicosinstalados.lst




