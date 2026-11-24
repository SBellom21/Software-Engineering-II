module.exports = {
  root: true,
  parser: '@typescript-eslint/parser',
  plugins: ['@typescript-eslint', 'boundaries'],
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'prettier',
  ],
  settings: {
    'boundaries/elements': [
      { type: 'scoring-domain', pattern: 'apps/backend/src/modules/scoring/domain/**' },
      { type: 'backend-module', pattern: 'apps/backend/src/modules/*' },
      { type: 'backend-common', pattern: 'apps/backend/src/common/**' },
      { type: 'api-types', pattern: 'packages/api-types/**' },
    ],
  },
  rules: {
    '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    '@typescript-eslint/no-explicit-any': 'warn',
    'boundaries/element-types': [
      'error',
      {
        default: 'allow',
        rules: [
          {
            from: ['scoring-domain'],
            disallow: ['backend-module', 'backend-common'],
            message: 'El dominio puro de scoring no debe acoplarse a otros módulos ni infraestructura (RNF-06).',
          },
        ],
      },
    ],
  },
  ignorePatterns: ['dist/', 'coverage/', 'node_modules/', '.expo/', '*.js', '*.cjs'],
};
