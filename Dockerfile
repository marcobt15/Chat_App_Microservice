# Use the official Rust image as the base image
FROM rust:1.65 as builder

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy the Cargo.toml and Cargo.lock files
COPY Cargo.toml Cargo.lock ./

# Create a target directory for build caching
RUN mkdir src && echo "fn main() {}" > src/main.rs

# Pre-build dependencies
RUN cargo build --release && rm -rf src

# Copy the source code to the container
COPY . .

# Build the application
RUN cargo build --release

# Use a smaller base image for the final executable
FROM debian:buster-slim

# Install dependencies required by Diesel and the final binary
RUN apt-get update && apt-get install -y \
    libpq-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy the compiled binary from the builder stage
COPY --from=builder /usr/src/app/target/release/microservice_rs /usr/local/bin/microservice_rs

# Set environment variables
ENV DATABASE_URL=postgres://postgres@db:5432/microservice_db

# Expose the port that the application will run on
EXPOSE 8080

# Run the application
CMD ["microservice_rs"]
