FROM node:22-alpine AS base
RUN corepack enable && corepack prepare pnpm@9.15.4 --activate
WORKDIR /app

FROM base AS builder
COPY package.json pnpm-lock.yaml* pnpm-workspace.yaml ./
COPY packages/api-types/package.json ./packages/api-types/
COPY apps/backend/package.json ./apps/backend/
RUN pnpm install --frozen-lockfile || pnpm install

COPY tsconfig.base.json ./
COPY packages/api-types ./packages/api-types
COPY apps/backend ./apps/backend

RUN pnpm --filter @arriendos/api-types build
RUN pnpm --filter @arriendos/backend prisma:generate
RUN pnpm --filter @arriendos/backend build

FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/packages/api-types/dist ./packages/api-types/dist
COPY --from=builder /app/packages/api-types/package.json ./packages/api-types/
COPY --from=builder /app/apps/backend/dist ./apps/backend/dist
COPY --from=builder /app/apps/backend/prisma ./apps/backend/prisma
COPY --from=builder /app/apps/backend/package.json ./apps/backend/

EXPOSE 3000
CMD ["node", "apps/backend/dist/main.js"]
