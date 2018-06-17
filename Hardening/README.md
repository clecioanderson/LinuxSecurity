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
