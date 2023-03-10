docker run --name postgres_arbitr \
           --detach \
           --restart=always \
           --publish 5432:5432 \
           --env POSTGRES_DB=arbitr \
           --env POSTGRES_USER=arbitr \
           --env POSTGRES_PASSWORD=arbitr \
           postgres:latest
