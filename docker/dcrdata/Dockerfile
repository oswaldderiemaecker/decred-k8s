FROM golang:1.11.1

RUN apt-get update && apt-get install -y vim tree lsof git gcc musl-dev jq curl dnsutils
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -
RUN apt-get install -y nodejs

RUN useradd --shell /bin/bash decred -m && chown -R decred:decred /home/decred
ENV GOPATH=/home/decred/go
ENV PATH=/go/bin:/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$GOPATH/bin
ENV DCRSRC_PATH=$GOPATH/src/github.com/decred/
ENV GO111MODULE=on

WORKDIR $DCRSRC_PATH
RUN git clone https://github.com/decred/dcrd.git
RUN chown -R decred:decred $GOPATH 
WORKDIR $DCRSRC_PATH/dcrd

USER decred
ENV GO111MODULE=on
RUN go get -d -v ./...
RUN go install . ./cmd/...

WORKDIR $DCRSRC_PATH
RUN git clone https://github.com/decred/dcrdata.git
RUN chown -R decred:decred $GOPATH 
WORKDIR $DCRSRC_PATH/dcrdata

USER decred
RUN go build
RUN go install

USER decred
RUN npm install
RUN npm run build

RUN cp -Rvpf $DCRSRC_PATH/dcrdata/public /home/decred/go/bin
RUN cp -Rvpf $DCRSRC_PATH/dcrdata/views /home/decred/go/bin

CMD /bin/bash
ENTRYPOINT ./dcrdata
