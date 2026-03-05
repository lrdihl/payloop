# PAYLOOP

Sistema de assinaturas recorrentes construído com Ruby on Rails, seguindo princípios de OOP, SOLID, DDD e arquitetura modular.

---

## Sobre o projeto

O PAYLOOP gerencia planos de assinatura com cobrança recorrente mensal. Cada cliente escolhe um plano, uma forma de pagamento e um dia de vencimento. O sistema gera cobranças automaticamente, processa os pagamentos, realiza retentativas em caso de falha e garante que nenhum cliente seja cobrado duas vezes no mesmo período.

A arquitetura foi pensada para ser extensível: novas formas de pagamento (Pix, cartão parcelado, gateways externos, etc.) podem ser adicionadas sem modificar o código existente — seguindo o princípio Open/Closed do SOLID.

---

## Stack

- **Ruby** 4.0.1
- **Rails** ~> 8.0.4
- **SQLite3** (banco de dados)
- **Puma** (servidor web)
- **Vite Rails** (frontend build)
- **Devise** (autenticação)
- **Alba** (serialização / presenters)
- **Solid Cache / Queue / Cable** (jobs, cache e websockets via banco)
- **RSpec** + **FactoryBot** + **Faker** (testes)
- **SimpleCov** (cobertura de testes)
- **Brakeman** + **RuboCop** (análise estática e lint)
- **Docker** + **Docker Compose** (containerização)

---

## Pré-requisitos

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Make](https://www.gnu.org/software/make/)

---

## Instalação e configuração

Clone o repositório e copie o arquivo de variáveis de ambiente:

```bash
git clone https://github.com/seu-usuario/payloop.git
cd payloop
cp .env.example .env
```

Faça o build da imagem, prepare o banco e popule com dados iniciais:

```bash
make setup
```

---

## Rodando o projeto

Suba os containers em background:

```bash
make start
```

Em outro terminal, inicie o servidor Vite para o frontend:

```bash
make vite
```

A aplicação estará disponível em [http://localhost:3000](http://localhost:3000).

---

## Comandos disponíveis

| Comando | Descrição |
|---|---|
| `make setup` | Build + banco + seed (primeira vez) |
| `make start` | Sobe os containers em background |
| `make stop` | Para os containers |
| `make bash` | Abre shell no container da aplicação |
| `make logs` | Exibe os logs da aplicação |
| `make deps` | Instala gems e pacotes JS |
| `make db_prepare` | Cria/migra o banco de dados |
| `make db_seed` | Popula o banco com dados iniciais |
| `make db_reset` | Recria o banco do zero |
| `make teste` | Roda a suíte de testes com RSpec |
| `make teste_coverage` | Roda testes com relatório de cobertura detalhado |
| `make lint` | Analisa o código com RuboCop |
| `make lint_fix` | Corrige automaticamente as ofensas do RuboCop |
| `make ci` | Roda RuboCop + Zeitwerk + Brakeman + RSpec em sequência |
| `make clean` | Remove containers, volumes e imagens locais |

---

## Usuários de desenvolvimento

Após rodar `make setup` (ou `make db_seed`), os seguintes usuários já estão disponíveis:

| Role | E-mail | Senha |
|---|---|---|
| Admin | `admin@payloop.dev` | `senha@123` |
| Customer | `customer@payloop.dev` | `senha@123` |

> O seed é idempotente — pode ser executado várias vezes sem duplicar registros.

---

## Testes

```bash
make teste
```

Para visualizar a cobertura de testes:

```bash
make teste_coverage
```

A cobertura mínima exigida é de **90%**. O SimpleCov gera um relatório em `coverage/index.html` após cada execução.

---

## CI/CD

### Integração Contínua (CI)

Todo Pull Request aberto para a branch `main` passa obrigatoriamente pelos seguintes checks antes de poder ser mergeado:

| Check | Ferramenta | O que valida |
|---|---|---|
| Lint | RuboCop | Estilo e consistência do código |
| Security | Brakeman | Vulnerabilidades de segurança no código Rails |
| Autoload | Zeitwerk | Convenções de nomeação e carregamento de arquivos |
| Testes | RSpec | Suíte completa de testes |
| Cobertura | SimpleCov | Cobertura mínima de 90% |
| Dependências | Dependency Review | Vulnerabilidades críticas introduzidas no PR |

A branch `main` está protegida — push direto é bloqueado para todos. Todo código passa pelo CI antes de ser mergeado.

### Antes de abrir um PR

Rode o CI localmente para garantir que tudo passa:

```bash
make ci
```

Se o RuboCop apontar ofensas, corrija automaticamente com:

```bash
make lint_fix
```

### Entrega Contínua (CD)

O deploy é automático: ao mergear um PR na `main`, o GitHub Actions dispara o deploy no Render via webhook. O fluxo completo é:

```
PR mergeado na main
      ↓
GitHub Actions dispara o webhook do Render
      ↓
Render faz o build da imagem Docker (stage production)
      ↓
Migrations rodam automaticamente via bin/docker-entrypoint
      ↓
Novo container sobe em produção
```

A infraestrutura está declarada no `render.yaml` na raiz do repositório. O ambiente de produção está disponível em [https://payloop-k2tq.onrender.com](https://payloop-k2tq.onrender.com).

### Variáveis de ambiente em produção

| Variável | Origem |
|---|---|
| `RAILS_ENV` | `render.yaml` |
| `RAILS_LOG_TO_STDOUT` | `render.yaml` |
| `RAILS_SERVE_STATIC_FILES` | `render.yaml` |
| `SECRET_KEY_BASE` | Gerado automaticamente pelo Render |
| `RAILS_MASTER_KEY` | Definido manualmente no painel do Render |
| `APP_HOST` | Definido manualmente no painel do Render |

Segredos nunca ficam no repositório — são definidos exclusivamente no painel do Render.

### Dependabot

O Dependabot monitora gems (Bundler) e actions do GitHub Actions, abrindo PRs automáticos semanalmente para manter as dependências atualizadas. PRs do Dependabot passam pelo mesmo CI antes de serem mergeados.

### O que pode evoluir quando o projeto crescer

- **Testes de sistema** — RSpec com Capybara/Selenium para fluxos críticos end-to-end
- **Cache do CI** — conforme o projeto crescer, o tempo de pipeline vai aumentar; vale adicionar cache do bundle
- **Notificação de falha** — um alerta no Slack/email quando o CI falha na main
- **Cobertura por camada** — o SimpleCov permite configurar cobertura mínima por camada (models, controllers, services) e não só global

---

## Licença

MIT
