# syntax=docker/dockerfile:1
FROM amd64/ubuntu:latest

ADD ./institute-person-api /
ADD ./PATCH /

EXPOSE 8081:8081

CMD ["/institute-person-api"]