FROM node:lts

WORKDIR /usr/src/app/
RUN useradd --home-dir /usr/src/app -s /bin/false www && \
    chown -R www:www /usr/src/app && \
    apt-get update && \
    apt-get install -y --no-install-recommends libpoppler-glib-dev ghostscript && \
    rm -rf /var/lib/apt/lists/*
USER www:www

COPY --chown=www:www ./components/ ./
RUN for component in *; do \
      cd $component && \
      echo Doing npm i for $component && \
      npm i --progress=false --loglevel=warn 2>&1; \
      if [ $? -ne 0 ]; then \
        echo npm i for $component failed.; \
        exit 1; \
      fi; \
      cd ..; \
    done; \
    for component in *; do \
      if [ $component != maowtm.org ]; then \
        cd maowtm.org/node_modules; \
        ln -sv ../../$component $component; \
        if [ $? -ne 0 ]; then \
          echo ln for $component to maowtm.org/node_modules failed.; \
          exit 1; \
        fi; \
        cd ../..; \
      fi; \
    done;

WORKDIR /usr/src/app/maowtm.org
COPY ./launcher.docker.js ./
WORKDIR /usr/src/app/
COPY ./dev-cmd ./run ./
EXPOSE 80 443
USER root
# https://github.com/lovell/sharp/issues/892#issuecomment-319215167 :
ENV LD_LIBRARY_PATH maowtm.org/node_modules/sharp/vendor/lib/
ENV MONGODB=mongodb://mw-mongo/maowtm REDIS=mw-redis ES=mw-es:9200
STOPSIGNAL SIGTERM
HEALTHCHECK --timeout=2s CMD curl -f https://localhost/

CMD ["bash", "./run"]
