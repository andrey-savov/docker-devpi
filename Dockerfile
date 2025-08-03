#
FROM python:3.13-alpine
LABEL maintainer="https://github.com/andrey-savov/"

ARG ARG_DEVPI_SERVER_VERSION=6.16.0

ENV DEVPI_SERVER_VERSION=$ARG_DEVPI_SERVER_VERSION
ENV PIP_NO_CACHE_DIR="off"
ENV PIP_INDEX_URL="https://pypi.python.org/simple"
ENV PIP_TRUSTED_HOST="pypi.python.org"
ENV PYTHON_PIP_VERSION=25.2
ENV VIRTUAL_ENV=/env

# Install bash
RUN apk add --no-cache bash

# devpi user
RUN addgroup -g 1000 -S devpi \
    && adduser -D -S -u 1000 -h /data -s /sbin/nologin -G devpi devpi

# create a virtual env in $VIRTUAL_ENV, ensure it respects pip version
RUN pip install virtualenv \
    && virtualenv $VIRTUAL_ENV \
    && $VIRTUAL_ENV/bin/pip install pip==$PYTHON_PIP_VERSION
ENV PATH=$VIRTUAL_ENV/bin:$PATH

RUN pip install "devpi-server==${DEVPI_SERVER_VERSION}"

EXPOSE 3141
VOLUME /data



USER devpi
ENV HOME=/data
WORKDIR /data

CMD ["bash", "-c", "devpi-init; devpi-server --host=0.0.0.0"]
