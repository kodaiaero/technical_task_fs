FROM node:24-alpine

RUN corepack enable

WORKDIR /app

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

COPY . .

# 3010 is the BFF, 5183 the Vite dev server.
EXPOSE 3010 5183

CMD ["pnpm", "dev"]
