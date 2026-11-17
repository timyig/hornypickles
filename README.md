# Horny Pickles

An Astro static website deployed to GitHub Pages. The initial site has a coming-soon homepage and a custom 404 page.

**Site:** https://timyig.github.io/hornypickles/

## Local development

Use Node.js 26.13.1 (`nvm install && nvm use` if you use nvm) and npm:

```sh
npm ci
npm run dev
```

Open http://localhost:4321/hornypickles/. Edit `src/pages/index.astro` for the homepage and `src/layouts/Layout.astro` for the shared layout and styles. Files in `public/` are copied directly to the site.

```sh
npm run check    # Astro and TypeScript diagnostics
npm run build    # Generate the static site in dist/
npm run preview  # Serve the generated site locally
```

New pages belong in `src/pages/`. Prefix links and public asset URLs with `import.meta.env.BASE_URL` so they work under the repository's `/hornypickles/` path. The trailing slash is included.

## Docker build environment

Docker with Buildx is sufficient; Node.js is not required on the host. GitHub Actions uses this same Dockerfile and runs both the type check and production build.

```sh
docker buildx build --target export --output type=local,dest=dist .
```

The default `export` target contains only the generated static files. The command writes them to `dist/`; it does not produce a runnable web-server image. GitHub Pages serves those files directly.

For a development server in Docker:

```sh
docker build --target development -t hornypickles-dev .
docker run --rm -p 127.0.0.1:4321:4321 \
  --mount type=bind,source="$(pwd)/src",target=/app/src \
  --mount type=bind,source="$(pwd)/public",target=/app/public \
  hornypickles-dev
```

Open http://localhost:4321/hornypickles/. Changes to `src/` and `public/` reload automatically. Rebuild the development image after changing dependencies or configuration.

## GitHub Pages deployment

`.github/workflows/deploy.yml` runs on pushes and pull requests targeting `main`. Both build and check the site in Docker. Only `main` deploys. You can also run the workflow manually from the Actions tab on `main`.

The repository must have Pages enabled with **Settings → Pages → Build and deployment → Source: GitHub Actions**. An administrator can also enable it with the GitHub CLI after the first commit is pushed:

```sh
gh api --method POST repos/timyig/hornypickles/pages -f build_type=workflow
```

If Pages is already enabled, use `--method PUT` instead. No personal access token or repository secret is needed by the workflow: the deployment job uses GitHub's built-in token and OIDC permissions. Actions must be allowed to run in the repository, and any configured protection rules on the `github-pages` environment must permit deployment from `main`.

Dependency, Docker base image, and GitHub Action updates are proposed weekly by Dependabot. Actions are pinned to release commits, and npm dependencies are locked in `package-lock.json`.

## Site URL or custom domain

The defaults in `astro.config.mjs` and the Dockerfile are:

- `ASTRO_SITE=https://timyig.github.io`
- `ASTRO_BASE=/hornypickles`

For a different deployment, set these environment variables for a local build or pass Docker build arguments:

```sh
docker buildx build --target export --output type=local,dest=dist \
  --build-arg ASTRO_SITE=https://example.com \
  --build-arg ASTRO_BASE=/ .
```

For GitHub Actions, add the same values as `build-args` on the Docker build step. For a custom domain, configure the domain in GitHub Pages and set its DNS records at your DNS provider. The default GitHub Pages URL needs no DNS configuration.

Deployment reference: [Astro's GitHub Pages guide](https://docs.astro.build/en/guides/deploy/github/).
