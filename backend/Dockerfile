# YAW backend — multi-stage build. Build context = repo root
# (butuh backend/ + database/migrations/ untuk initDb).
#   docker build -f backend/Dockerfile .

FROM node:22-alpine AS build
WORKDIR /app
COPY backend/package.json backend/package-lock.json ./
RUN npm ci --no-audit --no-fund
COPY backend/tsconfig.json ./
COPY backend/src ./src
RUN npm run build

FROM node:22-alpine AS runner
ENV NODE_ENV=production
WORKDIR /app
RUN addgroup -S app && adduser -S app -G app \
  && mkdir -p /app/uploads && chown app:app /app/uploads
COPY backend/package.json backend/package-lock.json ./
RUN npm ci --omit=dev --no-audit --no-fund && npm cache clean --force
COPY --from=build /app/dist ./dist
# Skema migrasi — dibaca initDb via process.cwd()/database/migrations
COPY database ./database
USER app
EXPOSE 3002
CMD ["node", "dist/app.js"]
