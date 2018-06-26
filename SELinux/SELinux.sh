#!/bin/sh

#  SELinux.sh
#  LinuxSecurity
#
#  Created by Clecio Ferreira on 25/06/2018.
#
# SELinux é um projeto desenvolvido pela NSA visa a implementação
# de um sistema operacional seguro.
#
# A segurança implementada em um sistema linux padrão basea-se no
# no conceito de DAC (Discricionary Access Control). Onde o usuário
# recebe acesso a um recurso com base em seu usuário e senha. O ponto
# de falha consiste nas contas administrativas. Uma vez alguém consi
# ga acesso a uma dessas contas, automaticamente terá acesso a todo
# o sistema de arquivos.
#
# O SELinux implementa um novo conceito de controle de acesso chama
# do MAC (Mandatory Access Control). Nesse modelo um grupo de polí
# ticas é aplicado ao serviço. Isso tornará mais difícil que o siste
# ma de arquivos fique exposto em casos de comprometimento de contas
# de usuários.
#
#######   Instalar o SELinux ###############

# aptitude install selinux-basics

# Uma vez instalado poderá checar o status do serviço com o comando
# abaixo:

# sestatus

####### Modos de Operação SELinux ############
#
# Enforcing [Efetivo]: Bloqueia tudo que não for explicitamente
# permitido no sistema.
#
# Permissive [Permissivo]: Ao invés de bloquear as atividades não
# autorizadas jogará em arquivo todas as violações.
#
# Disabled [Desativado]: Serviço inoperante. Desativado.
#

########## Ativando o SELinux ####################
#
# Para alterar o modo de operação padrão do SELinux podemos
# editar o arquivo /etc/selinux/config adicionando a diretiva

# SELINUX=enforcing #(permissive|disabled)

# Será necessário ainda habilitar o SELinux no PAM para todos os
# usuários conforme abaixo:

# echo "session required    pam_selinux.so  multiple" >> /etc/pam/lo
# gin

# Precisaremos ainda reconfigurar o fsck durante o boot do linux
# editando o arquivo /etc/default/rcS adicionando a diretiva abaixo

# set FSCKFIX=yes

# Em seguida, no mesmo arquivo adicionamos uma medida protetiva para
# o arquivo /etc/motd. A diretiva:

# EDITMOTD=no

# Apos aplicar as alterações acima no sistema será necessário
# reinicializar o servidor duas vezes para aplicação do SELinux
# em todo o sistema de arquivo.
#
# Uma outra maneira de checar o status alem do comando sestatus
# usando o comando getenfoce onde podemos exibir os valores que se
# guem:
#
# 0 - Permissive
# 1 - Enforcing
#
# Apos checar o status atual, podemos altera-lo usando o comando

# setenforce 0|1
#




