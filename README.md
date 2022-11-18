# alpine-perl-docker
### Alpine Perl Base Image
This is an attempt to produce a small Perl base image to use with containerized Perl Applications. 

The current image is based on Perl 5.36.0 and uses a multi-stage build to copy only the compiled assets to a fresh Alpine image, reducing the overall size of the image to around 65MB.

### Docker Build
```
docker build --tag alpine-perl:latest --tag alpine-perl:5.36.0 .
```

[Docker Image Repository](https://hub.docker.com/r/rshingleton/alpine-perl)
