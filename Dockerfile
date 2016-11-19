FROM nginx:1.11.5

ARG VERSION=0-DEV
ENV VERSION=${VERSION}

RUN mkdir -p /etc/ssl/certs
RUN mkdir /opt/certbot
RUN mkdir /var/www
RUN mkdir /nginx-letsencrypt-temp

VOLUME ['/nginx-letsencrypt', '/etc/letsencrypt/live/', '/etc/ssl/certs']


RUN apt-get update
RUN apt-get install wget -y

WORKDIR /opt/certbot
RUN wget https://dl.eff.org/certbot-auto
RUN chmod a+x certbot-auto
RUN ./certbot-auto --os-packages-only --non-interactive

RUN sed -i "s/include \/etc\/nginx\/conf.d\/\*.conf;/include \/etc\/nginx\/conf.d\/\*.conf;\ninclude \/etc\/nginx\/sites-enabled\/\*;/g" /etc/nginx/nginx.conf
RUN cat /etc/nginx/nginx.conf
#RUN sed -i "s/opcache.revalidate_freq=60/opcache.revalidate_freq=0/g" /usr/local/etc/php/conf.d/opcache-recommended.ini


# We dont actually install the cert, but want to mke sure that everything is installed in the docker image to begin the next process
#RUN ./letsencrypt-auto --noninteractive --agree-tos
#
#-a webroot --webroot-path=/var/www --noninteractive --agree-tos --email camilo.tapia@gmail.com

COPY ./bootscripts /bootscripts
COPY ./templates /nginx-templates

RUN touch /var/log/cron.log
ADD ./bootscripts/letsencrypt-cron /etc/cron.d/letsencrypt-cron

WORKDIR /bootscripts

EXPOSE 80 443

CMD ./entrypoint.sh
