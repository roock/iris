FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y dist-upgrade \
    && apt-get -y install libffi-dev libsasl2-dev python3-dev libyaml-dev \
        libldap2-dev libssl-dev python3-pip python3-setuptools python3-venv \
    mysql-client nginx uwsgi uwsgi-plugin-python3 uwsgi-plugin-gevent-python3 \
    && pip3 install mysql-connector-python \
    && rm -rf /var/cache/apt/archives/*


WORKDIR /home/iris

COPY src source/src
COPY setup.py MANIFEST.in README.md source/

RUN python3 -m venv /home/iris/env && \
    /bin/bash -c 'source /home/iris/env/bin/activate && python3 -m pip install -U pip wheel && cd /home/iris/source && pip install .'

COPY ops/daemons daemons/
COPY ops/daemons/uwsgi-docker.yaml daemons/uwsgi.yaml
COPY db db/
COPY configs/config.dev.yaml config/config.yaml
# Patch Config File to write logfile to a writeable location
RUN sed -i "s/filename.*/filename: '\/home\/iris\/var\/log\/sender\/rpc.access.log'/" config/config.yaml
COPY healthcheck /tmp/status
COPY ops/entrypoint.py entrypoint.py

RUN useradd -m -s /bin/bash iris && \
    chown -R iris:iris /var/log/nginx /var/lib/nginx && \
    mkdir -p /home/iris/var/log/uwsgi /home/iris/var/log/nginx /home/iris/var/run /home/iris/var/relay /home/iris/var/log/sender && \
    chown -R iris:iris /home/iris/var/log/uwsgi /home/iris/var/log/nginx /home/iris/var/run /home/iris/var/relay /home/iris/var/log/sender

EXPOSE 16649

ENV INIT_FILE=/tmp/iris_db_initialized
USER iris
CMD ["bash", "-c", "source /home/iris/env/bin/activate && exec python -u /home/iris/entrypoint.py"]
