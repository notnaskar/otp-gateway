# Build Stage
FROM golang:1.23-alpine AS builder
WORKDIR /app
# Install git for fetching dependencies if needed
RUN apk add --no-cache git
COPY . .
# Build the binary
RUN go build -o otpgateway ./cmd/otpgateway

# Final Stage
FROM alpine:latest
WORKDIR /app
RUN apk add --no-cache ca-certificates
# Copy binary from builder
COPY --from=builder /app/otpgateway .
# Copy static assets (required for templates)
COPY --from=builder /app/static ./static

# Copy config.toml if it exists locally during build, 
# otherwise the user must mount it or it will fail if not found.
# COPY config.toml config.toml 

# Copy sample config as default (prevents build failure if config.toml is ignored)
COPY config.sample.toml config.toml

# Expose port
EXPOSE 9000

# Run
CMD ["./otpgateway", "--config", "./config.toml"]
