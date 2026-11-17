# syntax=docker/dockerfile:1
FROM node:26.13.1-bookworm-slim AS dependencies
WORKDIR /app
ENV ASTRO_TELEMETRY_DISABLED=1
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm npm ci --no-audit --no-fund

# Optional development server: docker build --target development ...
FROM dependencies AS development
COPY . .
EXPOSE 4321
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]

# This is the same checked build used by GitHub Actions.
FROM development AS build
ARG ASTRO_SITE=https://timyig.github.io
ARG ASTRO_BASE=/hornypickles
ENV ASTRO_SITE=${ASTRO_SITE} ASTRO_BASE=${ASTRO_BASE}
RUN npm run check && npm run build

# Export only static assets. GitHub Pages needs no container at runtime.
FROM scratch AS export
COPY --from=build /app/dist/ /
