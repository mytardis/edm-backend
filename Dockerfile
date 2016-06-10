FROM elixir:1.2
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get update && apt-get install -y \
    postgresql-client \
    nodejs
COPY . /code/
WORKDIR /code
RUN mix local.hex --force
RUN mix deps.get
RUN mix deps.compile
RUN mix compile
RUN npm install
#CMD mix phoenix.server
#CMD mix run
CMD bash
