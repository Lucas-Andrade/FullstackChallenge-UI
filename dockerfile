FROM node:lts-alpine3.20 AS builder

ARG VITE_API_URL

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

RUN echo "VITE_API_URL=${VITE_API_URL}" > .env

RUN npm run build

FROM node:lts-alpine3.20

WORKDIR /app

ENV NODE_ENV=production

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN npm install --only=production

# Copy built application from builder stage
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/.env ./.env
COPY --from=builder /app/next.config.ts ./next.config.ts
COPY --from=builder /app/tsconfig.json ./tsconfig.json

EXPOSE 3000

CMD ["npm", "start"]
