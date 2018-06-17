# Hardening

1. Localizar programas desnecessários instalados e listá-los [dpkg]
    - Após localizar esses serviços poderá escolher quais manter habilitados ou desabilitar

2. Identificar arquivos com suid, sgid e sticky bit habilitados [find]
    - Uma vez com essa lista poderá decidir quais executáveis poderão manter essas permissões
    - Lembrando que essas permissões especiais (SUID BIT, especificamente) configuram uma brecha de segurança, uma vez que os executáveis que possuem tais permissões serão executados como root
3. Montar unidades de disco com opções de segurança [NOSUID, NOEXEC]
    - Editar /etc/fstab
    - Podemos aplicar tais politicas de montagem para partições mais vulneráveis a exploração por ameaças. (Ex.: /tmp /var /home)
    - Pode ser uma boa prática em ambientes onde as alterações sejam muito frequentes criar um script que possa montar/remontar as partições com as opções NOSUID, NOEXEC.
4. Desabilitar opções padrão do terminal que sejam inseguras
   - Desabilitar ctrl+alt+del no inittab (/etc/inittab)
   - Habilitar timeout de sessão de terminal por inatividade TMOUT
   - Restringir login de root nos terminais locais
   - Restringir validade de contas de usuários
5. Implementar PAM para gerenciamento de autenticação e sessões de usuários
    - Login em horários específicos
    - Restringir sessões simultâneas
    - Aplicar politica de complexidade de senhas
    - Controle de uso do comando SU
6. Localizar senhas fracas [ John the Ripper ]
7. Verificar serviços ativos
   
