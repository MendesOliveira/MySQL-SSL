# encrypt-mysql

Esse repositório tem como objetivo ajudar na realização de criação de banco de dados com maior segurança. Dessa vez será utilizada uma chave auto-assinada para servidor e cliente, que possibilitará a conexão ao banco apenas de usuários autorizados e que possuam acesso a chave privada disponibilizada pelo servidor para cliente. Dessa forma, toda e qualquer conexão estará por trás do SSL/TLS. 

## Tabela de Conteúdos

- [Sobre](#sobre)
- [Instalação](#instalação)
- [Exemplos](#Exemplos)

## Sobre

As chaves de criptografia são uma tecnologia crucial para realização de exposições de aplicações de forma segura. Ela realiza um encapsulamento da saída ou entrada de protocolos de uma aplicação, que só deve ser acessado pela chave de acesso, que o servidor fornecerá por si só, ou uma chave especifica criada para um usuário ou aplicação ter acesso ao servidor. O protocolo SSL/TLS é muito importante também para evitar ataques de Sniffing e MITM, e o uso de uma chave de acesso única e exclusiva, impede também o banco de dados sofrer ataque de força bruta.  

## Instalação

Para realizar a instalação utilizaremos como exemplo um ambiente UNIX, no caso a seguir, estaremos utilizando o Ubuntu 22.04;

Realização da instalação do Openssl, esta ferramenta será responsável pela criação do certificado auto-assinado que apontará para o hospedeiro do banco de dados;

```
sudo apt-get install openssl -y
``` 

Logo após, uma pasta será criada para armazenar os certificados digitais;

```
mkdir ./certs && cd ./certs
``` 

Realize a criação da CA, Uma unidade Certificadora, como o certificado que será utilizado é um auto-assinado então a unidade certificadora será também o próprio Host do servidor. É importante que o CN(Comun Name) do OpenSSl seja descrito como o DNS do hospedeiro, ou o próprio Ip do servidor;

```
openssl genrsa 2048 > ca-key.pem
```

Realizando a criação do certificado, e especulando o vencimento do mesmo a TAG (-days);

```
openssl req -new -x509 -nodes -days 3600 \
        -key ca-key.pem -out ca.pem
```

Criando o certificado do servidor, que será responsável por fazer a criptografia do tráfego que sai e entra do mesmo com o protocolo SSL;

```
openssl req -newkey rsa:2048 -days 3600 \
        -nodes -keyout server-key.pem -out server-req.pem
```

Alterando formato da chave para RSA;

```
openssl rsa -in server-key.pem -out server-key.pem
```

Vinculando CA ao certificado do servidor, para que o certificado aponte para a unidade certificadora auto-assinada;

```
openssl x509 -req -in server-req.pem -days 3600 \
        -CA ca.pem -CAkey ca-key.pem -set_serial 01 -out server-cert.pem
```

Criando Certificado do cliente, convertendo o mesmo para o formato RSA e o assinando com a unidade certificadora;

```
openssl req -newkey rsa:2048 -days 3600 \
        -nodes -keyout client-key.pem -out client-req.pem
openssl rsa -in client-key.pem -out client-key.pem
openssl x509 -req -in client-req.pem -days 3600 \
        -CA ca.pem -CAkey ca-key.pem -set_serial 01 -out client-cert.pem
```

