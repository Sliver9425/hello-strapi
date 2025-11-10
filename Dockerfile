#Use the official Node image as the base for building
FROM node:20-slim AS builder

#Set the working directory inside the container
WORKDIR /app


COPY package.json package-lock.json ./


RUN npm ci 

#Copy the rest of the application source code (config, API schemas, etc.)
COPY . .

RUN npm run build

#Use a clean, smaller Node image for the final production environment
FROM node:20-slim

#Set the working directory
WORKDIR /app

#The following lines copy only the necessary files from the builder stage:
#1. node_modules (production dependencies)
COPY --from=builder /app/node_modules ./node_modules

#2. package.json
COPY --from=builder /app/package.json .

#3. The built admin panel assets
COPY --from=builder /app/build ./build

#4. Copy the rest of the application source code (config, API schemas, etc.)
COPY . .

#Set environment variable for production mode
ENV NODE_ENV production

#Expose the default Strapi port. Render will map its assigned PORT to this.
EXPOSE 1337


CMD ["npm", "start"]