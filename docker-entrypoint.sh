#!/bin/sh
set -e

if [ "$1" = "mcp" ] || [ "$1" = "resumeee-mcp" ]; then
    shift
    exec /usr/local/bin/resumeee-mcp "$@"
fi

if [ "$1" = "server" ] || [ "$1" = "resumeee-server" ]; then
    shift
fi

# Start the Go API/MCP server on the internal backend port, then run NGINX on :8080
PORT="${BACKEND_PORT:-8081}" /usr/local/bin/resumeee-server "$@" &
SERVER_PID=$!

nginx -g "daemon off;" &
NGINX_PID=$!

cleanup() {
    kill -TERM "$SERVER_PID" "$NGINX_PID" 2>/dev/null || true
}
trap cleanup TERM INT

while kill -0 "$SERVER_PID" 2>/dev/null && kill -0 "$NGINX_PID" 2>/dev/null; do
    sleep 1
done

cleanup
wait "$SERVER_PID" 2>/dev/null || true
wait "$NGINX_PID" 2>/dev/null || true
exit 1
