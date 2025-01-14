FROM golang:1.21 as base 

WORKDIR /app

COPY go.mod .

RUN go mod download

COPY . .

RUN go build -o main .

#Expose 8080

#CMD ["./main"]


#Final stage - Distroless Image

FROM gcr.io/distroless/base

#Binary 
COPY --from=base /app/main .   

COPY --from=base /app/static ./static

EXPOSE 8080

CMD ["./main"]
