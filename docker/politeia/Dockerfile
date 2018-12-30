FROM golang:1.11.1

RUN apt-get update ; apt-get install -y dnsutils curl jq telnet screen; apt-get clean

RUN useradd -s /bin/bash -m -d /home/decred decred && chown -R decred:decred /home/decred
ENV GOPATH=/home/decred/go
ENV GOBIN=$GOPATH/bin
ENV PATH=/go/bin:/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$GOPATH/bin
ENV DCRSRC_PATH=$GOPATH/src/github.com/decred/
RUN mkdir -p $GOPATH/src/github.com/decred/
RUN mkdir $GOBIN
RUN chown -R decred:decred $GOPATH
USER decred

RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh

WORKDIR $DCRSRC_PATH
RUN git clone https://github.com/decred/politeia.git
WORKDIR $DCRSRC_PATH/politeia
RUN git checkout release-v1.3
RUN export GO111MODULE=on
RUN dep ensure
RUN go install -v ./...

CMD ["politeiad"]
