FROM alpine:latest

WORKDIR /app

# Copy the pre-built server executable
COPY server /app/

# Expose the port your server listens on
EXPOSE 9090

# Run the server (you'll need to provide the Redis address as an argument)
ENTRYPOINT ["./server"]