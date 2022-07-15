FROM eldonlabs/humongous-onpremise:1.0.333

WORKDIR /app
COPY . /app

CMD ["/app/bin/hio"]