import adapter from '@sveltejs/adapter-auto';
import svPreprocess from 'svelte-preprocess';

/** @type {import('@sveltejs/kit').Config} */
const config = {
  // Consult https://github.com/sveltejs/svelte-preprocess
  // for more information about preprocessors
  preprocess: svPreprocess({ postcss: true }),

  kit: {
    adapter: adapter(),
  },
};

export default config;