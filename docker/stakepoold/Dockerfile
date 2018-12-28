FROM golang:1.11.1

RUN apt-get update ; apt-get install -y dnsutils wget telnet screen; apt-get clean

RUN useradd -s /bin/bash -m -d /home/decred decred && chown -R decred:decred /home/decred
ENV GOPATH=/home/decred/go
ENV PATH=/go/bin:/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$GOPATH/bin
ENV DCRSRC_PATH=$GOPATH/src/github.com/decred/
RUN mkdir -p $GOPATH/src/github.com/decred/
RUN chown -R decred:decred $GOPATH 
USER decred
 
WORKDIR $DCRSRC_PATH
RUN git clone https://github.com/decred/dcrd.git
WORKDIR $DCRSRC_PATH/dcrd
RUN git checkout release-v1.4

ENV GO111MODULE=on
RUN go build
RUN go install . ./cmd/...

WORKDIR $DCRSRC_PATH
RUN git clone https://github.com/decred/dcrwallet.git
WORKDIR $DCRSRC_PATH/dcrwallet
RUN git checkout release-v1.4

ENV GO111MODULE=on
RUN go build
RUN go install -v ./...

WORKDIR $DCRSRC_PATH
RUN git clone https://github.com/decred/dcrstakepool.git
WORKDIR $DCRSRC_PATH/dcrstakepool/backend/stakepoold

RUN go build
RUN go install -v ./...

WORKDIR $DCRSRC_PATH/dcrd

CMD ["dcrd"]
