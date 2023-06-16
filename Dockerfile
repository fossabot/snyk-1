# Install dependencies only when needed
ARG NODE_FRAMEWORK=$NODE_FRAMEWORK
ARG NODE_VERSION=$NODE_VERSION

FROM node:${NODE_VERSION}-alpine as develop

RUN apk add -X https://dl-cdn.alpinelinux.org/alpine/v3.17/main -u alpine-keys && \
    apk update && apk add --no-cache curl

ARG PNPM=$PNPM
ARG PNPM_VERSION=$PNPM_VERSION
RUN if [ "$PNPM" = "false" ] ; then echo 'nothing to do' ; else npm install -g pnpm@$PNPM_VERSION ; fi

ENV NODE_ENV development
# set working directory
WORKDIR /app
# add `/app/node_modules/.bin` to $PATH
ENV PATH /app/node_modules/.bin:$PATH

FROM node:${NODE_VERSION}-alpine AS deps
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add -X https://dl-cdn.alpinelinux.org/alpine/v3.17/main -u alpine-keys && \
    apk update && apk add --no-cache libc6-compat
WORKDIR /app
ARG LOCKFILE=$LOCKFILE
# COPY package.json ${LOCKFILE:-yarn.lock} tsconfig.json ./
COPY ${LOCKFILE:-yarn.lock} *.json .
ARG PNPM=$PNPM
ARG PNPM_VERSION=$PNPM_VERSION
RUN if [ "$PNPM" = "false" ] ; then echo 'nothing to do' ; else npm install -g pnpm@$PNPM_VERSION ; fi
RUN if [ "$PNPM" = "false" ] ; then yarn install --network-timeout 1000000000 ; else pnpm i ; fi

# Rebuild the source code only when needed
FROM node:${NODE_VERSION}-alpine AS builder

ENV PATH /app/node_modules/.bin:$PATH

WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# RUN chmod a+x /app/docker-nestjs-environment/migrations-* && \
#     mv /app/docker-nestjs-environment/migrations-* /app/.
ARG PNPM=$PNPM
ARG PNPM_VERSION=$PNPM_VERSION
ARG NODE_FRAMEWORK=$NODE_FRAMEWORK

RUN if [ "$PNPM" = "false" ] ; then echo 'nothing to do' ; else npm install -g pnpm@$PNPM_VERSION ; fi
RUN if [ "$NODE_FRAMEWORK" = "node"] ; then echo 'nothing to do' ; else if [ "$PNPM" = "false" ] ; then yarn build ; else pnpm build ; fi ; fi

RUN rm -rf /app/node_modules
RUN if [ "$PNPM" = "false" ] ; then yarn install --prod --network-timeout 1000000000 ; else pnpm i --prod ; fi
# If using npm comment out above and use below instead
# RUN npm run build

FROM builder AS migrations
WORKDIR /app

ENV NODE_ENV production

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nestjs

COPY --from=builder /app/node_modules ./node_modules
# COPY ./docker-nestjs-environment /app/docker-nestjs-environment
RUN chown -R nestjs:nodejs /app

ARG MIGRATIONS=$MIGRATIONS
ARG MIGRATIONS_ORM=$MIGRATIONS_ORM
RUN if [ "$MIGRATIONS" = "false" ] ; then echo 'nothing to do' ; else chmod a+X /app/docker-nestjs-environment/migrations-${MIGRATIONS_ORM} ; fi

# Production image, copy all the files and run next
FROM node:${NODE_VERSION}-alpine AS build_node
WORKDIR /app
# ONBUILD WORKDIR /app
COPY --from=builder /app .

FROM node:${NODE_VERSION}-alpine AS build_nestjs
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/tsconfig.json ./
COPY --from=builder /app/dist/ ./dist/

FROM build_${NODE_FRAMEWORK} AS runner
# WORKDIR /app

ENV NODE_ENV production

RUN apk add -X https://dl-cdn.alpinelinux.org/alpine/v3.17/main -u alpine-keys && \
    apk update && apk add --no-cache curl

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nestjs
RUN chown -R nestjs:nodejs /app

USER nestjs

EXPOSE 3000

ENV PORT 3000

ARG APP_CMD=$APP_CMD
CMD ["node", "$APP_CMD"]