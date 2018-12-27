FROM golang:1.11-alpine3.8

RUN apk update && apk add vim tree lsof bash git gcc musl-dev
RUN adduser -s /bin/bash -D -h /home/decred decred && chown -R decred:decred /home/decred
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

USER root
RUN apk add nodejs npm

USER decred
RUN npm install
RUN npm run build

RUN cp -Rvpf $DCRSRC_PATH/dcrdata/public /home/decred/go/bin
RUN cp -Rvpf $DCRSRC_PATH/dcrdata/views /home/decred/go/bin

CMD /bin/bash
ENTRYPOINT ./dcrdata
