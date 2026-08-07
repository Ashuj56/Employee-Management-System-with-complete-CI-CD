# ── Stage 1: Build React app ───────────────────────────────────────────────────
FROM node:20-alpine AS builder
# RUN addgroup -S appgroup && adduser -S appuser -G appgroup
# USER appuser
WORKDIR /app
COPY --chown=appuser:appgroup package.json package-lock.json ./
RUN npm ci --prefer-offline --ignore-scripts
COPY --chown=appuser:appgroup . .
RUN npm run build

# ── Stage 2: Serve with Nginx (alpine) ────────────────────────────────────────

FROM nginx:1.27-alpine AS runtime
RUN rm -rf /usr/share/nginx/html/*
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
