# docker build -t appsecco/owasp-webgoat-dot-net .
# docker run --name webgoat -it -p 9000:9000 -d appsecco/owasp-webgoat-dot-net
FROM mono:slim
LABEL MAINTAINER="Appsecco"

RUN wget https://packages.microsoft.com/config/ubuntu/22.10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb
    && rm packages-microsoft-prod.deb

RUN apt-get update \
    && apt-get install -y apt-utils wget unzip dotnet-sdk-7.0 aspnetcore-runtime-7.0 dotnet-runtime-7.0 mono-xsp4 sqlite3 \
    && wget https://github.com/jerryhoff/WebGoat.NET/archive/master.zip \
    && unzip master.zip \
    && cd /WebGoat.NET-master/WebGoat/ \
    && dotnet build --verbosity detailed

EXPOSE 9000

WORKDIR "/WebGoat.NET-master/WebGoat/"

CMD [ "xsp4", "--printlog" ]
