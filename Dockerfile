# ============================================================
# ARGs globais (disponíveis antes do primeiro FROM)
#
# ARG = BUILD TIME: definido ao buildar a imagem.
#   Controla decisões que não podem ser mudadas depois:
#   - quais gems instalar (sem dev/test em produção)
#   - se assets serão pré-compilados
#
# Como passar:
#   Local (docker compose):  args: RAILS_ENV: development  (docker-compose.yml)
#   CI/CD (Render):          Build Arg RAILS_ENV=production no painel
#
# IMPORTANTE: RAILS_ENV também precisa ser definido como variável
# de ambiente no runtime (ENV abaixo / painel do Render), para que
# o Rails em execução saiba em qual ambiente está rodando.
# ============================================================
ARG RUBY_VERSION=4.0.1
ARG ALPINE_VERSION=3.23
ARG RAILS_ENV=development      # padrão seguro: nunca sobe prod por acidente

# ============================================================
# Stage 1 — base
#   Dependências de sistema + usuário não-root
#   Apenas o essencial para rodar o app em qualquer ambiente.
#   nodejs/npm/yarn foram movidos para o builder — não são
#   necessários em runtime (produção ou desenvolvimento).
# ============================================================
FROM ruby:${RUBY_VERSION}-alpine${ALPINE_VERSION} AS base

# Re-declara o ARG dentro do stage para torná-lo acessível aqui.
# ARGs globais não são herdados automaticamente após um FROM.
ARG RAILS_ENV

# ENV = RUNTIME: persiste na imagem e fica disponível para o processo
# que roda dentro do container (rails server, rake, etc).
#
# RAILS_ENV e NODE_ENV recebem o valor do ARG de build time, garantindo
# que build e runtime estejam sempre alinhados. Em produção, o Render
# também deve definir RAILS_ENV=production como Environment Variable
# no painel — isso reforça o valor em runtime caso a imagem seja
# reutilizada em contextos diferentes.
ENV RAILS_ENV=${RAILS_ENV} \
    NODE_ENV=${RAILS_ENV} \
    RUBY_YJIT_ENABLE=1 \
    USER=app \
    GROUP=app \
    UID=1000 \
    GID=1000 \
    HOME=/app \
    BUNDLE_PATH=/app/vendor/bundle \
    BUNDLE_JOBS=5 \
    BUNDLE_RETRY=5

RUN apk add --no-cache \
        build-base \
        libc6-compat \
        tzdata \
        yaml-dev \
    && ln -fs /usr/share/zoneinfo/Brazil/East /etc/localtime \
    && addgroup -S $GROUP --gid $GID \
    && adduser  -S $USER  --uid $UID -G $GROUP --home $HOME

# ============================================================
# Stage 2 — builder
#   Instala gems + pacotes JS; resultado vai para o stage final.
#   nodejs/npm/yarn ficam aqui — usados apenas para pré-compilar
#   assets e instalar dependências JS. Não seguem para produção.
#
#   Este stage usa $RAILS_ENV (ARG/ENV herdado do base) para
#   tomar decisões que afetam o conteúdo da imagem final:
#     - development: instala todas as gems (incluindo dev/test)
#     - production:  exclui gems de dev/test e pré-compila assets
#
#   Essas decisões SÓ podem ser feitas aqui, em build time.
#   Não é possível "trocar" o ambiente depois que a imagem foi gerada.
# ============================================================
FROM base AS builder

# Re-declara o ARG para que o valor esteja acessível nos RUN abaixo.
# O ENV herdado do stage base já cobre o runtime, mas comandos RUN
# precisam do ARG explicitamente declarado no stage atual.
ARG RAILS_ENV

# Instala jemalloc + ferramentas JS como root, antes de trocar de usuário.
# nodejs/npm/yarn são necessários apenas no builder para instalar
# dependências JS e pré-compilar assets — não seguem para os stages finais.
RUN apk add --no-cache jemalloc nodejs npm

USER $USER
WORKDIR $HOME

# Copia apenas os manifests primeiro para aproveitar o cache de camadas:
# enquanto Gemfile.lock e package.json não mudarem, o Docker reutiliza
# as camadas de bundle/yarn sem reinstalar tudo.
COPY --chown=$USER:$GROUP .ruby-* Gemfile* package* ./

RUN gem install bundler -v "$(grep -A 1 'BUNDLED WITH' Gemfile.lock | tail -n 1)" \
    && bundle config set --local path "$BUNDLE_PATH" \
    && bundle config set --local jobs "$BUNDLE_JOBS" \
    && bundle config set --local retry "$BUNDLE_RETRY" \
    # BUILD TIME: decide quais gems instalar com base no ARG RAILS_ENV.
    # Se fosse ENV (runtime), o bundle install já teria rodado com
    # todas as gems — esta otimização não funcionaria.
    && if [ "$RAILS_ENV" = "production" ]; then \
         bundle config set --local without "development test"; \
       fi \
    && bundle install \
    && npm ci

# Copia o restante do código após instalar dependências,
# para não invalidar o cache de gems a cada mudança de arquivo.
COPY --chown=$USER:$GROUP . .

# BUILD TIME: pré-compila assets somente em produção.
# Requer que RAILS_ENV=production seja passado como build arg —
# não adianta setar apenas como variável de ambiente no Render.
RUN if [ "$RAILS_ENV" = "production" ]; then \
      bundle exec rails assets:precompile; \
    fi

# ============================================================
# Stage 3 — development
#   Imagem para uso local via docker compose.
#   O docker-compose.yml aponta para este stage com: target: development
# ============================================================
FROM base AS development

USER $USER
WORKDIR $HOME

COPY --chown=$USER:$GROUP --from=builder $HOME $HOME

ENTRYPOINT ["bin/docker-entrypoint"]
EXPOSE 3000 28080

#CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

# ============================================================
# Stage 4 — production
#   Imagem para o Render e CI/CD.
#   Herda do base — sem nodejs/npm/yarn, imagem mais enxuta e
#   deploy mais rápido.
#
#   No Render, configure:
#     Build Arg:            RAILS_ENV=production  ← controla o build
#     Environment Variable: RAILS_ENV=production  ← controla o runtime
#
#   As duas configurações são necessárias e complementares:
#   o Build Arg garante gems enxutas e assets pré-compilados;
#   a Environment Variable garante que o Rails rode em modo produção.
# ============================================================
FROM base AS production

USER $USER
WORKDIR $HOME

COPY --chown=$USER:$GROUP --from=builder $HOME $HOME

# Variáveis esperadas pelo Render em runtime.
# Segredos (SECRET_KEY_BASE, DATABASE_URL, etc.) NÃO devem ficar
# aqui — devem ser definidos exclusivamente no painel do Render.
ENV RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true

ENTRYPOINT ["bin/docker-entrypoint"]
EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]