# Stage 1: Build dependencies
FROM alpine:latest AS dependencies

# Set working directory
WORKDIR /app

# Install Node.js and npm
RUN apk add --no-cache nodejs npm

# Copy only package.json to leverage Docker cache
COPY package.json ./

# Install dependencies
RUN npm install

# Stage 2: Final image
FROM alpine:latest

# Metadata labels
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.docker.cmd="docker run -d -p 3000:3000 --name alpine_timeoff"

# Install runtime dependencies and clean up cache
RUN apk add --no-cache \
    nodejs npm vim && \
    rm -rf /var/cache/apk/*

# Set working directory
WORKDIR /app

# Copy application source code
COPY . .

# Copy dependencies from the build stage
COPY --from=dependencies /app/node_modules ./node_modules

# Add non-root user for better security
RUN adduser --system --home /app app
USER app

# Set default command
CMD ["npm", "start"]

# Expose the application port
EXPOSE 3000
