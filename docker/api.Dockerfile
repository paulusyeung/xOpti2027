# syntax=docker/dockerfile:1
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY xOpti.sln ./
COPY src/xOpti.Api/xOpti.Api.csproj src/xOpti.Api/
COPY src/xOpti.Application/xOpti.Application.csproj src/xOpti.Application/
COPY src/xOpti.Domain/xOpti.Domain.csproj src/xOpti.Domain/
COPY src/xOpti.Infrastructure/xOpti.Infrastructure.csproj src/xOpti.Infrastructure/
RUN dotnet restore src/xOpti.Api/xOpti.Api.csproj
COPY src/ src/
RUN dotnet publish src/xOpti.Api/xOpti.Api.csproj -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
# Npgsql loads the GSSAPI library at connection time; the base image does not include it.
RUN apt-get update \
 && apt-get install -y --no-install-recommends libgssapi-krb5-2 \
 && rm -rf /var/lib/apt/lists/*
ENV TZ=America/Vancouver
ENV ASPNETCORE_URLS=http://+:8080
# appsettings.json pins Kestrel to the development port; the container must listen on 8080 for nginx.
ENV Kestrel__Endpoints__Http__Url=http://0.0.0.0:8080
ENV XOptiApi__FileStorageRoot=/var/lib/xopti/files
ENV XOptiApi__FontDirectories__0=/usr/share/xopti/fonts
ENV XOptiApi__SchemaFile=/app/schema/xopti-schema.sql
COPY --from=build /app/publish ./
RUN mkdir -p /usr/share/xopti/fonts /var/lib/xopti/files /var/lib/xopti/dpkeys
COPY eOptical6DAO/3of9.TTF /usr/share/xopti/fonts/3of9.TTF
# Canonical rebuild script used by --bootstrap and --schema-drift.
COPY tools/legacy-migration/schema/xopti-schema.sql /app/schema/xopti-schema.sql
RUN chown -R app:app /usr/share/xopti /var/lib/xopti /app
EXPOSE 8080
USER app
ENTRYPOINT ["dotnet", "xOpti.Api.dll"]
