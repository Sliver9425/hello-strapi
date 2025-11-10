FROM node:20-slim AS builder

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci

COPY . .
ENV NODE_ENV=production

RUN npm run build


RUN echo "--- LISTADO DE ARCHIVOS TRAS BUILD ---" && ls -la /app && echo "----------------------------------------"


RUN npm prune --production


FROM node:20-slim
WORKDIR /app


COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules


COPY --from=builder /app .

ENV NODE_ENV production
EXPOSE 1337
CMD ["npm", "start"]