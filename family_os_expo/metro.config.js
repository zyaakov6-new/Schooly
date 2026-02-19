const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);

// Firebase v10 uses package.json "exports" for subpath resolution.
// Metro needs to be told to:
//   1. Read the exports map at all (unstable_enablePackageExports)
//   2. Prefer the "react-native" export condition — otherwise it picks
//      the browser/ESM build (dist/esm/index.esm.js) which doesn't exist
//      in the installed package, causing "Unable to resolve firebase/auth"
config.resolver.unstable_enablePackageExports = true;
config.resolver.unstable_conditionNames = ['react-native', 'require', 'default'];
config.resolver.sourceExts = [...config.resolver.sourceExts, 'cjs'];

module.exports = config;
