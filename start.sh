docker-compose up --force-recreate --build
# docker run -it \
#   -e MONGO_INITDB_ROOT_USERNAME=mongoadmin \
#   -e MONGO_INITDB_ROOT_PASSWORD=secret123 \
#   -v $PWD/etc/mongo:/etc/mongo \
#   -v $PWD/data/db:/data/db \
#   -p 27017:27017 \
#   mongo-single-replica