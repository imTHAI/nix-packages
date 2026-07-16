{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mist";
  version = "0.40";

  src = fetchurl {
    url = "https://github.com/ninxsoft/Mist/releases/download/v${finalAttrs.version}/Mist.${finalAttrs.version}.dmg";
    hash = "sha256-iJ0F4BOb8WJ7QzTDMcR/V0f5BJk/TNkZsHLYSk8phNg=";
  };

  nativeBuildInputs = [ undmg ];

  # undmg extracts Mist.app straight into the build dir — no intermediate
  # volume-name folder (unlike the APFS dmgs unpacked via 7zz elsewhere in
  # this repo), so the generic unpacker's single-root assumption still fails
  # since there's no wrapping directory to descend into.
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r Mist.app $out/Applications/Mist.app

    runHook postInstall
  '';

  meta = {
    description = "Mac utility that automatically downloads macOS Firmwares / Installers";
    homepage = "https://github.com/ninxsoft/Mist";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    platforms = lib.platforms.darwin;
  };
})
