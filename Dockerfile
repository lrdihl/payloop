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
#   nodejs/npm incluídos para suporte ao desenvolvimento local
#   e execução de scripts JS. yarn removido — projeto usa npm/Vite.
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
        nodejs \
        npm \
        tzdata \
        yaml-dev \
    && ln -fs /usr/share/zoneinfo/Brazil/East /etc/localtime \
    && addgroup -S $GROUP --gid $GID \
    && adduser  -S $USER  --uid $UID -G $GROUP --home $HOME

# ============================================================
# Stage 2 — builder
#   Instala gems + pacotes JS; resultado vai para o stage final.
#   jemalloc instalado aqui para redução de memória em runtime.
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

# Re-declara os ARGs para que os valores estejam acessíveis nos RUN abaixo.
# O ENV herdado do stage base já cobre o runtime, mas comandos RUN
# precisam dos ARGs explicitamente declarados no stage atual.
ARG RAILS_ENV
# SECRET_KEY_BASE é necessário durante o assets:precompile pois o Rails
# inicializa a aplicação nesse momento. Um valor dummy é suficiente aqui —
# o valor real vem do painel do Render em runtime.
ARG SECRET_KEY_BASE=dummy
ENV SECRET_KEY_BASE=${SECRET_KEY_BASE}

# Instala jemalloc como root, antes de trocar de usuário.
RUN apk add --no-cache jemalloc

USER $USER
WORKDIR $HOME

# Copia apenas os manifests primeiro para aproveitar o cache de camadas:
# enquanto Gemfile.lock e package-lock.json não mudarem, o Docker reutiliza
# as camadas de bundle/npm sem reinstalar tudo.
COPY --chown=$USER:$GROUP .ruby-* Gemfile* package* ./

# --global garante que a configuração persiste para o bundle install
# diferente de --local que salvaria em .bundle/config e poderia não
# ser encontrado corretamente pelo stage de produção.
RUN gem install bundler -v "$(grep -A 1 'BUNDLED WITH' Gemfile.lock | tail -n 1)" \
    && if [ "$RAILS_ENV" = "production" ]; then \
         bundle config set --global without "development:test"; \
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

# BUNDLE_WITHOUT garante que o Bundler não tenta carregar gems de
# development/test que não foram instaladas no build de produção.
ENV BUNDLE_WITHOUT="development:test" \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true

ENTRYPOINT ["bin/docker-entrypoint"]
EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]