---
marp: true
theme: default
paginate: true
title: "SGA-Func — Programação Funcional em Haskell"
---

# SGA-Func
## Sistema de Gestão Acadêmica Funcional

Haskell • IHP 1.6 • PostgreSQL • HSX (SSR)

**Projeto de Programação Funcional**

---

# Arquitetura

**Front Controller → Controller → Funções puras → Banco → Views HSX**

- IHP organiza rotas e ações de CRUD.
- PostgreSQL persiste estudantes, disciplinas, matrículas e avaliações.
- HSX gera HTML no servidor.
- Funções puras de validação e autorização deixam regras testáveis.

---

# Segurança: hash ≠ criptografia

- **Senha:** hash salgado usando `hashPassword` do IHP / `pwstore-fast`.
- **Nota confidencial:** campo `BYTEA` cifrado com `pgcrypto` (AES-256).
- Chave fornecida pelo ambiente: `SGA_ENCRYPTION_KEY`.
- A senha não pode ser recuperada do hash; a nota pode ser decifrada com a chave.

---

# Sessões e autorização

| Perfil | Leitura de disciplinas | Leitura de estudantes | Alterações | Dashboard |
|---|---|---|---|---|
| Administrador | Sim | Sim | Sim | Sim |
| Professor | Sim | Sim | Não | Sim |
| Aluno | Sim | Próprio cadastro | Não | Não |

**Proteção server-side**: esconder botões não é controle de acesso.

---

# Funções puras + tipos algébricos

```haskell
primeiraNota :: [Double] -> Maybe Double
primeiraNota [] = Nothing
primeiraNota (x:_) = Just x

validarNota :: Double -> Either String Double
validarNota nota
    | nota < 0 = Left "Nota negativa"
    | nota > 10 = Left "Acima de 10"
    | otherwise = Right nota
```

- `Maybe`: ausência de valor.
- `Either`: erro ou valor validado.

---

# Functor, Reader e IO

- `fmap (+ 1) (Just 7) == Just 8`: transformação preservando estrutura.
- `Reader Configuracao`: ambiente/configuração sem estado global mutável.
- `IO`: efeitos de console e banco isolados nas bordas da aplicação.
- `CPS`: funções que recebem a continuação do cálculo.

`lib/MonadsFunctorsCPS.hs` contém os exemplos do projeto.

---

# Dashboard acadêmico

- Contagem de estudantes, disciplinas e matrículas.
- Média das notas existentes.
- Ranking de disciplinas por média.
- Filtro por período acadêmico.
- Agregação por SQL tipado no PostgreSQL.
- Atualização por formulário HTTP (SSR), sem Miso/Obelisk.

---

# Demonstração prática

1. Abrir uma rota protegida sem login.
2. Entrar e sair do sistema.
3. Tentar acesso indevido como professor e aluno.
4. Salvar anotação privada e conferir ciphertext no banco.
5. Filtrar ranking por período no dashboard.
6. Demonstrar `Maybe`, `Either`, `Reader` e `fmap` no GHCi.

**Preparação completa:** `docs/DEMO-SEGURANCA-MONADS.md`.

---

# Validação e limitações

- Executar `nix flake check --impure` e testar rotas.
- HTTPS, cookies, CSRF e gestão de chaves exigem validação antes de produção.
- Não há cadastro público, recuperação de senha por e-mail ou MFA.
- Este projeto usa **HSX SSR**; não declara integração Miso/Obelisk.
- O trabalho deve ser apresentado com as funcionalidades que passaram nos testes.

---

# Obrigado!

**Repositório:** dev-leodiogenes/sga-func

Projeto focado em composição funcional, testes de funções puras, segurança server-side e interfaces renderizadas em Haskell.
