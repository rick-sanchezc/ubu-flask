## Pull ubuntu:latest as base image
FROM ubuntu:latest 
## update image repo cache
RUN apt-get update
## install packages needed for python/flask
RUN apt-get install -y \
    python3 python3-pip libpcre3 libpcre3-dev
## setup user and to run service
ENV RUN_USER           wsgi 
ENV RUN_GROUP          wsgi
ENV RUN_UID            5001
ENV RUN_GID            5001
ENV RUN_HOME	       /opt/app
## set defautl path when exec image runtime
WORKDIR /opt/app
## add group and user into image
RUN groupadd --gid ${RUN_GID} ${RUN_GROUP} \
    && useradd --uid ${RUN_UID} --gid ${RUN_GID} --no-create-home ${RUN_USER}
## add pip requirements.txt to image
ADD conf/requirements.txt /opt/requirements.txt
## install requirements in the image
RUN pip3 install -r /opt/requirements.txt 
## cleanup image
RUN apt -y purge python3-pip libpcre3-dev \
    && rm -rf /opt/requirements.txt \
    && apt clean 
## add code/workarea to image
COPY ./app /opt/app
## grant user to copied code
RUN chown -R ${RUN_USER}:${RUN_GROUP} /opt/
## set user to run image when launched
USER ${RUN_USER}
## command to run when launched
CMD [ "uwsgi", "--ini", "/opt/app/project.ini" ]
