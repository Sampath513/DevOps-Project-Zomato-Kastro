# Stage 1: Build React frontend
FROM node:16-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Runtime for Node.js server
FROM node:16-alpine
WORKDIR /app

# Copy only necessary files
COPY package*.json ./
RUN npm ci --only=production

# Copy server code + built frontend
COPY --from=builder /app/build ./build
COPY . .

EXPOSE 3000
CMD ["node", "server/index.js"]