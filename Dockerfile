# syntax=docker/dockerfile:1
# ==============================================================================
# Stage 1: Build Web SPA Assets
# ==============================================================================
FROM node:24-alpine AS web-builder

WORKDIR /web

COPY web/package.json web/package-lock.json ./
RUN npm ci

COPY web/ .

ARG VITE_API_BASE_URL=/api/v1
ARG ADMIN_MODE=true

ENV VITE_API_BASE_URL=${VITE_API_BASE_URL} \
    ADMIN_MODE=${ADMIN_MODE}

RUN npm run build

# ==============================================================================
# Stage 2: Build Static Go Binaries (CGO enabled for mattn/go-sqlite3)
# ==============================================================================
FROM golang:1.27-alpine AS server-builder

RUN apk add --no-cache ca-certificates tzdata gcc musl-dev

WORKDIR /workspace

COPY server/go.mod server/go.sum ./
RUN go mod download

COPY server/ .

RUN CGO_ENABLED=1 go build \
    -trimpath \
    -ldflags="-s -w -extldflags '-static'" \
    -o /bin/resumeee-server \
    ./cmd/server && \
    CGO_ENABLED=1 go build \
    -trimpath \
    -ldflags="-s -w -extldflags '-static'" \
    -o /bin/resumeee-mcp \
    ./cmd/mcp

# ==============================================================================
# Stage 3: Unified Unprivileged Runtime (NGINX :8080 + Go Server :8081)
# ==============================================================================
FROM nginx:alpine AS runtime

RUN apk add --no-cache ca-certificates tzdata curl mailcap && \
    addgroup -g 10001 -S appgroup && \
    adduser -u 10001 -S appuser -G appgroup && \
    sed -i '/user  nginx;/d' /etc/nginx/nginx.conf && \
    sed -i 's,/run/nginx.pid,/tmp/nginx.pid,g' /etc/nginx/nginx.conf && \
    sed -i '/include \/etc\/nginx\/conf.d\/\*\.conf;/i \
    client_body_temp_path /tmp/client_temp;\n    proxy_temp_path /tmp/proxy_temp_path;\n    fastcgi_temp_path /tmp/fastcgi_temp;\n    uwsgi_temp_path /tmp/uwsgi_temp;\n    scgi_temp_path /tmp/scgi_temp;\n' /etc/nginx/nginx.conf && \
    rm -rf /etc/nginx/conf.d/* && \
    mkdir -p /data /var/cache/nginx /var/log/nginx /usr/share/nginx/html /tmp/client_temp /tmp/proxy_temp_path /tmp/fastcgi_temp /tmp/uwsgi_temp /tmp/scgi_temp && \
    chown -R 10001:10001 /data /var/cache/nginx /var/log/nginx /usr/share/nginx/html /tmp

# Copy NGINX configuration and point /api/ proxy to local Go backend on 127.0.0.1:8081
COPY web/deploy/security_headers.conf /etc/nginx/security_headers.conf
COPY web/deploy/nginx.conf /etc/nginx/conf.d/default.conf
RUN sed -i '/resolver /d' /etc/nginx/conf.d/default.conf && \
    sed -i 's,http://server:8080,http://127.0.0.1:8081,g' /etc/nginx/conf.d/default.conf && \
    chown -R 10001:10001 /etc/nginx/conf.d /etc/nginx/security_headers.conf

# Copy compiled Web SPA assets and Go binaries
COPY --from=web-builder /web/dist /usr/share/nginx/html
COPY --from=server-builder /bin/resumeee-server /usr/local/bin/resumeee-server
COPY --from=server-builder /bin/resumeee-mcp /usr/local/bin/resumeee-mcp

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    chown -R 10001:10001 /usr/share/nginx/html

WORKDIR /data

ENV DB_PATH=/data/resumeee.db \
    ADMIN_MODE=true \
    BACKEND_PORT=8081 \
    ENV=production \
    LOG_LEVEL=INFO

USER 10001:10001

EXPOSE 8080 8081

VOLUME ["/data"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD wget -q --spider http://127.0.0.1:8080/api/v1/health || exit 1

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["server"]
