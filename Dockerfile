# Stage 1: Build React frontend FROM node:16-slim AS builder WORKDIR /app COPY package*.json ./ RUN npm ci COPY . . RUN npm run build # Stage 2: Runtime for Node.js server FROM node:16-slim WORKDIR /app # Copy only necessary files COPY package*.json ./ RUN npm ci --only=production # Copy server code + built frontend COPY --from=builder /app/build ./build COPY . . EXPOSE 3000 CMD ["npm", "start"]
FROM node:16-slim AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Runtime for Node.js server
FROM node:16-slim
WORKDIR /app

# Copy only necessary files
COPY package*.json ./
RUN npm ci --only=production

# Copy server code + built frontend
COPY --from=builder /app/build ./build
COPY . .

EXPOSE 3000
CMD ["npm", "start"]