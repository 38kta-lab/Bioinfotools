# MAFFT; https://github.com/evolbioinfo/dockerfiles/blob/master/mafft/v7.505/Dockerfile
# Trimal; https://github.com/evolbioinfo/dockerfiles/blob/master/trimal/v1.4.1/Dockerfile
# IQ-TREE; https://github.com/evolbioinfo/dockerfiles/blob/master/iqtree/v2.2.5/Dockerfile
# PhyML; https://github.com/evolbioinfo/dockerfiles/blob/master/phyml/v3.3.20220408/Dockerfile
# Seqkit; https://github.com/evolbioinfo/dockerfiles/blob/master/seqkit/v2.4.0/Dockerfile
# HMMER; https://github.com/evolbioinfo/dockerfiles/blob/master/hmmer/v3.3/Dockerfile


# base image: Ubuntu
FROM --platform=linux/amd64 ubuntu:22.04

# File Author / Maintainer
LABEL maintainer=38kta.lab@gmail.com

# VERSION

ENV mafft_VERSION=7.505
ENV trimal_VERSION=1.4.1
ENV iqtree_VERSION=2.2.2.7
ENV PHYML_VERSION=v3.3.20220408
ENV PHYML_COMMIT=1d08eeec1a24178de69488127faff09082dac0cd
ENV seqkit_VERSION=2.4.0
ENV hmmer_VERSION=3.3.2

# apt deps
RUN apt-get update --fix-missing && apt-get install -y \
	build-essential \
    bzip2 \
	wget \
	g++ \
	autoconf \
	automake \
	pkg-config \
	cmake \
	git \
    gcc \
	make

# move /usr/local/
RUN cd /usr/local/

# MAFFT

RUN wget -O mafft-${mafft_VERSION}-without-extensions-src.tgz https://mafft.cbrc.jp/alignment/software/mafft-${mafft_VERSION}-without-extensions-src.tgz\
    && tar -xzvf mafft-${mafft_VERSION}-without-extensions-src.tgz \
    && rm -rf mafft-${mafft_VERSION}-without-extensions-src.tgz \
    && cd mafft-${mafft_VERSION}-without-extensions/core \
    && make \
    && make install \
	&& rm -rf /usr/local/mafft-${mafft_VERSION}-without-extensions/ 

# Trimal

RUN wget https://github.com/scapella/trimal/archive/v${trimal_VERSION}.tar.gz \
    && tar -xzvf v${trimal_VERSION}.tar.gz \
    && cd trimal-${trimal_VERSION}/source \
    && make \
    && mv readal statal trimal /usr/local/bin \
    && rm -rf /usr/local/v${trimal_VERSION}.tar.gz \
	&& rm -rf /usr/local/trimal-${trimal_VERSION}

# IQ-TREE

RUN wget https://github.com/iqtree/iqtree2/releases/download/v${iqtree_VERSION}/iqtree-${iqtree_VERSION}-Linux.tar.gz \
    && tar -xzvf iqtree-${iqtree_VERSION}-Linux.tar.gz \
    && mv iqtree-${iqtree_VERSION}-Linux/bin/iqtree2 /usr/local/bin/iqtree2 \
    && chmod +x /usr/local/bin/iqtree2 \
    && rm -rf /usr/local/iqtree-${iqtree_VERSION}-Linux.tar.gz \
    && rm -rf /usr/local/iqtree-${iqtree_VERSION}-Linux

#PhyML

RUN wget -O phyml-${PHYML_VERSION}.tar.gz https://github.com/stephaneguindon/phyml/archive/${PHYML_COMMIT}.tar.gz \
    && tar -xzvf phyml-${PHYML_VERSION}.tar.gz \
    && rm -rf phyml-${PHYML_VERSION}.tar.gz \
    && cd phyml-${PHYML_COMMIT} \
    && sh ./autogen.sh \
    && ./configure \
    && make \
    && make install \
    && rm -rf /usr/local/phyml-${PHYML_COMMIT} 

# Seqkit

RUN wget https://github.com/shenwei356/seqkit/releases/download/v${seqkit_VERSION}/seqkit_linux_amd64.tar.gz \
    && tar -xzvf seqkit_linux_amd64.tar.gz \
    && rm -f seqkit_linux_amd64.tar.gz \
    && mv seqkit /usr/local/bin/

# HMMER

RUN wget http://eddylab.org/software/hmmer/hmmer-${hmmer_VERSION}.tar.gz \
    && tar zxf hmmer-${hmmer_VERSION}.tar.gz \
    && cd hmmer-${hmmer_VERSION} \
    && ./configure \
    && make \
    && make install \
    && rm -rf /usr/local/hmmer-${hmmer_VERSION}

# miniconda

ENV PATH ~/miniconda3/bin:$PATH
ENV DEBIAN_FRONTEND=noninteractive

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py39_23.10.0-1-Linux-x86_64.sh -O ~/Miniconda.sh && \
 /bin/bash ~/Miniconda.sh -b -p ~/miniconda3 && \
 rm ~/Miniconda.sh && \
 echo ". ~/miniconda3/etc/profile.d/conda.sh" >> ~/.bashrc && \
 echo "conda activate base" >> ~/.bashrc

SHELL ["/bin/bash", "-c"]
WORKDIR /home