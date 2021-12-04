# syntax=docker/dockerfile:1

FROM golang:1.17-alpine3.14 as builder

WORKDIR /app

COPY ./go.mod ./
COPY ./go.sum ./
RUN go mod download

COPY ./app/*.go ./

RUN go build -o server

FROM alpine:3.14
RUN apk --no-cache add ca-certificates
WORKDIR /app
COPY --from=builder /app/server ./

CMD [ "./server" ]
