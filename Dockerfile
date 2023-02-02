# docker build -t appsecco/owasp-webgoat-dot-net .
# docker run --name webgoat -it -p 9000:9000 -d appsecco/owasp-webgoat-dot-net
FROM mono:slim
LABEL MAINTAINER="Appsecco"

#RUN apt-get update \
#    && apt-get install -y apt-utils wget unzip

#RUN wget https://packages.microsoft.com/config/ubuntu/22.10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
#    && dpkg -i packages-microsoft-prod.deb \
#    && rm packages-microsoft-prod.deb

# dotnet-sdk-7.0 aspnetcore-runtime-7.0 dotnet-runtime-7.0

RUN cat /etc/*-release

RUN rm -f /etc/apt/sources.list.d/microsoft-prod.list

RUN apt-get update && apt-get install -y apt-transport-https apt-utils wget unzip

RUN wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh \
    && chmod +x ./dotnet-install.sh
    && ./dotnet-install.sh --version latest

RUN apt-get update \
    && apt-get install -y mono-xsp4 sqlite3

RUN wget https://github.com/jerryhoff/WebGoat.NET/archive/master.zip \
    && unzip master.zip \
    && cd /WebGoat.NET-master/WebGoat/

RUN dotnet build --verbosity detailed

EXPOSE 9000

WORKDIR "/WebGoat.NET-master/WebGoat/"

CMD [ "xsp4", "--printlog" ]
