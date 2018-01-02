FROM ubuntu:xenial
MAINTAINER Makoto Yoshida <mattintosh4@gmail.com>

RUN sed -E -i 's!(archive|security).ubuntu.com/ubuntu!ftp.jaist.jp/pub/Linux/ubuntu!' /etc/apt/sources.list
RUN dpkg --add-architecture i386
RUN apt-get -y update
RUN apt-get -y install locales \
    && localedef -i ja_JP -c -f UTF-8 -A /usr/share/locale/locale.alias ja_JP.UTF-8
RUN apt-get -y install wget
RUN wget -qO- http://dl.winehq.org/wine-builds/Release.key | apt-key add -
RUN echo 'deb http://dl.winehq.org/wine-builds/ubuntu/ xenial main' >/etc/apt/sources.list.d/dl.winehq.org.list
RUN apt-get -y update
RUN apt-get -y install winehq-stable
RUN apt-get -y clean all

ADD qaac/* /usr/local/bin/

RUN useradd -m qaac
USER qaac
ENV LANG        ja_JP.UTF-8
ENV WINEPATH    /usr/local/bin
ENV WINEDEBUG   -all
WORKDIR /mnt
