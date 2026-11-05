# Checklist de verificação da entrega

## Verificação local obrigatória
- [ ] Executar `nix flake check --impure` com Nix, PostgreSQL e o schema atualizado.
- [ ] Validar login, logout, falha de login, bloqueio após tentativas incorretas.
- [ ] Confirmar `admin` faz CRUD e `professor` recebe 403 para alterações.
- [ ] Confirmar `aluno` recebe 403 ao abrir o cadastro de outro estudante.
- [ ] Confirmar chave `SGA_ENCRYPTION_KEY` configurada; salvar/ler/corrigir anotação confidencial e verificar ciphertext no banco.
- [ ] Confirmar que uma operação sem chave falha em vez de gravar nota em texto puro.
- [ ] Confirmar SSR de Estudantes, Disciplinas, Login e Dashboard.
- [ ] Confirmar total e média do dashboard em cenários vazio e com notas e múltiplos períodos.
- [ ] Confirmar que não há segredos rastreados por Git e que HTTPS está ativo no deploy.

## Escopo
Autenticação de sessão IHP; RBAC server-side; dados privados cifrados em repouso; HSX SSR e dashboard. Miso/Obelisk não foram adicionados porque o projeto já usa IHP/HSX SSR.
Nenhum dos itens acima deve ser considerado verificado só pela presença dos arquivos: execute o teste completo antes do merge.
