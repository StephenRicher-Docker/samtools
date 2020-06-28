#################### BASE IMAGE ######################

FROM alpine:3.9 AS download

#################### METADATA ########################

LABEL base.image="alpine:3.9"
LABEL version="1"
LABEL software="Samtools"
LABEL software.version="1.9"
LABEL about.summary="Utilities for the Sequence Alignment/Map (SAM) format."
LABEL about.home="https://github.com/samtools/samtools"
LABEL about.documentation="http://www.htslib.org/doc/samtools.html"
LABEL license="https://github.com/samtools/samtools/blob/develop/LICENSE"
LABEL about.tags="Genomics"

#################### MAINTAINER ######################

MAINTAINER Stephen Richer <sr467@bath.ac.uk>

#################### DOWNLOAD ########################

ENV URL=https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2

WORKDIR /tmp

RUN apk update && \
    apk add --no-cache curl tar
RUN curl -L $URL | tar -xj

#################### BUILD ###########################

FROM alpine:3.9 AS build

COPY --from=download /tmp /tmp

RUN apk update && apk add --no-cache \
      gcc \
      make \
      libc-dev \
      bzip2-dev \
      zlib \
      libbz2 \
      xz-dev \
      libcurl \
      ncurses-dev
RUN cd /tmp/* && \
    ./configure --prefix=/usr/local/ && \
    make -j4 && \
    make install

#################### FINALISE ########################

FROM alpine:3.9

RUN apk update && apk add --no-cache \
      zlib \
      libbz2 \
      xz-dev \
      libcurl \
      ncurses-dev

COPY --from=build /usr/local /usr/local

USER guest
CMD ["samtools"]
