# Build stage
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build-env
WORKDIR /source
COPY ./Lalafell.API/src ./

# Build the application
RUN dotnet build -c Release -o ./bin

# Run stage
FROM mcr.microsoft.com/dotnet/aspnet:7.0

# Download sheets
WORKDIR /sqpack/ffxiv
RUN apt update && apt install curl -y

ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache
RUN curl -O https://media.githubusercontent.com/media/karashiiro/0a0000_kr/main/0a0000.win32.dat0
RUN curl -O https://media.githubusercontent.com/media/karashiiro/0a0000_kr/main/0a0000.win32.index2
RUN curl -O https://media.githubusercontent.com/media/karashiiro/0a0000_kr/main/0a0000.win32.index

WORKDIR /app
COPY --from=build-env /source/bin/ ./
COPY appsettings.json .
ENTRYPOINT ["dotnet", "XIVAPI.KR.dll"]