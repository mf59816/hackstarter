# This file was auto-generated by cabal2nix. Please do NOT edit manually!

{ cabal, aeson, conduit, csv, dataDefault, esqueleto, fastLogger
, hjsmin, hspec, httpConduit, monadControl, monadLogger, persistent
, persistentPostgresql, persistentTemplate, resourcet, shakespeare
, text, time, transformers, waiExtra, waiLogger, warp, yaml, yesod
, yesodAuth, yesodCore, yesodForm, yesodStatic, yesodTest, yesodBin
}:

cabal.mkDerivation (self: {
  pname = "hackstarter";
  version = "0.0.0";
  src=./.;
  isLibrary = true;
  isExecutable = true;
  buildTools = [ yesodBin ];
  buildDepends = [
    aeson conduit csv dataDefault esqueleto fastLogger hjsmin
    httpConduit monadControl monadLogger persistent
    persistentPostgresql persistentTemplate shakespeare text time
    transformers waiExtra waiLogger warp yaml yesod yesodAuth yesodCore
    yesodForm yesodStatic
  ];
  testDepends = [
    hspec monadLogger persistent persistentPostgresql resourcet
    transformers yesod yesodCore yesodTest
  ];
  meta = {
    license = self.stdenv.lib.licenses.unfree;
    platforms = self.ghc.meta.platforms;
  };
})
