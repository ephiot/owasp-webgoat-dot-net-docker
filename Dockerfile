# docker build -t appsecco/owasp-webgoat-dot-net .
# docker run --name webgoat -it -p 9000:9000 -d appsecco/owasp-webgoat-dot-net
#FROM mono:slim
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 as build
LABEL MAINTAINER="Appsecco"

ARG SONAR_PROJECT_KEY=Protosofia_owasp-webgoat-dotnet
ARG SONAR_OGRANIZAION_KEY=protosofia
ARG SONAR_HOST_URL=https://sonarcloud.io
ARG SONAR_TOKEN=54qib4cxjksyr6o6kspmvfopnrnh2pngj4h3ddeah654cmfnh26a

# Install Sonar Scanner, Coverlet and Java (required for Sonar Scanner)
RUN apt-get update && apt-get install -y openjdk-11-jdk
RUN dotnet tool install --global dotnet-sonarscanner
RUN dotnet tool install --global coverlet.console
ENV PATH="$PATH:/root/.dotnet/tools"

RUN apt-get update \
    && apt-get install -y wget unzip mono-xsp4 sqlite3 \
    && wget https://github.com/jerryhoff/WebGoat.NET/archive/master.zip \
    && unzip master.zip \
    && cd /WebGoat.NET-master/WebGoat/
#    && msbuild

WORKDIR "/WebGoat.NET-master/WebGoat/"

# Start Sonar Scanner
RUN dotnet sonarscanner begin \
  /k:"$SONAR_PROJECT_KEY" \
  /o:"$SONAR_OGRANIZAION_KEY" \
  /d:sonar.host.url="$SONAR_HOST_URL" \
  /d:sonar.login="$SONAR_TOKEN" \
  /d:sonar.cs.opencover.reportsPaths=/coverage.opencover.xml

# Restore NuGet packages
COPY *.csproj .
RUN dotnet restore

# Copy the rest of the files over
COPY . .

# Build and test the application
RUN dotnet publish --output /out/
RUN dotnet test \
  /p:CollectCoverage=true \
  /p:CoverletOutputFormat=opencover \
  /p:CoverletOutput="/coverage"

# End Sonar Scanner
RUN dotnet sonarscanner end /d:sonar.login="$SONAR_TOKEN"

# Download the official ASP.NET Core Runtime image
# to run the compiled application
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
WORKDIR "/WebGoat.NET-master/WebGoat/"

# Open port
EXPOSE 9000

# Copy the build output from the SDK image
COPY --from=build /out .

CMD [ "xsp4", "--printlog" ]
