FROM --platform=${BUILDPLATFORM} golang:bullseye@sha256:80ede0f12980ec4fc580fa651aabff041d46d1255b323fa0b740ecbce9f89256 as builder

WORKDIR /build
COPY . . 
ENV CGO_ENABLED=0
ARG TARGETOS TARGETARCH
RUN  --mount=type=cache,target=/go/pkg/mod \
     --mount=type=cache,target=/root/.cache/go-build \
     GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o trufflehog .

FROM alpine:3.15@sha256:69463fdff1f025c908939e86d4714b4d5518776954ca627cbeff4c74bcea5b22
RUN apk add --no-cache git ca-certificates \
    && rm -rf /var/cache/apk/* && \
    update-ca-certificates
COPY --from=builder /build/trufflehog /usr/bin/trufflehog
COPY entrypoint.sh /etc/entrypoint.sh
RUN chmod +x /etc/entrypoint.sh
ENTRYPOINT ["/etc/entrypoint.sh"]
