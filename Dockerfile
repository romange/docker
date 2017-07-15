FROM drydock/u16cppall:{{%TAG%}}

ADD . /u16_ci

RUN /u16_ci/install.sh
