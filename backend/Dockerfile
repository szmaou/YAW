# YAW backend — production image (multi-stage, no .env dibake; env via compose)
# Build context = repo root (lihat docker-compose.prod.yml) agar folder
# database/migrations ikut terbake — initDb membutuhkannya saat start.
FROM node:22-alpine AS builder
WORKDIR /app
COPY backend/package.json backend/package-lock.json ./
RUN npm ci
COPY backend/tsconfig.json ./
COPY backend/src ./src
RUN npm run build

FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production \
    UPLOAD_PATH=/app/uploads
COPY backend/package.json backend/package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force
COPY --from=builder /app/dist ./dist
COPY database ./database
RUN mkdir -p /app/uploads
VOLUME /app/uploads
EXPOSE 3002
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD node -e "fetch('http://localhost:3002/api/health').then(r=>{if(!r.ok)process.exit(1)}).catch(()=>process.exit(1))"
CMD ["node", "dist/app.js"]
