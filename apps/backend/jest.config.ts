import type { Config } from 'jest';

const config: Config = {
  moduleFileExtensions: ['js', 'json', 'ts'],
  rootDir: 'src',
  testRegex: '.*\\.spec\\.ts$',
  transform: {
    '^.+\\.(t|j)s$': 'ts-jest',
  },
  collectCoverageFrom: ['modules/scoring/domain/**/*.ts'],
  coverageDirectory: '../coverage',
  coverageThreshold: {
    global: {},
    './src/modules/scoring/domain/': {
      statements: 85,
      branches: 80,
      functions: 85,
      lines: 85,
    },
  },
  testEnvironment: 'node',
};

export default config;
