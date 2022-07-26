FROM ubuntu:bionic

ARG build_env=devel
ENV BUILD_ENV=$build_env

RUN set -xe \
    && echo "Europe/Moscow" > /etc/timezone \
    && apt-get -y update \
    && apt-get -y install curl \
    && mkdir -p /opt/kraken/bin /tmp/kraken \
    && curl http://repo.krakend.io/bin/krakend_1.0.0_amd64.tar.gz \
    --output - |tar -C /tmp/kraken -zxf - \
    && cp /tmp/kraken/usr/bin/krakend /opt/kraken/bin/krakend \
    && rm -r /tmp/kraken && rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/unit.list \
    && /opt/kraken/bin/krakend -h

ADD flexible /etc/krakend
ADD api /etc/krakend/settings

ENV FC_ENABLE=1
ENV FC_SETTINGS=/etc/krakend/settings
ENV FC_TEMPLATES=/etc/krakend/templates
ENV FC_OUT=/etc/krakend/debug.json

RUN if [ "${BUILD_ENV}" = "devel" ]; \
    then mv /etc/krakend/templates/const/dev.tmpl /etc/krakend/templates/const.tmpl; \
    else mv /etc/krakend/templates/const/prod.tmpl /etc/krakend/templates/const.tmpl; \
    fi

ENTRYPOINT [ "/opt/kraken/bin/krakend" ]
CMD [ "run", "-c", "/etc/krakend/krakend.json" ]