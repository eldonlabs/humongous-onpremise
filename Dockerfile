FROM eldonlabs/humongous-onpremise:latest

WORKDIR /app
COPY . /app

CMD ["/app/bin/hio"]