# syntax=docker/dockerfile:1
# Build stage runs the full web gate (contract check, typecheck, tests, build,
# output checks). The runtime stage is nginx serving the static bundle.

FROM node:24-alpine AS build
# The contract check script is bash.
RUN apk add --no-cache bash
WORKDIR /repo/web/xOpti.Web

COPY web/xOpti.Web/package.json web/xOpti.Web/package-lock.json ./
RUN npm ci

# Inputs the gate reads outside the web project: the committed contract and its
# check script, and the backend permission source that the client mirror is tested against.
COPY api-contract /repo/api-contract
COPY scripts /repo/scripts
COPY src/xOpti.Application/Authorization/PermissionNames.cs /repo/src/xOpti.Application/Authorization/PermissionNames.cs

COPY web/xOpti.Web/ ./
RUN npm run ci

FROM nginx:1.27-alpine AS runtime
ENV XOPTI_ANALYTICS_ENABLED=false
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY docker/web/40-xopti-config.sh /docker-entrypoint.d/40-xopti-config.sh
COPY --from=build /repo/web/xOpti.Web/dist /usr/share/nginx/html
EXPOSE 80
