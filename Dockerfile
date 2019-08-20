FROM centos:7

ARG SLURM_TAG=slurm-19-05-2-1

RUN set -ex \
    && yum makecache fast \
    && yum -y update \
    && yum -y install epel-release \
    && yum -y install \
        autoconf \
        bzip2 \
        bzip2-devel \
        file \
        gcc \
        gcc-c++ \
        gdbm-devel \
        git \
        glibc-devel \
        gmp-devel \
        make \
        mariadb-devel \
        munge \
        munge-devel \
        ncurses-devel \
        openssl-devel \
        openssl-libs \
        pkconfig \
        psmisc \
        readline-devel \
        sqlite-devel \
        tcl-devel \
        tix-devel \
        tk \
        tk-devel \
        supervisor \
        wget \
        zlib-devel \
    && yum clean all \
    && rm -rf /var/cache/yum

# Compile, build and install Slurm from Git source
RUN set -ex \
    && git clone https://github.com/SchedMD/slurm.git \
    && pushd slurm \
    && git checkout tags/$SLURM_TAG \
    && ./configure --enable-debug --prefix=/usr \
       --sysconfdir=/etc/slurm --with-mysql_config=/usr/bin \
       --libdir=/usr/lib64 \
    && make install \
    && install -D -m644 etc/cgroup.conf.example /etc/slurm/cgroup.conf.example \
    && install -D -m644 etc/slurm.conf.example /etc/slurm/slurm.conf.example \
    && install -D -m644 etc/slurmdbd.conf.example /etc/slurm/slurmdbd.conf.example \
    && install -D -m644 contribs/slurm_completion_help/slurm_completion.sh /etc/profile.d/slurm_completion.sh \
    && popd \
    && rm -rf slurm

RUN set -ex \
    && groupadd -r slurm  \
    && useradd -r -g slurm slurm \
    && mkdir /etc/sysconfig/slurm \
        /var/spool/slurmd \
        /var/run/slurmd \
        /var/lib/slurmd \
        /var/log/slurm \
    && chown slurm:root /var/spool/slurmd \
        /var/run/slurmd \
        /var/lib/slurmd \
        /var/log/slurm 

# hmmm
RUN /sbin/create-munge-key

COPY slurm.conf /etc/slurm/slurm.conf
COPY gres.conf /etc/slurm/gres.conf
COPY slurmdbd.conf /etc/slurm/slurmdbd.conf

COPY slurmctld-supervisord.conf /etc/
COPY slurmdbd-supervisord.conf /etc/

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY supervisord-eventlistener.sh /supervisord-eventlistener.sh

ADD https://github.com/krallin/tini/releases/download/v0.18.0/tini /usr/sbin/tini
RUN chmod +x /usr/sbin/tini

ENTRYPOINT ["/usr/sbin/tini", "--", "/docker-entrypoint.sh"]

