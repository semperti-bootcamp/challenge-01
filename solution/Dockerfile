# Etapa Builder
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install --production=false
COPY . .
RUN npm run build

# Etapa Producción
FROM node:18-alpine AS production
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app

COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/api ./api
# COPY --from=builder /app/dist ./dist
USER appuser

EXPOSE 3000

CMD ["npm", "start"]