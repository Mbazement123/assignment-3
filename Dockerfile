FROM alpine:latest

# Install required packages for system info, networking, and connectivity checks
RUN apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    dnsmasq \
    bind-tools \
    iproute2 \
    iputils \
    netcat-openbsd \
    net-tools \
    procps \
    && rm -rf /var/cache/apk/*

# Create app directory and copy application
RUN mkdir -p /app/app
WORKDIR /app

# Copy the entire app directory (or just the app.sh file)
COPY app/app.sh /app/app/app.sh

# Make app.sh executable
RUN chmod +x /app/app/app.sh

# Set entrypoint and default command
ENTRYPOINT ["/app/app/app.sh"]
CMD ["help"]
