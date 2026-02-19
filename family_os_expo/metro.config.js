const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);

// Required for Firebase v10 modular imports (firebase/auth, firebase/firestore, etc.)
// Firebase uses package.json "exports" field for subpath resolution which Metro
// does not follow by default.
config.resolver.unstable_enablePackageExports = true;

module.exports = config;
