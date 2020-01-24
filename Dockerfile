FROM centos:7

ARG SLURM_TAG=slurm-19-05-5-1

ARG MUNGEUSER=891
ARG SLURMUSER=16924
ARG SLURMGROUP=1034

RUN groupadd -g $MUNGEUSER munge \
    && useradd  -m -c "MUNGE Uid 'N' Gid Emporium" -d /var/lib/munge -u $MUNGEUSER -g munge  -s /sbin/nologin munge \
    && groupadd -g $SLURMGROUP slurm \
    && useradd  -m -c "SLURM workload manager" -d /var/lib/slurm -u $SLURMUSER -g slurm  -s /bin/bash slurm

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
        wget \
        zlib-devel \
        pam-devel numactl numactl-devel hwloc hwloc-devel lua lua-devel readline-devel rrdtool-devel ncurses-devel man2html libibmad libibumad rpm-build mysql-devel rpm-build gcc  libssh2-devel  gtk2-devel  libibmad libibumad perl-Switch perl-ExtUtils-MakeMaker \
        sssd nss-pam-ldapd \
        python-setuptools \
        golang \
    && yum clean all \
    && rm -rf /var/cache/yum

RUN easy_install supervisor

# setup accounts
COPY sssd/nsswitch.conf sssd/nslcd.conf /etc/
COPY sssd/sssd.conf /etc/sssd/sssd.conf

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
    && rm -rf slurm \
    && mkdir /etc/sysconfig/slurm \
        /var/spool/slurmd \
        /var/run/slurmd \
        /var/lib/slurmd \
        /var/log/slurm \
    && chown slurm:root /var/spool/slurmd \
        /var/run/slurmd \
        /var/lib/slurmd \
        /var/log/slurm \
    && /sbin/create-munge-key

# install monitoring
RUN set -ex \
    && git clone https://github.com/vpenso/prometheus-slurm-exporter.git \
    && pushd prometheus-slurm-exporter \
    && mkdir /tmp/build && export GOPATH=/tmp/build \
    && make build \
    && mv /prometheus-slurm-exporter/bin/prometheus-slurm-exporter /usr/bin/ \
    && popd \
    && rm -rf /prometheus-slurm-exporter /tmp/build

COPY etc/slurm.conf etc/gres.conf etc/cgroup.conf etc/cgroup_allowed_devices_file.conf etc/slurmdbd.conf  /etc/slurm/

# configs
ENV MUNGE_ARGS='' SLURMDBD_ARGS='' SLURMCTLD_ARGS=''
COPY slurmctld-supervisord.conf slurmdbd-supervisord.conf  /etc/

# startup
COPY docker-entrypoint.sh supervisord-eventlistener.sh /

ADD https://github.com/krallin/tini/releases/download/v0.18.0/tini /usr/sbin/tini
RUN chmod +x /usr/sbin/tini

RUN chmod 600 /etc/sssd/sssd.conf

ENTRYPOINT ["/usr/sbin/tini", "--", "/docker-entrypoint.sh"]

