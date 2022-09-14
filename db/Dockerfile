FROM mysql:8
LABEL description="Global database for the Avinya Foundation stack"

COPY ./api/tests/Config.toml ./tmp/Config.toml
RUN source ./tmp/Config.toml

COPY ./db/schema/*.sql ./docker-entrypoint-initdb.d/
