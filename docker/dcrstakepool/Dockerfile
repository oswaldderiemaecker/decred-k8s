FROM golang:1.11.1

WORKDIR /go/src/app
RUN git clone https://github.com/decred/dcrd.git
WORKDIR /go/src/app/dcrd
RUN git checkout release-v1.4

ENV GO111MODULE=on
RUN go get -d -v ./...
RUN go install . ./cmd/...

WORKDIR /go/src/app
RUN git clone https://github.com/decred/dcrwallet.git
WORKDIR /go/src/app/dcrwallet
RUN git checkout release-v1.4

ENV GO111MODULE=on
RUN go get -d -v ./...
RUN go install -v ./...

WORKDIR /go/src/app
RUN git clone https://github.com/decred/dcrstakepool.git
WORKDIR /go/src/app/dcrstakepool

RUN go build
RUN go install -v ./...

RUN apt-get update ; apt-get install -y dnsutils telnet screen; apt-get clean

RUN mkdir ~/.dcrstakepool
WORKDIR ~/.dcrstakepool

CMD ["dcrstakepool"]
