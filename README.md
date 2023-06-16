# Docker Environment for NestJS App
> Ambiente docker para sua aplicação construída com NestJS App. 

<!-- [![NPM Version][npm-image]][npm-url]
[![Build Status][travis-image]][travis-url]
[![Downloads Stats][npm-downloads]][npm-url] [![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fmadson7%2Fsnyk.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2Fmadson7%2Fsnyk?ref=badge_shield)
-->

Este ambiente lhe permitirá executar localmente para desenvolvimento e também criar e realizar o deploy da aplicação nos clusters de homologação e produção do DECEA.

<!-- ![](../header.png) -->

## Instalação

> OS X & Linux

Para instalação execute o comando abaixo no terminal no caminho raíz de sua aplicação NestJS

```sh
bash <( curl --request GET --header "PRIVATE-TOKEN: $GITLAB_TOKEN" 'https://gitlab.devops.decea.intraer/api/v4/projects/762/repository/files/install%2Esh/raw?ref=main' ) -v 1.3.3
```

### Pós Instalação

#### Configuração Gitlab CI

> ##### gitmodule

Após adicionar o ambiente ao seu front utilizado o comando de instalação acima citado, é preciso corrigir o arquivo `.gitmodules` para utilizar o URL relativo. Somente desta forma é o CI do Gitlab funcionará corretamente.

Feito a instalação, o arquivo `.gitmodules` na raíz do seu projeto deverá ficar assim:

```git
[submodule "docker-nestjs-environment"]
	path = docker-nestjs-environment
	url = git@gitlab.devops.decea.intraer:2201/atd-sdop/devops/docker-nestjs-environment.git
```

Precisamos alterar o valor da chave **url** para um caminho relativo. Digamos que seu projeto se encontra em `gitlab.devops.decea.intraer/atd-sdop/nome_do_grupo_projeto/nome_do_projeto`, o ambiente se encontra em `gitlab.devops.decea.intraer/atd-sdop/devops/docker-nestjs-environment`. O caminho relativo do seu projeto para o projeto do ambiente ficaria `../../devops/docker-nestjs-environment`. Ficaria seu `.gitmodules` assim:

```git
[submodule "docker-nestjs-environment"]
	path = docker-nestjs-environment
	url = ../../devops/docker-nestjs-environment
```

A título de exemplo, se o caminho do seu projeto fosse `gitlab.devops.decea.intraer/atd-sdop/nome_do_grupo_projeto/projeto/sub_projeto`, o caminho relativo para o ambiente seria `../../../devops/docker-nestjs-environment`. Ficaria seu `.gitmodules` assim:

```git
[submodule "docker-nestjs-environment"]
	path = docker-nestjs-environment
	url = ../../../devops/docker-nestjs-environment
```

## Variáveis

Para implantação do seu front nos clusters de homologação e produção você deverá aplicar as variáveis nas configurações do seu repositório em CI/CD -> Variáveis.

![configurando variáveis no CI/CD do Gitlab](https://messenger-ciop.decea.gov.br/files/79o1nkiscjbqimnjtf8peoqxno/public?h=rD4ZJhJRK6gBJVQiasmZ65T2cgmrlKQ10iVioFSLFCI)

No Gitlab usamos como padrão os nomes **dev** e **prod** para declarar os respectivos ambientes de homologação e produção. Portanto, algumas variáveis deverão possuir valores diferentes de acordo com o ambiente, como por exemplo a url de conexão com api.

A sugestão para o cadastro das variáveis seria aplicar como "**All (default)**" todas as variáveis e para aquelas que precisam ter valores distintos você duplicará mas deverá selecionar o environment "**prod**". Veja como ficaria:

![configurando variavel para prod](https://messenger-ciop.decea.gov.br/files/jkr1ix9injr1dbgaqqf1so9hxw/public?h=P6t7rkObG2IYMNy89J3FLhBl0c4rST41KIjaMkfQZvQ)

Resultado final:

![como configurar as variáveis para dev e prod](https://messenger-ciop.decea.gov.br/files/trs3nwut3fnppkekmashqry8jr/public?h=JbJ4ZySA_Zq7oRxwqNRRhPMAEqDgZslC6SNVo62RLQ4)

Segue abaixo as variáveis disponíveis, em quais ambientes se aplica e o exemplo do valor esperado:

| Variável  |  Qual environment aplicar  |  Exemplo Formato Valor |
|-----------|:-------------:|------:|
| APP_NAME  | **All (default)** | o nome do app a ser utilizado em várias etapas do ciclo de vida da aplicação (ex: meuapp-front) |
| DEV_PORT  |    apenas para **dev local**   | porta da aplicação no docker host. exemplo:  4041 |
| POSTGRES_PORT_HOST  |    apenas para **dev local**   |  porta do banco no docker host. exemplo: 5432 |
| NODE_VERSION | **All (default)** | selecione a versão da imagem node de docker (node:$NODE_VERSION). padrão: 16 |
| SWARM  |  **All (default)** | `true` se roda via swarm ou `false` para rodar com compose |
| REPLICAS  |    **All (default)** & **prod**  | Nº de réplicas no cluster. padrão: 2 |
| UPDATE_PARALLELISM  |    **All (default)** & **prod**  | Nº de containers paralelos durante o deploy. padrão: 1 |
| DOMAIN  | **All (default)** & **prod** |  meunestjs.dev.decea.intraer ou meunestjs.decea.mil.br |
| DOMAIN_LOCALPROD  | **All (default)** & **prod** |  meunestjs.prod.decea.intraer |
| SUBPATH  |    **All (default)** & **prod**   |  exemplo: "&& PathPrefix(\`/api\`)" |
| SUBPATH_TRAEFIK  |    **All (default)** & **prod**  |   exemplo: `/api` |
| HEALTHCHECK_ENDPOINT  | **All (default)** & **prod** |  endpoint de healthcheck. exemplo: `endpoint/` |
| NODE_ID  |    **All (default)** & **prod**   | nó do cluster onde é armazenado os arquivos do banco. exemplo: sagtaf-3 |
| ENV  |    **All (default)** & **prod**   | exemplo: `development` ou `production` |
| PORT  |    **All (default)** & **prod**   | porta da aplicação no container docker. padrão: 3000 |
| APP_DESCRIPTION  |    **All (default)** & **prod**   | descrição da aplicação |
| APP_YARN_CMD  |    **All (default)** & **prod**   | quando rodando com `make dev`, selecione valor  `start:dev` ou `start:debug` |
| POSTGRES  |    **All (default)** & **prod**   | ativar banco postgres. exemplo: `true` ou `false` |
| POSTGRES_VERSION  |    **All (default)** & **prod**   | tag da imagem de container exemplo: `postgres:14.0-alpine` |
| POSTGRES_DB  |    **All (default)** & **prod**   | nome do database |
| POSTGRES_USER  |    **All (default)** & **prod**   | nome de usuário no database |
| POSTGRES_PASSWORD  |    **All (default)** & **prod**   | senha de usuário no database |
| POSTGRES_PORT  |    **All (default)** & **prod**   | a porta do banco no container docker |
| POSTGRES_HOST  |    **All (default)** & **prod**   | endereço do banco, para uso da aplicação |
| MIGRATE_DROP  |    **All (default)** & **prod**   | ative `true` se quiser realizar o drop do banco antes da execução das migrations |
| MIGRATIONS_WITH_TYPEORM  |    **All (default)** & **prod**   | ative `true` se quiser executar migrations com typeorm |
| MINIO  |    **All (default)** & **prod**   | ativa minio s3 para desenvolvimento local. exemplo: `true` ou `false` |
| MINIO_PORT  |    **All (default)** & **prod**   | porta exposta do minio no docker host |
| MINIO_ENDPOINT  |    **All (default)** & **prod**   | endpoint do minio para uso pela aplicação. exemplo: `http://minion:9000` |
| MINIO_KEY  |    **All (default)** & **prod**   | chave de acesso do minio |
| MINIO_SECRET  |    **All (default)** & **prod**   | chave secreta do minio |
| MINIO_BUCKET  |    **All (default)** & **prod**   | nome do bucket, para uso pela aplicação |

***Obs***: algumas variáveis só precisam ser definidas valor para **prod**, pois o valor para **All (default)** já existe herdado do grupo pai ATD-SDOP.

## Exemplo de uso

Por este projeto utilizar múltiplos arquivos yaml para o docker-compose, usamos neste ambiente o makefile como *wrapper*, facilitando assim a execução do ambiente em diferentes cenários.

Alguns comandos básicos:

- `make dev` - inicia o ambiente de desenvolvimento local, montando o código fonte da aplicação como volume dentro do container (o que significa que qualquer alteração feita nos arquivos da aplicação irão refletir de imediato no container) e executa este código com *yarn run*.

- `make logs` para visualizar os logs do container ou `make logs p=-f` para visualizar e manter na tela.

- `make down` para encerrar o container.

- `make ps` para visualizar os containers em execução

- `make top` para visualizar os processos do container

- `make shell` para acessar o shell do container em execução

- `make lint` execute o eslint no seu código React ou Vue

- `make local-prod` inicia o ambiente realizando o build do react e os entrega para nginx servir. simula a aplicação em produção.

- `make local-prod-top` para visualizar os processos do container quando usar "make local-prod"

- `make up c=migrations` para rodar suas migrations de maneira manual


Para mais comandos, execute `make` dentro da pasta docker-react-environment para visualizar a ajuda.

![comandos do make](https://messenger-ciop.decea.gov.br/files/fd1zt1upobyfmc3wnnnbm4u4kr/public?h=yozq-47fLFVBBcCB1XBMjLmrYIh_rHd1Z8WIYmG23mU)


<!-- _Para mais exemplos, consulte a [Wiki][wiki]._  -->

<!-- ## Configuração para Desenvolvimento

Descreva como instalar todas as dependências para desenvolvimento e como rodar um test-suite automatizado de algum tipo. Se necessário, faça isso para múltiplas plataformas.

```sh
make install
npm test
``` -->

# 🚧 *work in progress* 🚧 

<!--

## Histórico de lançamentos

* 0.2.1
    * MUDANÇA: Atualização de docs (código do módulo permanece inalterado)
* 0.2.0
    * MUDANÇA: Remove `setDefaultXYZ()`
    * ADD: Adiciona `init()`
* 0.1.1
    * CONSERTADO: Crash quando chama `baz()` (Obrigado @NomeDoContribuidorGeneroso!)
* 0.1.0
    * O primeiro lançamento adequado
    * MUDANÇA: Renomeia `foo()` para `bar()`
* 0.0.1
    * Trabalho em andamento

## Meta

Seu Nome – [@SeuNome](https://twitter.com/...) – SeuEmail@exemplo.com

Distribuído sob a licença XYZ. Veja `LICENSE` para mais informações.

[https://github.com/yourname/github-link](https://github.com/othonalberto/)

## Contributing

1. Faça o _fork_ do projeto (<https://github.com/yourname/yourproject/fork>)
2. Crie uma _branch_ para sua modificação (`git checkout -b feature/fooBar`)
3. Faça o _commit_ (`git commit -am 'Add some fooBar'`)
4. _Push_ (`git push origin feature/fooBar`)
5. Crie um novo _Pull Request_

[npm-image]: https://img.shields.io/npm/v/datadog-metrics.svg?style=flat-square
[npm-url]: https://npmjs.org/package/datadog-metrics
[npm-downloads]: https://img.shields.io/npm/dm/datadog-metrics.svg?style=flat-square
[travis-image]: https://img.shields.io/travis/dbader/node-datadog-metrics/master.svg?style=flat-square
[travis-url]: https://travis-ci.org/dbader/node-datadog-metrics
[wiki]: https://github.com/seunome/seuprojeto/wiki -->

## License
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fmadson7%2Fsnyk.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2Fmadson7%2Fsnyk?ref=badge_large)