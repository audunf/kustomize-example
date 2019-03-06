FROM node:8.11.3-alpine as builder

RUN mkdir -p /background-worker
WORKDIR /background-worker

COPY package.json ./

RUN npm i -g npm@latest && \
    npm audit fix

FROM node:8.11.3-alpine

# Create a group/user different from root, which can run processes for us
# Create user 'foouser', user id=3000, no password
RUN addgroup -g 3000 foogroup && \
    adduser -D -s /bin/sh -u 3000 -G foogroup foouser

WORKDIR /home/foouser

## From 'builder' stage copy over the artifacts
COPY --from=builder /background-worker .

# copy the source code
COPY src ./src
COPY run-worker.sh .

RUN echo "*/5 * * * * /home/foouser/run-worker.sh" | /usr/bin/crontab -u foouser -

RUN chown -R foouser:foogroup /home/foouser && \
    chmod 0444 $(find /home/foouser -type f) && \
    chmod 0755 /home/foouser/run-worker.sh

