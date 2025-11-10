
FROM node:20-slim AS builder

WORKDIR /app

COPY package.json package-lock.json ./


RUN npm ci

COPY . .

ENV NODE_ENV=production


RUN npm run build


RUN npm prune --production

FROM node:20-slim

WORKDIR /app


COPY --from=builder /app .

ENV NODE_ENV production


RUN mkdir -p public/uploads

EXPOSE 1337

CMD ["npm", "start"]