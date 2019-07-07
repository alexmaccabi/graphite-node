FROM ubuntu:16.04

RUN apt-get update
RUN add-apt-repository ppa:jonathonf/python-3.6
RUN apt-get install -y software-properties-common 
RUN apt-get update

# Install required packages
RUN apt-get install -y build-essential python3.6 python3.6-dev python3-pip libcairo2-dev curl git nginx-light supervisor

# Install Python related modules
RUN python3.6 -m pip install pip --upgrade
RUN python3.6 -m pip install wheel
RUN python3.6 -m pip install redis
RUN pip install --upgrade setuptools
RUN pip install gunicorn

#Install nodejs for kube-watch
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get update
RUN apt-get install -y nodejs

# Install redis-server and redis-cli
RUN apt-get install -y redis-server redis-tools

#RUN     pip install Twisted==13.2.0

RUN     pip install Twisted==18.7.0
RUN     pip install pytz

RUN     git clone https://github.com/graphite-project/whisper.git /src/whisper            &&\
        cd /src/whisper                                                                   &&\
        git checkout 1.1.5                                                                &&\
        python3.6 setup.py install

RUN     git clone https://github.com/graphite-project/carbon.git /src/carbon              &&\
        cd /src/carbon                                                                    &&\
        git checkout 1.1.5                                                                &&\
        python3.6 setup.py install


RUN     git clone https://github.com/graphite-project/graphite-web.git /src/graphite-web  &&\
        cd /src/graphite-web                                                              &&\
        git checkout 1.1.5								                                                &&\
        python3.6 setup.py install                                                           &&\
        pip install -r requirements.txt                                                   &&\
        python3.6 check-dependencies.py

# fixes fatal error "Your WhiteNoise configuration is incompatible with WhiteNoise v4.0"
RUN     /usr/bin/yes | pip uninstall whitenoise                                           &&\
        pip install "whitenoise<4"

# Add system service config
ADD	./nginx/nginx.conf /etc/nginx/nginx.conf
ADD	./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add graphite config
ADD	./webapp/initial_data.json /opt/graphite/webapp/graphite/initial_data.json
#ADD	./webapp/local_settings.py /opt/graphite/webapp/graphite/local_settings.py
ADD	./webapp/local_settings.py.template /opt/graphite/webapp/graphite/local_settings.py.template
ADD	./conf/carbon.conf /opt/graphite/conf/carbon.conf
ADD	./conf/storage-schemas.conf /opt/graphite/conf/storage-schemas.conf
ADD	./conf/storage-aggregation.conf /opt/graphite/conf/storage-aggregation.conf
RUN	mkdir -p /opt/graphite/storage/whisper
RUN	touch /opt/graphite/storage/graphite.db /opt/graphite/storage/index
RUN	chmod 0775 /opt/graphite/storage /opt/graphite/storage/whisper
RUN	chmod 0664 /opt/graphite/storage/graphite.db
RUN cp /src/graphite-web/webapp/manage.py /opt/graphite/webapp

RUN mkdir /kube-watch
RUN cd /kube-watch && npm install hashring kubernetes-client@5 json-stream
ADD kube-watch.js /kube-watch/kube-watch.js

# Install curator cron job
ADD curator/cron /etc/cron.d/curator.cron
ADD curator/run.sh /etc/cron.d/curator.sh
RUN chmod +x /etc/cron.d/curator.sh

ADD entrypoint.sh /entrypoint.sh

# Nginx
EXPOSE	80
# Carbon pickle receiver port
EXPOSE	2004
RUN chmod +x entrypoint.sh
CMD	["/entrypoint.sh"]
