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
| `make teste_coverage` | Roda testes com relatório de cobertura |
| `make lint` | Analisa o código com RuboCop |
| `make lint_fix` | Corrige automaticamente as ofensas do RuboCop |
| `make clean` | Remove containers, volumes e imagens locais |

---

## Testes

```bash
make teste
```

Para visualizar a cobertura de testes:

```bash
make teste_coverage
```

---

## Deploy (produção)

A imagem de produção é construída via multi-stage build. Ao fazer deploy (ex: Render), configure:

- **Build Arg:** `RAILS_ENV=production`
- **Environment Variable:** `RAILS_ENV=production`
- **Demais segredos** (`SECRET_KEY_BASE`, `DATABASE_URL`, etc.) devem ser definidos exclusivamente nas variáveis de ambiente da plataforma — nunca no repositório.

---

## Licença

MIT