# Confluent Health AI Demo Quickstart Guide

## Project Setup

```sh
# Step 1: Install the necessary dependencies.
npm i

# Step 2: Start the development server with auto-reloading and an instant preview.
npm run dev

# Step 3: navigate to the url
http://localhost:8001
```

## Docker Setup

#### Running the React App with Docker
This guide will walk you through setting up and running your React application in a Docker container. Ensure Docker is installed and running on your system before you proceed.

### Building the Docker Image
First, we need to build the Docker image from your project directory. This process involves compiling your React app and preparing it to run in a container.

Open a terminal.

Navigate to the root of the Frontend project where the Dockerfile is located.

Run the following command to build the Docker image:

```bash
docker build -t frontend-app .
```

In the command above, `frontend-app` is the name we are giving to our Docker image, but you can name it whatever you like. The `.` at the end of the command indicates that Docker should look for the Dockerfile in the current directory.

#### Running the Docker Container
After the image has been successfully built, you can run it in a Docker container.

To run the container and make your application accessible on port 8001, use the following command:

```bash
docker run -p 8001:80 frontend-app
```

`-p 8001:80` maps port `8001` on your local machine to port `80` in the Docker container, allowing you to access the app via http://localhost:8001 in your web browser.

#### Accessing the Application
Open your web browser.

Visit http://localhost:8001 to view your React application.

#### Environment Variables

The application relies on the environment variable `REACT_APP_WS_URL`, you can pass it at runtime using the `-e` flag with docker run. Here's an example:

```bash
docker run -e REACT_APP_WS_URL=ws://your-websocket-url -p 8080:80 my-react-app
```

Replace `ws://your-websocket-url` with the actual WebSocket URL

#### Debugging and Logs

If you need to troubleshoot or debug your application, viewing Docker container logs can be extremely helpful. Use the following command to view the logs of your running container:

```bash
docker logs <container_id>
```

You can find the <container_id> by running `docker ps` and looking at the list of running containers.

## What technologies are used for this project?

This project is built with .

- Vite
- TypeScript
- React
- shadcn-ui
- Tailwind CSS
