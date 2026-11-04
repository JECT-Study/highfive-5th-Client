/// <reference types="vitest/config" />

import react from '@vitejs/plugin-react';
import { defineConfig, loadEnv } from 'vite';

const flavors = ['dev', 'prod'];

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), 'VITE_');
  if (!flavors.includes(env.VITE_FLAVOR)) {
    throw new Error(`VITE_FLAVOR must be one of ${flavors.join(', ')} (mode: ${mode})`);
  }
  if (!env.VITE_API_BASE_URL?.trim()) {
    throw new Error('VITE_API_BASE_URL must not be empty');
  }
  return {
    plugins: [react()],
    test: { environment: 'jsdom' },
  };
});
