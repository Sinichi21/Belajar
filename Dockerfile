FROM golang:1.17-alpine as build

ARG USERNAME_GITHUB
ARG TOKEN_GITHUB

RUN apk update
RUN apk add git 

WORKDIR /app

COPY go.mod /app/
COPY go.sum /app/

RUN git config --global url."https://${USERNAME_GITHUB}:${TOKEN_GITHUB}@github.com" instedadof "https://github.com"

RUN go mod download
RUN go mod tidy

COPY . /app/
RUN go build -o /app/main

#------------------------------
FROM alpine:3.16.0
WORKDIR /app

#web service
EXPOSE 8080
COPY --from=build /app/conf/.env.example /app/conf/.env
COPY --from=build /app/main /app/main

CMD ["./main"]