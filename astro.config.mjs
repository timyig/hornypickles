import { defineConfig } from 'astro/config';

export default defineConfig({
  output: 'static',
  site: process.env.ASTRO_SITE || 'https://timyig.github.io',
  base: process.env.ASTRO_BASE || '/hornypickles',
  trailingSlash: 'always',
});
