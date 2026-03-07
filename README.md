# PAYLOOP

Sistema de assinaturas recorrentes construído com Ruby on Rails, seguindo princípios de OOP, SOLID, DDD e arquitetura modular.

---

## Sobre o projeto

O PAYLOOP gerencia planos de assinatura com cobrança recorrente. Cada cliente escolhe um plano e uma forma de pagamento. O sistema gera cobranças automaticamente, processa os pagamentos via gateway (simulado), realiza retentativas em caso de falha e garante que nenhum cliente seja cobrado duas vezes no mesmo período.

Novas formas de pagamento podem ser adicionadas sem modificar o código existente — seguindo o princípio Open/Closed do SOLID através do `Shared::PaymentMethods::Registry`.

---

## Stack

- **Ruby** 4.0.1 / **Rails** ~> 8.1.2
- **SQLite3** — banco de dados (Solid Cache / Queue / Cable nativos)
- **Puma** — servidor web
- **Vite Rails** — frontend build
- **Devise** — autenticação (database_authenticatable, confirmable, lockable, trackable)
- **Pundit** — autorização (deny-all por padrão)
- **dry-validation / dry-monads / dry-transaction** — contratos e operações de domínio
- **Alba** — serialização / presenters
- **Solid Queue** — processamento de jobs e cron jobs (`config/recurring.yml`)
- **RSpec** + **FactoryBot** + **Faker** — testes
- **SimpleCov** — cobertura mínima de 90%
- **Brakeman** + **RuboCop** — análise estática e lint
- **Docker** + **Docker Compose** — containerização

---

## Arquitetura

O projeto segue **Domain-Driven Design (DDD)** com separação clara de responsabilidades:

```
app/
  controllers/          # Thin controllers — apenas autorização + chamada de operation
  domains/
    billing/
      contracts/        # Validação do payload do webhook
      jobs/             # BillingJob, CloseSubscriptionsJob, ChargeSubscriptionsJob
      operations/       # ProcessPayment, HandleGatewayCallback
    identity/
      contracts/        # Validação de registro e perfil
      operations/       # RegisterUser, UpdateProfile, UpdateUserRole
    plans/
      contracts/        # Validação de plano
      operations/       # CreatePlan, UpdatePlan, DiscardPlan
    shared/
      payment_methods/  # Registry + Base + CreditCard, Boleto, BankDeposit
      values/           # Money, Period (value objects)
    subscriptions/
      contracts/        # CreateSubscription, UpdatePaymentMethod
      operations/       # CreateSubscription, ActivateSubscription, FailSubscription,
                        #   CancelSubscription, CloseSubscription, RetrySubscription,
                        #   PendingSubscription, UpdatePaymentMethod
  models/               # Persistência pura + Devise + validações estruturais
  policies/             # Pundit — deny-all por padrão, permissões opt-in
```

### Padrões

| Camada | Responsabilidade |
|--------|-----------------|
| **Controller** | Autoriza via Pundit, chama uma Operation, passa o resultado para `handle_result` |
| **Operation** (dry-transaction) | Regra de negócio — retorna `Success(value)` ou `Failure({type:, errors:})` |
| **Contract** (dry-validation) | Valida shape e semântica do input antes da operation |
| **Model** | Persistência + validações estruturais + associações. Sem regras de negócio |
| **Value Object** | `Money` (cents + currency) e `Period` (count + type) — imutáveis, sem identidade |
| **Job** | Orquestra operações assíncronas (billing, cron de fechamento e cobrança) |

---

## Ciclo de vida de uma Subscription

```
                     ┌─────────────────────────────────────────┐
                     │            VALID_TRANSITIONS             │
                     └─────────────────────────────────────────┘

  pending_payment ──► active ──────────────────────────► closed
       ▲    │            │                                  ▲
       │    │            ├──► pending_payment (renovação)   │
       │    ▼            │                                  │
       │ error_payment   └──► canceled             succeeded + closed_at vencido
       │    │
       └────┘ (retry)
```

| Transição | Disparada por |
|-----------|--------------|
| `pending_payment → active` | Webhook de pagamento com `succeeded` |
| `pending_payment → error_payment` | Esgotamento de retries do `BillingJob` |
| `active → pending_payment` | `ChargeSubscriptionsJob` (renovação) |
| `active → closed` | `CloseSubscriptionsJob` ou webhook `succeeded` com `closed_at` vencido |
| `active → canceled` | Ação do admin ou cliente |
| `error_payment → pending_payment` | Retry manual (admin/cliente) |
| `error_payment → canceled` | Ação do admin |

---

## Fluxo de cobrança

```
ChargeSubscriptionsJob (00:10)
        │
        ▼
PendingSubscription  ──► subscription → pending_payment
        │
        ▼
  BillingJob.perform_later
        │
        ▼
ProcessPayment (operation)
  ├─ cria Payment (pending)
  └─ chama PaymentMethod#process(payment:)
        │
        ├── Success → Payment salvo (pending) → aguarda webhook
        └── Failure → Payment (failed) → GatewayError → retry com backoff polinomial
                                                    (até BILLING_MAX_RETRIES, default 5)
                                                    após esgotar → FailSubscription
                                                                → subscription: error_payment
```

### Webhook de callback

O gateway envia o resultado via `POST /webhooks/gateway_callbacks` autenticado com `X-Signature: Token <token>`.

`HandleGatewayCallback` operation:
- Localiza o `Payment` pelo `transaction_id`
- Idempotente — se o payment já foi processado, retorna 200 sem reprocessar
- `succeeded` → `ActivateSubscription` (ou `CloseSubscription` se `closed_at ≤ hoje`)
- `failed` → `FailSubscription`

---

## Formas de pagamento

Registradas em `Shared::PaymentMethods::Registry` via initializer (`config/initializers/payment_methods.rb`):

| Chave | Classe |
|-------|--------|
| `credit_card` | `Shared::PaymentMethods::CreditCard` |
| `boleto` | `Shared::PaymentMethods::Boleto` |
| `bank_deposit` | `Shared::PaymentMethods::BankDeposit` |

Para adicionar uma nova forma de pagamento basta criar uma classe que herda de `Base` e chama `Registry.register(:chave, self)`.

---

## Cron Jobs (Solid Queue)

Configurados em `config/recurring.yml`:

| Horário | Job | Ação |
|---------|-----|------|
| 00:00 | `CloseSubscriptionsJob` | Fecha subscriptions `active` com `closed_at == hoje` |
| 00:10 | `ChargeSubscriptionsJob` | Move para `pending_payment` subscriptions `active` com `next_due_date == hoje` e enfileira `BillingJob` |

---

## Pré-requisitos

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Make](https://www.gnu.org/software/make/)

---

## Instalação e configuração

```bash
git clone https://github.com/seu-usuario/payloop.git
cd payloop
cp .env.example .env
make setup
```

---

## Rodando o projeto

```bash
make start   # sobe os containers em background
make vite    # inicia o servidor Vite (em outro terminal)
```

A aplicação estará disponível em [http://localhost:3000](http://localhost:3000).

---

## Comandos disponíveis

| Comando | Descrição |
|---------|-----------|
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

Após `make setup` (ou `make db_seed`):

| Role | E-mail | Senha |
|------|--------|-------|
| Admin | `admin@payloop.dev` | `senha@123` |
| Customer | `customer@payloop.dev` | `senha@123` |

> O seed é idempotente — pode ser executado várias vezes sem duplicar registros.

---

## Testes

```bash
make teste
make teste_coverage   # relatório em coverage/index.html
```

Cobertura mínima exigida: **90%**.

---

## CI/CD

### Integração Contínua

Todo PR para `main` passa pelos seguintes checks:

| Check | Ferramenta | O que valida |
|-------|-----------|--------------|
| Lint | RuboCop | Estilo e consistência do código |
| Security | Brakeman | Vulnerabilidades Rails |
| Autoload | Zeitwerk | Convenções de nomeação |
| Testes | RSpec | Suíte completa |
| Cobertura | SimpleCov | Mínimo de 90% |
| Dependências | Dependency Review | Vulnerabilidades críticas no PR |

```bash
make ci        # rode antes de abrir o PR
make lint_fix  # corrige ofensas do RuboCop automaticamente
```

### Entrega Contínua

Merge na `main` → GitHub Actions → deploy automático no Render via webhook.

```
PR mergeado na main → build Docker (production) → migrations → novo container em produção
```

### Variáveis de ambiente em produção

| Variável | Origem |
|----------|--------|
| `RAILS_ENV` | `render.yaml` |
| `SECRET_KEY_BASE` | Gerado automaticamente pelo Render |
| `RAILS_MASTER_KEY` | Painel do Render |
| `APP_HOST` | Painel do Render |
| `BILLING_MAX_RETRIES` | Painel do Render (default: `5`) |

---

## Licença

MIT
