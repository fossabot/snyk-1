## Ambiente docker-nestjs-environment

Este repositório está com o docker-nestjs-environment integrado, para fazer funcionar você deve clonar com parâmetro `--recursive` ou caso já tenha o repositório localmente, baixe o submodule com `git submodule update --init --remote --recursive`.

Antes de iniciar os passos seguintes, não se esqueça de gerar o .env a partir do .env.example. Você pode rodar o comando na raíz do projeto para gerar o env: `cp .env.example .env`

1. Esteja no path `docker-nestjs-environment/` para conseguir executar os comandos abaixo;
1. Para levantar o ambiente de desenvolvimento local, faça `make dev`;
2. Derrubando os containers: `make down`.

Para a versão "buildada", você pode rodar `make local-prod`. Irá realizar o build da aplicação e servir via servidor node.

Para visualizar os logs: `make logs p=-f`

Para execução de migrations de forma manual: `make up c=migrations`

Para mais comandos, digite apenas `make`.

Mais informações sobre o docker-nestjs-environment [acesse aqui](https://gitlab.devops.decea.intraer/atd-sdop/devops/docker-nestjs-environment).