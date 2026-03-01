EXEC=docker-compose exec app
EXEC_RUN=docker-compose run --rm --entrypoint "" app
COMPOSE_CMD=docker-compose

build:
	${COMPOSE_CMD} build --no-cache

setup: build db_prepare db_seed

start:
	$(COMPOSE_CMD) up -d

stop:
	${COMPOSE_CMD} stop

bash:
	${EXEC} /bin/sh

server:
	$(EXEC) env RUBY_DEBUG_OPEN=true bin/rails server -b 0.0.0.0

# No SQLite, o prepare cria o arquivo .sqlite3 se ele não existir
db_prepare:
	${EXEC_RUN} bin/rails db:prepare

db_seed:
	${EXEC_RUN} bin/rails db:seed

db_reset:
	${EXEC_RUN} bin/rails db:drop db:create db:migrate db:seed

clean:
	$(COMPOSE_CMD) down --rmi local --volumes --remove-orphans

deps:
	${EXEC} bundle install
	${EXEC} npm install

vite:
	$(EXEC) bin/vite dev -- --host 0.0.0.0 --port 3036 -l info

logs:
	${COMPOSE_CMD} logs -f --tail 1000 app

# Roda os testes com saída resumida
teste:
	$(EXEC) bundle exec rspec --format progress

# Roda os testes com saída detalhada + relatório de cobertura (SimpleCov)
teste_coverage:
	$(EXEC) bundle exec rspec --format documentation

lint:
	$(EXEC) bundle exec rubocop

lint_fix:
	$(EXEC) bundle exec rubocop -a

# Roda lint + Zeitwerk + security + testes em sequência — para no primeiro erro
ci:
	@echo "🔍 Rodando RuboCop...\n" && \
	$(EXEC) bundle exec rubocop --parallel --format progress && \
	echo "\n✅ RuboCop OK\n------------------\n" && \
  echo "🔍 Rodando Zeitwerk...\n" && \
	$(EXEC) bin/rails zeitwerk:check && \
	echo "\n✅ Zeitwerk OK\n------------------\n" && \
	echo "🔍 Rodando Brakeman...\n" && \
	$(EXEC) bundle exec brakeman --no-pager -q --exit-on-warn && \
	echo "\n✅ Brakeman OK\n------------------\n" && \
	echo "🔍 Rodando RSpec...\n" && \
	$(EXEC) bundle exec rspec --format progress && \
	echo "\n✅ RSpec OK"
