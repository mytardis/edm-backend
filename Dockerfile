FROM elixir:1.4
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get update && apt-get install -y \
    postgresql-client \
    nodejs \
    && apt-get clean
COPY . /code/
WORKDIR /code
ENV DATABASE_ADAPTER Elixir.Ecto.Adapters.Postgres
RUN mix local.hex --force
RUN mix deps.get
RUN mix deps.compile
RUN mix compile
RUN npm install
CMD mix phoenix.server
#CMD mix run
