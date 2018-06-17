# Hardening

1. Localizar programas desnecessários instalados e listá-los [dpkg]
    - Após localizar esses serviços poderá escolher quais manter habilitados ou desabilitar

2. Identificar arquivos com suid, sgid e sticky bit habilitados [find]
    - Uma vez com essa lista poderá decidir quais executáveis poderão manter essas permissões
    - Lembrando que essas permissões especiais configuram uma brecha de segurança, uma vez que os executáveis que possuem tais permissões serão executados como root
