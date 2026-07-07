FROM node:20-alpine AS builder
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm ci

FROM node:20-alpine AS runner
WORKDIR /usr/src/app
ENV NODE_ENV=production
ENV PORT=3000

# Copy only what is needed from the builder stage
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/package*.json ./
COPY . .

# Security Feature: Switch to non-root user
USER node

EXPOSE 3000
CMD ["node", "app.js"]

