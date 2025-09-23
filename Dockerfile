# Stage 1: Build the Angular application
# Use a Node.js base image with a specific version for stability.
FROM node:20.19.0-alpine AS build

# Set the working directory inside the container.
WORKDIR /app

# Copy package.json and package-lock.json to leverage Docker's layer caching.
COPY package*.json ./

# Install project dependencies.|| --legacy-peer-deps :- This is a quick fix that tells npm to ignore peer dependency conflicts and install the packages anyway
RUN npm install --legacy-peer-deps

# Copy the rest of the application source code.
COPY . .

# Build the Angular application for production. The --output-path flag specifies where to put the build files.
RUN npm run build -- --output-path=./dist/angular-conduit

# Stage 2: Serve the application with Nginx
# Use a lightweight Nginx image.
FROM nginx:alpine

# Copy the custom Nginx configuration file into the container.
#COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the built Angular application from the 'build' stage into the Nginx server's directory.
#RUN rm -rf /usr/share/nginx/html/*
COPY --from=build /app/dist/angular-conduit/browser /usr/share/nginx/html

# Expose port 80 to allow incoming traffic.
EXPOSE 80

# Start Nginx in the foreground.
CMD ["nginx", "-g", "daemon off;"]
