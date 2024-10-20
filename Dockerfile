ARG MONGO_VERSION=8.0.1-noble
# ARG MONGO_VERSION=8.0.1

FROM mongo:${MONGO_VERSION}

COPY ./scripts /scripts

# Start mongo in replica set mode in a background task
ENTRYPOINT ["/scripts/entrypoint.sh"]