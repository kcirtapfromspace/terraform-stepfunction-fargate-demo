ARG PYTHON_VERSION=3.9
    
# Python build stage
FROM python:${PYTHON_VERSION}-slim-bullseye as python_build
WORKDIR /opt/venv
RUN apt-get update && \
    apt-get install -y \
        gcc \ 
        python3-dev \
        libsasl2-dev \
        unixodbc-dev \
        git \
        ssh-client \
        software-properties-common \
        make \
        build-essential \
        ca-certificates \
        libpq-dev \
        --no-install-recommends && \
    apt-get clean  && \
    rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/*

COPY  ./ops/dev-stack/dbt/requirements.txt .
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN python3 -m venv $VIRTUAL_ENV && \
    $VIRTUAL_ENV/bin/python3 -m pip install -U --upgrade pip && \
    $VIRTUAL_ENV/bin/pip install --upgrade pip setuptools wheel psutil

# Python install stage
FROM  python_build as python_install
# Use buildkit to cache pip dependencies
# https://pythonspeed.com/articles/docker-cache-pip-downloads/
RUN --mount=type=cache,target=/root/.cache \ 
        $VIRTUAL_ENV/bin/python3 -m pip install -U --no-cache-dir -r requirements.txt --prefer-binary

# Final stage 
FROM gcr.io/distroless/python3-debian11:debug as final
ENV PYTHONIOENCODING=utf-8
ENV LANG=C.UTF-8
ENV PYTHON_VERSION=3.9

COPY --from=python_install /opt/venv/ /opt/venv/
COPY --from=python_install /usr/ /usr/

ENV PATH=$PATH:/opt/bin
ENV PATH /opt/venv/bin:$PATH

WORKDIR /opt/venv
CMD [ "dbt --debug debug" ]
