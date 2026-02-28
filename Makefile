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
	${EXEC} yarn

vite:
	$(EXEC) bin/vite dev -- --host 0.0.0.0 --port 3036 -l info

logs:
	${COMPOSE_CMD} logs -f --tail 1000 app

teste:
	$(EXEC) bundle exec rspec

teste_coverage:
	$(EXEC) bundle exec rspec --format progress

lint:
	$(EXEC) bundle exec rubocop

lint_fix:
	$(EXEC) bundle exec rubocop -a