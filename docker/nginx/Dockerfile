FROM nginx:1.7

COPY auto-reload-nginx.sh /home/auto-reload-nginx.sh
RUN chmod +x /home/auto-reload-nginx.sh

RUN apt-get update && apt-get install -y inotify-tools procps
