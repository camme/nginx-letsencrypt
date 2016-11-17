FROM: nginx:1.11.5

RUN apt-get update
RUN apt-get -y install git
RUN git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt  

COPY ./bootscripts /bootscripts
COPY ./templates /nginx-templates

WORKDIR /bootscripts

CMD ['./entrypoint.sh']
