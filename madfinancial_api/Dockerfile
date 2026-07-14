FROM node:26.1.0-trixie

WORKDIR /app

COPY package.json pnpm-lock.yaml ./

RUN npm install -g pnpm@11.13.0

RUN pnpm install --frozen-lockfile

COPY . .

RUN pnpm run build

EXPOSE 4000

CMD ["pnpm", "run", "prod"]