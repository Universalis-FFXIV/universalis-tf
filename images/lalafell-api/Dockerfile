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
RUN curl -O https://s3.us-west-1.wasabisys.com/universalis-ffxiv-sqpack-kr/sqpack/ffxiv/0a0000.win32.dat0
RUN curl -O https://s3.us-west-1.wasabisys.com/universalis-ffxiv-sqpack-kr/sqpack/ffxiv/0a0000.win32.index2
RUN curl -O https://s3.us-west-1.wasabisys.com/universalis-ffxiv-sqpack-kr/sqpack/ffxiv/0a0000.win32.index

WORKDIR /app
COPY --from=build-env /source/bin/ ./
COPY appsettings.json .
ENTRYPOINT ["dotnet", "XIVAPI.KR.dll"]