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
ENV TZ=America/Vancouver
ENV ASPNETCORE_URLS=http://+:8080
ENV XOptiApi__FileStorageRoot=/var/lib/xopti/files
ENV XOptiApi__FontDirectories__0=/usr/share/xopti/fonts
COPY --from=build /app/publish ./
RUN mkdir -p /usr/share/xopti/fonts /var/lib/xopti/files
COPY eOptical6DAO/3of9.TTF /usr/share/xopti/fonts/3of9.TTF
RUN chown -R app:app /usr/share/xopti /var/lib/xopti /app
EXPOSE 8080
USER app
ENTRYPOINT ["dotnet", "xOpti.Api.dll"]
