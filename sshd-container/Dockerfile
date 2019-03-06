FROM alpine:3.7
WORKDIR /
RUN apk add --update bash openssh-server 

# setup sshd
COPY sshd_config /etc/ssh

EXPOSE 22

