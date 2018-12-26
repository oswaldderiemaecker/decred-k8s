FROM golang:1.11.1

WORKDIR /go/src/app
RUN git clone https://github.com/decred/dcrd.git

WORKDIR /go/src/app/dcrd

ENV GO111MODULE=on
RUN go get -d -v ./...
RUN go install . ./cmd/...

WORKDIR /go/src/app
RUN git clone https://github.com/decred/dcrwallet.git 

WORKDIR /go/src/app/dcrwallet

ENV GO111MODULE=on
RUN go get -d -v ./...
RUN go install -v ./...

WORKDIR /go/src/app/dcrd

CMD ["dcrd"]
