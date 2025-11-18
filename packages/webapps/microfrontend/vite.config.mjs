import { defineConfig } from "vite";

export default defineConfig({
  plugins: [],
  build: {
    minify: false,
    lib: {
      formats: ["es"],
      entry: {
        index: "src/index.js",
      },
    },
    sourcemap: true,
  },
});
