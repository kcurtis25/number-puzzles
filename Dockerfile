FROM rapi/psgi

MAINTAINER Katherine Curtis

COPY SCP-WebApp/cpanfile /opt/app/

RUN cpanm --installdeps /opt/app/ && apt-get update && apt-get install -y texlive

COPY puzzle.tt SCP-WebApp/ lib/ /opt/app/
COPY data /opt/app/data/

ENV RAPI_PSGI_PORT 50000
 
EXPOSE 50000
