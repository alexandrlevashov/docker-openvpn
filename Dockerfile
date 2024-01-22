# Original credit: https://github.com/jpetazzo/dockvpn

# Smallest base image
FROM alpine:3.13
#alpine:latest

LABEL maintainer="Kyle Manna <kyle@kylemanna.com>"

# Testing: pamtester
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    #apk add --update openvpn iptables bash easy-rsa openvpn-auth-pam google-authenticator pamtester libqrencode && \
    apk add --update iptables bash easy-rsa google-authenticator pamtester libqrencode && \
    apk add --update git && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

#RUN apk update && apk add --no-cache build-base 

RUN apk add --update --no-cache \
    file \
    make \
    gcc \
    g++ \
    wget \
    linux-headers \
    openssl-dev \
    lzo-dev \
    linux-pam-dev \
    libnl3-dev libcap-ng libcap-ng-dev lz4 lz4-dev && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*


ADD ./openvpn-2.6.8_al.tar.gz /root

RUN cd /root && \ 
    cd /root/openvpn-2.6.8 && \
    ./configure --disable-dependency-tracking  && \
    make && make install  


# Needed by scripts
ENV OPENVPN=/etc/openvpn
ENV EASYRSA=/usr/share/easy-rsa \
    EASYRSA_CRL_DAYS=3650 \
    EASYRSA_PKI=$OPENVPN/pki

VOLUME ["/etc/openvpn"]

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp

CMD ["ovpn_run"]

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

# Add support for OTP authentication using a PAM module
ADD ./otp/openvpn /etc/pam.d/
