# ----------------------------------------------------------------
# STAGE 1: Builder (Install dependencies and build the admin panel)
# ----------------------------------------------------------------

# Use the official Node image as the base for building
FROM node:20-slim AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and yarn.lock (or package-lock.json if using npm)
# This step allows Docker to cache the dependency installation layer
COPY package.json yarn.lock ./

# Install project dependencies, ensuring only production dependencies are installed
# --frozen-lockfile is used for CI/CD environments to ensure reproducibility
RUN yarn install --production --frozen-lockfile

# Copy the rest of the application source code
COPY . .

# Build the Strapi admin panel. This step is mandatory for production environments.
RUN yarn build

# ----------------------------------------------------------------
# STAGE 2: Production (Final image: smaller and more secure)
# ----------------------------------------------------------------

# Use a clean, smaller Node image for the final production environment
FROM node:20-slim

# Set the working directory
WORKDIR /app

# The following lines copy only the necessary files from the builder stage:
# 1. node_modules (production dependencies)
COPY --from=builder /app/node_modules ./node_modules
# 2. package.json
COPY --from=builder /app/package.json .
# 3. The built admin panel assets
COPY --from=builder /app/build ./build
# 4. Copy the rest of the application source code (config, API schemas, etc.)
COPY . .

# Set environment variable for production mode
ENV NODE_ENV production

# Expose the default Strapi port. Heroku will map its assigned port to this.
EXPOSE 1337

# The command to run the application when the container starts
CMD ["yarn", "start"]