# ── Stage 1: Build ──────────────────────────────────────────────────────────
FROM registry.access.redhat.com/ubi9/nodejs-20-minimal:latest AS builder

USER root

WORKDIR /app

# Copy dependency manifests first (layer-cache friendly)
COPY package*.json ./

# Fix permissions so npm can write node_modules
RUN chown -R 1001:1001 /app

USER 1001

# Install ALL dependencies (including devDeps needed for tsc)
RUN npm install

# Copy source and compile TypeScript → dist/
COPY tsconfig.json ./
COPY src/ ./src/

RUN npm run build

# ── Stage 2: Run ────────────────────────────────────────────────────────────
FROM registry.access.redhat.com/ubi9/nodejs-20-minimal:latest

USER root

WORKDIR /app

# Copy only production artifacts
COPY --from=builder /app/dist ./dist
COPY package*.json ./

# Fix permissions
RUN chown -R 1001:1001 /app

USER 1001

# Install production dependencies only
RUN npm install --omit=dev

EXPOSE 3000

CMD ["node", "dist/index.js"]