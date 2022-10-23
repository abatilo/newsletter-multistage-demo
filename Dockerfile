ARG TAG=18.10.0-alpine

# Install production dependencies only
FROM node:${TAG} as dependencies
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --production=true --frozen-lockfile

# Install dev dependencies like the
# typescript compiler so that we can build the app
FROM node:${TAG} as builder
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile
COPY . .
RUN yarn build

# Our final image that will be used in production
FROM node:${TAG}
COPY --from=dependencies /app /app
COPY --from=builder /app/.next /app/.next
COPY --from=builder /app/public /app/public
WORKDIR /app
CMD ["yarn", "run", "start"]
