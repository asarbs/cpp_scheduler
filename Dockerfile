FROM debian


USER root
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y bash
RUN apt-get install -y bash-completion
RUN apt-get install -y python3
RUN apt-get install -y python3-django
RUN apt-get install -y python3-pip
RUN apt-get install -y git
RUN apt-get install -y python3-bs4
RUN apt-get install -y sqlite3
RUN apt-get install -y wget
RUN apt-get install -y lsb-release
RUN apt-get install -y software-properties-common 
RUN apt-get install -y gnupg

SHELL ["/bin/bash", "-c"]

EXPOSE 3000