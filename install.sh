#!/bin/sh
while getopts v: option
do
case "${option}"
in
v) VERSION=${OPTARG};;
esac
done

git submodule add -f ssh://git@gitlab.devops.decea.intraer:2201/atd-sdop/devops/docker-nestjs-environment.git
git submodule foreach --recursive git checkout $VERSION
git submodule foreach --recursive git pull
cp docker-nestjs-environment/.dockerignore.example .dockerignore
cp docker-nestjs-environment/.gitlab-ci.yml.example .gitlab-ci.yml
cat docker-nestjs-environment/.env.example >> .env.example
cat docker-nestjs-environment/readmeapp.md >> README.md
cd docker-nestjs-environment && make

