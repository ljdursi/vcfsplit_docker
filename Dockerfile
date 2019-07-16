FROM ubuntu
LABEL Maintainer="CanDIG Project"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get -y install build-essential

RUN apt-get install -y git autoconf

RUN apt-get install -y zlib1g-dev libbz2-dev liblzma-dev

RUN apt-get install -y libssl-dev libcurl4-openssl-dev

WORKDIR /build

RUN git clone https://github.com/samtools/htslib.git \
    && cd htslib \
    && git checkout develop \
    && autoheader \
    && autoconf \
    && ./configure --enable-s3 --enable-libcurl --enable-plugins \
    && make \
    && make install \
    && cd ..

RUN git clone https://github.com/samtools/bcftools.git --branch=develop \
    && cd bcftools \
    && make \
    && make install \
    && cd ..

RUN apt-get install -y curl

COPY script.sh /usr/local/bin/script.sh

WORKDIR /conf

ENTRYPOINT ["/usr/local/bin/script.sh"]
