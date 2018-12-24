FROM node:lts-stretch

WORKDIR /usr/src/app/
RUN useradd --home-dir /usr/src/app -s /bin/false www && \
    chown -R www:www /usr/src/app && \
    apt-get update && \
    apt-get install -y --no-install-recommends libpoppler-glib-dev ghostscript && \
    rm -rf /var/lib/apt/lists/*
USER www:www

# Copy main package.json and build-components' package.json
COPY --chown=www:www ./components/maowtm.org/package.json ./maowtm.org/
COPY --chown=www:www ./components/schsrch/package.json ./schsrch/
COPY --chown=www:www ./components/leafvote/package.json ./leafvote/
COPY --chown=www:www ./components/fancy-lyric/package.json ./fancy-lyric/

RUN for component in *; do \
      cd $component && \
      echo Doing npm i for $component && \
      script --return -qc "npm i" /dev/null; \
      if [ $? -ne 0 ]; then \
        echo npm i for $component failed.; \
        exit 1; \
      fi; \
      cd ..; \
    done

# COPY app source
COPY --chown=www:www ./components/ ./
# Run npm i again to bulld gyp modules, webpack assets and stuff.
RUN for component in *; do \
      cd $component && \
      echo Doing npm i after copying for $component && \
      script --return -qc "npm i" /dev/null; \
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

COPY ./compression_safari.patch ./
RUN cd /usr/src/app/maowtm.org/node_modules/compression && \
    patch index.js /usr/src/app/compression_safari.patch

CMD ["bash", "./run"]
