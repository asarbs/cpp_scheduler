FROM debian


USER root
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y bash bash-completion python3 python3-django python3-pip git python3-bs4 sqlite3 wget lsb-release software-properties-common gnupg clang-format

SHELL ["/bin/bash", "-c"]

EXPOSE 3000
