FROM mysql:5.7

RUN mkdir /home/cert

COPY ./cert /root/cert

COPY ./my.cnf /etc/mysql

RUN chown -R mysql: /root/cert
