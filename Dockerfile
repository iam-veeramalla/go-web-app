FROM golang:1.22.5 as base

WORKDIR /app

#Commands written after this would be written in this work directory

COPY go.mod .

#dependencises can be copied required for running this app

RUN go mod download

#right now there were no dependencies required and go.mod didn't have any dependency 
#but if dev team add dependeny then this command would help to run and download required dependency

COPY . .

#Copy all the go files in app dir (source and des)

RUN go build -o main .

#now build the app like we did in local, this will create binary files

#Now one option can be just stop here and add CMD ["./main"] in the next line and expose port 8080
#This would start the app, but here this is single stage Dockerfile and image size is large
#we want to make sure image is of reduced size and secured
#so we will use distroless image

#Now new stage is created with distroless image
#Final Stage

FROM gcr.io/distroless/base

#famous distroless image

COPY --from=base /app/main .

#Copy binary files from app dir created from base image to default dir

COPY --from=base /app/static ./static

#We have to copy the static files also and here they are sent to newer dir static

EXPOSE 8080

CMD [ "./main" ]

#Add the entrypoint main binary file and expose the port 8080