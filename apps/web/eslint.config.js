import { readdirSync } from 'node:fs';
import js from '@eslint/js';
import globals from 'globals';
import reactHooks from 'eslint-plugin-react-hooks';
import reactRefresh from 'eslint-plugin-react-refresh';
import { createNodeResolver, importX } from 'eslint-plugin-import-x';
import tseslint from 'typescript-eslint';
import { defineConfig, globalIgnores } from 'eslint/config';
import eslintConfigPrettier from 'eslint-config-prettier';

const rulesDoc = 'docs/web-architecture.md 2절';

const features = readdirSync(new URL('./src/features', import.meta.url), { withFileTypes: true })
  .filter((entry) => entry.isDirectory())
  .map((entry) => entry.name);

const importZones = [
  {
    target: './src/shared',
    from: './src/app',
    message: `shared는 app을 import하지 않는다 (${rulesDoc})`,
  },
  {
    target: './src/shared',
    from: './src/features',
    message: `shared는 features를 import하지 않는다 (${rulesDoc})`,
  },
  {
    target: './src/features',
    from: './src/app',
    except: ['./routes.ts'],
    message: `features는 app 중 routes.ts만 import할 수 있다 (${rulesDoc})`,
  },
  ...features.map((feature) => ({
    target: `./src/features/${feature}`,
    from: './src/features',
    except: [`./${feature}`],
    message: `다른 기능을 import하지 않는다. 기능 간에는 shared로 올리거나 API 계약으로 연결한다 (${rulesDoc})`,
  })),
];

export default defineConfig([
  globalIgnores(['dist']),
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      js.configs.recommended,
      tseslint.configs.recommended,
      reactHooks.configs.flat.recommended,
      reactRefresh.configs.vite,
    ],
    languageOptions: {
      globals: globals.browser,
    },
  },
  {
    files: ['src/**/*.{ts,tsx}'],
    plugins: { 'import-x': importX },
    settings: {
      'import-x/resolver-next': [createNodeResolver({ extensions: ['.ts', '.tsx', '.js'] })],
    },
    rules: {
      'import-x/no-restricted-paths': [
        'error',
        { basePath: import.meta.dirname, zones: importZones },
      ],
    },
  },
  eslintConfigPrettier,
]);
