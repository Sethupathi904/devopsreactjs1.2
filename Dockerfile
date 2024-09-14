# Stage 1: Build the ReactJS application
FROM node:18 AS build

# Set working directory
WORKDIR /app

# Install production dependencies only
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Copy the rest of the application source code
COPY . .

# Build the React application
ENV NODE_OPTIONS=--openssl-legacy-provider
RUN npm run build

# Stage 2: Serve the ReactJS application with Nginx
FROM nginx:alpine

# Copy built React app from the 'build' stage to Nginx's HTML directory
COPY --from=build /app/build /usr/share/nginx/html

# Expose port 80 to serve the app
EXPOSE 80

# Start Nginx in the foreground (default Nginx command)
CMD ["nginx", "-g", "daemon off;"]
