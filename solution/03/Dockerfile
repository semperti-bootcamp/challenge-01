# Stage 1: Build the application
FROM node:18 AS builder

# Set the working directory
WORKDIR /app

# Copy the package.json and package-lock.json files
COPY package*.json ./

# Install all dependencies
RUN npm install --production=false

# Copy the rest of the application code
COPY . .

# Build the application
RUN npm run build

# Stage 2: Set up the production environment
FROM node:18-alpine AS production

# Instalar curl para el health check
RUN apk add --no-cache curl

# Create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set the working directory
WORKDIR /app

# Copy only the essential files from the builder stage
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/app.js .

# Set the user to the non-root user
USER appuser

# Expose the application port
EXPOSE 3000

# Health check (bonus)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 CMD curl -f http://localhost:3000 || exit 1

# Start the application
CMD ["node", "app.js"]
