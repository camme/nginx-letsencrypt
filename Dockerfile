FROM nginx:1.11.5

ARG VERSION=0-DEV
ENV VERSION=${VERSION}

RUN apt-get update
RUN apt-get install wget -y

RUN mkdir /opt/certbot
WORKDIR /opt/certbot
RUN wget https://dl.eff.org/certbot-auto
RUN chmod a+x certbot-auto
RUN ./certbot-auto --os-packages-only --non-interactive
#--noninteractive

#RUN apt-get install certbot 
#RUN apt-get -y install git
#RUN git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt  
#WORKDIR /opt/letsencrypt  

RUN mkdir /var/www

# We dont actually install the cert, but want to mke sure that everything is installed in the docker image to begin the next process
#RUN ./letsencrypt-auto --noninteractive --agree-tos
#
#-a webroot --webroot-path=/var/www --noninteractive --agree-tos --email camilo.tapia@gmail.com

COPY ./bootscripts/entrypoint.sh /bootscripts/entrypoint.sh
COPY ./templates /nginx-templates

WORKDIR /bootscripts

CMD ./entrypoint.sh
