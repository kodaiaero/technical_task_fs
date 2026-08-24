FROM golang:1.25-alpine AS build

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 go build -trimpath -o /out/consumer .

FROM alpine:3
RUN adduser -D -u 10001 consumer
USER consumer
COPY --from=build /out/consumer /usr/local/bin/consumer
ENTRYPOINT ["consumer"]
