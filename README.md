## tragus/nfsd
tragus/webmin with a basic nfs server installed.

## Note to self

Using --net=host I've had good luck with pandrew/nfs-server.
Except for my weird apache/webmin base image stuff, this is essentially the
same and should behave.

## Why?

I use NFS in my home network to share storage between multiple physical and
virtual machines including dailyi-use desktops and laptops. As I deprecate the
VMs and move their functions to Docker, I need to maintain the services they
provide. In this case: NFS. I know there are several options available for
sharing and syncing data between containers but those don't solve my need for
doing the same with non-container clients. I've tried a few of the nfs
containers in the registry but didn't have any luck with them without making
modifications similar to the grossness described below. So... here is my own
attempt to build a workable (if not elegant) NFS server container.

## Building the image

```
git clone https://github.com/jcejohnson/docker-nfsd.git tragus-nfsd
cd tragus-nfsd
docker build -t tragus/nfsd .
```

## Running the container

Modify & use nfsd.launch to start the container. Use nfsd.shutdown to cleanly
shutdown the server or docker stop to terminate the instance more or less
immediately.

This is a mess at the moment. I can't figure out how to properly map the port(s)
so that clients can mount the server's exported filesystems. After wasting
several hours I decided to punt and just use --net=host. That's not without its
own issues but it'll do for now.

```
docker run -d \
  --privileged \
  --net=host    \
  --name nfsd    \
  \
  -e apache_ipaddress=192.168.42.51 \
  \
  -e nfsd_hostname=nfshost      \
  -e nfsd_domainname=tragus.org  \
  -e nfsd_ipaddress=192.168.42.51 \
  \
  -v /usr/local/containers/nfsd/etc:/etc    \
  -v /var/run/nfsd-control:/var/run/container-control \
  \
  tragus/nfsd
```

--privileged is needed for access to all /dev that we need

--net=host maps the host's network stack into the container. This is really
gross and should not be necessary if I can just work out the right set of
port mappings.

'-e apache_ipaddress=...' tells the tragus/apache apache2 instance to bind to
a specific interfae instead of all interfaces. This is important since
--net=host will make all of the hosts interfaces available to the container
and we may want some other container to also expose a webserver on some other
virtual ip or the host's ip.

'-e nfsd_*=...' is not really necessary but I don't like that my nfsd container
thinks its hostname is the same as the containing host.

## Persistent Data

Since apache, webmin and nfs all keep their configuration in /etc I took the
easy route and extracted all of /etc from my first boot of the image into
/usr/local/containers/<containername>/etc. This gives me persistence of all
of their configuration and I can use a similar technique later for managing
the logs and other bits if I want.

## About nfsd Processes

When you 'ps -aef' on the container host you will see several nfsd* processes.
These are actually bits of the kernel and very necessary for the in-container
kernel-nfs-server to function.

## TODO

This is gross in lots of ways.

## See Also
Please read the tragus/webmin documentation to for current warnings:
https://github.com/jcejohnson/docker-webmin
(That document will point you to tragus/apache which you should also read. And
that will point you to tragus/ubuntu which you should *also* read. -- it's
turtles all the way down...)
