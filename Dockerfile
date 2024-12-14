FROM golang:1.20-alpine

WORKDIR /app

COPY . .
RUN go build  port-knocking.go

EXPOSE 1234 5678 3456
CMD ["./port-knocking"]
