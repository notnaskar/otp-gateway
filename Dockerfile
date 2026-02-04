# Stage 1: Build the Go binary
FROM golang:1.23-alpine AS builder

WORKDIR /app
# Install git for dependencies
RUN apk add --no-cache git
COPY . .

# Build the binary named 'otpgateway'
RUN go mod download
RUN go build -o otpgateway ./cmd/otpgateway

# Stage 2: Create the runtime image
FROM alpine:latest

# Install CA certificates for WhatsApp HTTPS calls
RUN apk add --no-cache ca-certificates

WORKDIR /app

# Copy the binary and assets from Stage 1
COPY --from=builder /app/otpgateway .
# Copy static assets (important for email templates if used later)
COPY --from=builder /app/static ./static
# Copy sample config to prevent crash if mount fails (fallback)
COPY --from=builder /app/config.sample.toml config.sample.toml

# Expose the port
EXPOSE 9000

# Run the app
CMD ["./otpgateway"]
