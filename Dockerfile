FROM tragus/webmin

MAINTAINER James Johnson

RUN apt-get update && \
    apt-get -y install nfs-kernel-server

EXPOSE 80/tcp 111/udp 111/tcp 2049/tcp 2049/udp

# Perform build-time configuration of the container
ADD nfsd.configure   /usr/local/bin/nfsd.configure
RUN chmod +x /usr/local/bin/nfsd.configure && /usr/local/bin/nfsd.configure

# Install any other scripts
ADD nfsd.start      /usr/local/bin/apache2.start.d/nfsd.start
ADD nfsd.stop       /usr/local/bin/apache2.stop.d/nfsd.stop

# We build this off of the webmin image which, in turn, is built off of
# the apache image. webmin will give us an easy way to administer our
# nfsd image. Because of this, we can use the apache2.start script.
ENTRYPOINT ["/usr/local/bin/apache2.start"]
