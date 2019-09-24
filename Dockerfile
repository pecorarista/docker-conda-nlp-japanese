FROM continuumio/anaconda

SHELL ["/bin/bash", "-c"]

ENV DEBCONF_NOWARNINGS yes

ENV CI_USER "nlp"
ENV JUMANPP_VERSION "1.02"

RUN apt-get update

RUN apt-get install -y \
        build-essential \
        curl \
        libboost-dev \
        sudo \
        postgresql-client \
        mecab \
        libmecab-dev \
        mecab-ipadic-utf8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --skel /etc/skel \
        --home-dir /opt/${CI_USER} \
        --shell /bin/bash ${CI_USER} && \
    echo "${CI_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/${CI_USER} && \
    chmod 440 /etc/sudoers.d/${CI_USER} && \
    visudo --check

RUN echo $'export PATH=$HOME/usr/local/bin:$PATH\n\
source /opt/conda/etc/profile.d/conda.sh\n\
conda activate base' >> /opt/${CI_USER}/.bashrc

RUN chown -R ${CI_USER}:${CI_USER} /opt

USER ${CI_USER}

WORKDIR /opt/${CI_USER}

# Juman++
RUN wget --quiet "http://nlp.ist.i.kyoto-u.ac.jp/DLcounter/lime.cgi?down=http://lotus.kuee.kyoto-u.ac.jp/nl-resource/jumanpp/jumanpp-${JUMANPP_VERSION}.tar.xz&name=jumanpp-${JUMANPP_VERSION}.tar.xz" -O "jumanpp-${JUMANPP_VERSION}.tar.xz" && \
    tar xf "jumanpp-${JUMANPP_VERSION}.tar.xz" && \
    cd "jumanpp-${JUMANPP_VERSION}" && \
    ./configure && \
    make && \
    sudo make install && \
    cd && \
    rm "jumanpp-${JUMANPP_VERSION}.tar.xz" && \
    rm -rf "jumanpp-${JUMANPP_VERSION}"

# NEologd
RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git && \
    cd mecab-ipadic-neologd && \
    ./bin/install-mecab-ipadic-neologd -n -y -p /var/lib/mecab/dic/mecab-ipadic-neologd && \
    cd \
    rm -rf mecab-ipadic-neologd

CMD ["/bin/bash"]
