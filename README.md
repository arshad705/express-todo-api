# Getting Started Journey: Containerising and Deploying an Express Todo API to OpenShift

This demo takes a real Node.js/TypeScript REST API — a Todo app with full CRUD operations backed by an in-memory store — and walks through the complete journey from source code to a live, publicly accessible application running on OpenShift.

The app itself is a straightforward Express server written in TypeScript. It exposes five REST endpoints to create, read, update, and delete todos, and uses an in-memory `Map` as its database (no external DB required). The Node.js engine was upgraded from **16 to 20** as part of this exercise.

Using IBM Bob, the following was generated and configured from scratch:

- **[`Dockerfile`](./Dockerfile)** — A multi-stage build using `ubi9/nodejs-20-minimal` as the base image. Stage 1 installs all dependencies and compiles TypeScript into `dist/`. Stage 2 copies only the compiled output and installs production dependencies, keeping the final image lean. The container runs as non-root user `1001` throughout.
- **[`deployment.yaml`](./deployment.yaml)** — A Kubernetes `Deployment` that runs 3 replicas of the app, each pulling the container image and exposing port 3000.
- **[`service.yaml`](./service.yaml)** — A Kubernetes `Service` that routes internal cluster traffic to the running pods on port 3000.
- **[`route.yaml`](./route.yaml)** — An OpenShift `Route` that exposes the Service externally so the API can be called from outside the cluster.

## Prerequisites

- Node.js 20.x
- Docker or Podman
- Access to a container image registry (e.g. quay.io or Docker Hub)
- Access to an OpenShift cluster

## Tasks

### 1. Clone the Git Repo

```bash
git clone https://github.com/IBM/bob-demo.git
cd bob-demo/bob-get-started/express-todo-api
```

### 2. Create a Dockerfile to Build the Image

Created a [`Dockerfile`](./Dockerfile) using a multi-stage build pattern. Stage 1 compiles the TypeScript source to JavaScript. Stage 2 produces a minimal production image — only the compiled `dist/` folder and production `node_modules` are included. The image runs as non-root user `1001` for security compliance.

### 3. Test the Image Locally

Build and run the container on your machine to confirm it works before pushing:

```bash
docker build -t express-todo-api .
docker run -p 3000:3000 express-todo-api
```

Verify the API is responding:

```bash
curl http://localhost:3000/api/todos
```

### 4. Push the Image to a Container Registry

Tag the image with your Docker Hub username and push it so OpenShift can pull it during deployment:

```bash
docker tag express-todo-api <your-dockerhub-username>/todo-api:latest
docker push <your-dockerhub-username>/todo-api:latest
```

### 4.5. Create Your Own Namespace/Project in OpenShift

Create a dedicated project in your OpenShift cluster to isolate the app's resources:

```bash
oc new-project <your-project-name>
```

### 5. Deploy the App in OpenShift

Update the `image` field in [`deployment.yaml`](./deployment.yaml) to point to the image you pushed in step 4, then apply the manifest. This creates a `Deployment` that schedules 3 Pod replicas across the cluster's Nodes:

```bash
oc apply -f deployment.yaml
```

### 6. Expose the App with a Service and Route

Apply the `Service` to give the Pods a stable internal address, then apply the `Route` to expose the app publicly. OpenShift's router assigns a public hostname that forwards traffic through the Route → Service → Pods:

```bash
oc apply -f service.yaml
oc apply -f route.yaml
```

Get the public URL:

```bash
oc get route todo-api
```

The app is now accessible externally via that hostname.

## API Endpoints

- `GET /api/todos` - Get all todos
- `GET /api/todos/:id` - Get a specific todo
- `POST /api/todos` - Create a new todo
- `PUT /api/todos/:id` - Update a todo
- `DELETE /api/todos/:id` - Delete a todo

## Example Usage

```bash
# Get all todos
curl http://localhost:3000/api/todos

# Create a new todo
curl -X POST http://localhost:3000/api/todos \
  -H "Content-Type: application/json" \
  -d '{"title": "Learn Bob IDE"}'

# Update a todo
curl -X PUT http://localhost:3000/api/todos/{id} \
  -H "Content-Type: application/json" \
  -d '{"completed": true}'
```

## Getting Started (Local Development)

### Install dependencies

```bash
npm install
```

### Run in development mode

```bash
npm run dev
```

### Build for production

```bash
npm run build
npm start
```
