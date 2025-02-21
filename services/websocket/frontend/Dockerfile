# Stage 1: Build the React application
FROM node:23-alpine AS builder

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json/npm-shrinkwrap.json to workdir in container
COPY package*.json ./

# Install dependencies including 'devDependencies' for building the app
RUN npm install

# Copy the rest of your app's source code from your host to your image filesystem.
COPY ../../../frontend .

# Build the app
RUN npm run build

# Stage 2: Serve the build with Nginx
FROM nginx:stable-alpine AS server

# Copy the build output to replace the default nginx contents.
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 80 to the outside once the container has launched
EXPOSE 80

# Command to run when the container starts
CMD ["nginx", "-g", "daemon off;"]
