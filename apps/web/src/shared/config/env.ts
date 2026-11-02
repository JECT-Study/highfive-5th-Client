export type Flavor = 'dev' | 'prod';

function parseEnv(values: ImportMetaEnv) {
  const flavor = values.VITE_FLAVOR;
  const apiBaseUrl = values.VITE_API_BASE_URL;

  if (flavor !== 'dev' && flavor !== 'prod') {
    throw new Error('VITE_FLAVOR must be dev or prod');
  }
  if (!apiBaseUrl?.trim()) {
    throw new Error('VITE_API_BASE_URL must not be empty');
  }

  return { flavor, apiBaseUrl, isDev: flavor === 'dev' } as const;
}

export const env: { flavor: Flavor; apiBaseUrl: string; isDev: boolean } = parseEnv(
  import.meta.env,
);
