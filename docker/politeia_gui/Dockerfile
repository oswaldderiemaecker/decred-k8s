FROM node:8.15.0-jessie

RUN apt-get update ; apt-get install -y dnsutils curl jq telnet screen; apt-get clean

RUN npm install --global cross-env

RUN git clone https://github.com/decred/politeiagui.git
WORKDIR politeiagui
RUN yarn
RUN yarn build
RUN yarn global add serve

CMD ["serve", "-s", "build"]
