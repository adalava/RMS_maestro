
# https://www.docker.com/blog/multi-arch-images/

#docker build -t adalava/rms --platform linux/amd64 .
#docker build -t adalava/rms --platform linux/arm64 .
#linux/arm/v7

docker buildx build --platform linux/amd64,linux/arm64 -t adalava/rms:latest --push .
#docker buildx build --platform linux/amd64 -t adalava/rms:latest --push .

