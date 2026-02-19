const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);

config.resolver.unstable_enablePackageExports = true;
config.resolver.unstable_conditionNames = ['react-native', 'require', 'default'];
config.resolver.sourceExts = [...config.resolver.sourceExts, 'cjs'];

// The top-level `firebase` package exports map points to dist/esm/*.esm.js
// files that don't exist in the npm install, so Metro can never resolve
// firebase/auth, firebase/firestore, etc. regardless of condition names.
//
// The actual implementations live in the @firebase/* scoped packages
// (e.g. @firebase/auth) which ship proper React Native builds and whose
// exports maps are correct. firebase/* is just a thin re-export wrapper,
// so mapping through resolveRequest is transparent to application code.
config.resolver.resolveRequest = (context, moduleName, platform) => {
  if (/^firebase\/(?!compat\/)/.test(moduleName)) {
    const mapped = '@firebase/' + moduleName.slice('firebase/'.length);
    return context.resolveRequest(context, mapped, platform);
  }
  return context.resolveRequest(context, moduleName, platform);
};

module.exports = config;
