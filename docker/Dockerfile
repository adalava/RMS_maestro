FROM ubuntu:22.04

SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

RUN apt -y update && \
    apt -y install git \
        ffmpeg cmake nano mc \
        gstreamer1.0-python3-plugin-loader \
        gstreamer1.0-plugins-good \
        python3-opencv sudo iputils-ping tmux \
        python3-pip python3-tk vim

RUN mkdir  ~/source && cd ~/source && \
    git clone https://github.com/adalava/RMS.git

RUN  pip install --upgrade pip  && pip install virtualenv setuptools && \
         cd ~ && virtualenv --system-site-packages vRMS && source vRMS/bin/activate  && \
         pip install cython && \
         echo "source ~/vRMS/bin/activate" > /root/.bashrc && \
         echo "cd ~/source/RMS" >> /root/.bashrc

RUN pip install flask flask-sqlalchemy flask-login simplepam shelljob flask_shell2http Flask-AutoIndex

# needed by istrastream
RUN apt -y install imagemagick ffmpeg curl

ARG CACHEBUST=1
RUN cd ~/source/RMS && \ 
    git pull && \
    git checkout docker_x86_64 && \
    source ~/vRMS/bin/activate  && \
    pip install .



COPY ./extra/maestro /maestro
COPY ./extra/entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 5000