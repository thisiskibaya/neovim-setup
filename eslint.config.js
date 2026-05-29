export default [
  { ignores: ['dist/', 'node_modules/'] },
  {
    rules: {
      'no-unused-vars': 'warn',
      'no-undef': 'error',
      semi: ['warn', 'never'],
      'no-console': 'warn',
    },
  },
]
