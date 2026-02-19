const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);

// Firebase v10 uses two things Metro doesn't support by default:
//   1. package.json "exports" field for subpath resolution (firebase/auth, etc.)
//   2. .cjs file extensions for its React Native builds
config.resolver.unstable_enablePackageExports = true;
config.resolver.sourceExts = [...config.resolver.sourceExts, 'cjs'];

module.exports = config;
