#
# Consul Couchbase
#
FROM 		couchbase/server:enterprise-4.0.0-3508
MAINTAINER 	Corbin Uselton <corbinu@decimal.io>

# installed Node.js, similar to https://github.com/joyent/docker-node/blob/428d5e69763aad1f2d8f17c883112850535e8290/0.12/Dockerfile
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys 7937DFD2AB06298B2293C3187D33FF9D0246406D 114F43EE0176B71C7BC219DD50A3051F888C628D

RUN echo "APT::Install-Recommends 0;" >> /etc/apt/apt.conf.d/01norecommends \
    && echo "APT::Install-Suggests 0;" >> /etc/apt/apt.conf.d/01norecommends \
    && apt-get update \
    && apt-get install -y --no-install-recommends curl

RUN rm -rf /var/lib/apt/lists/*

ENV NODE_VERSION 0.12.7
ENV NPM_VERSION 2.13.3

ENV CB_USERNAME Administrator
ENV CB_PASSWORD password

RUN curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
	&& curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
	&& gpg --verify SHASUMS256.txt.asc \
	&& grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
	&& tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
	&& rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc \
	&& npm install -g npm@"$NPM_VERSION" \
	&& npm cache clear

RUN npm install -g json

COPY bin/* /usr/local/bin/

EXPOSE 8091 8092 11207 11210 11211 18091 18092
VOLUME /opt/couchbase/var

ENTRYPOINT ["consul-couchbase-start"]
CMD ["couchbase-server"]
