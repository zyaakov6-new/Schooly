const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);

// Firebase v10 ships some .cjs files that Metro doesn't recognise by default.
// Adding the extension lets Metro resolve them without needing
// unstable_enablePackageExports (which breaks firebase's ESM exports maps).
config.resolver.sourceExts = [...config.resolver.sourceExts, 'cjs'];

module.exports = config;
