{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "hipixel";
  version = "0.4.3";

  src = fetchurl {
    url = "https://github.com/okooo5km/HiPixel/releases/download/v${finalAttrs.version}/HiPixel-v${finalAttrs.version}.dmg";
    hash = "sha256-+PIbwLUNZGoW7zrE3VzXRU9zQXDewP7pKxElwFziSo0=";
  };

  # `undmg` only reads HFS+ images; this dmg's payload volume is APFS, so
  # unpack with 7-Zip instead, which understands both.
  nativeBuildInputs = [ _7zz ];

  unpackPhase = ''
    runHook preUnpack

    7zz x $src -oextracted -y
    # 7-Zip materializes HFS/APFS extended-attribute streams as sibling
    # files named "<file>:com.apple.provenance"; drop them so they don't
    # end up inside the installed bundle.
    find extracted -name '*:com.apple.provenance' -delete

    runHook postUnpack
  '';

  sourceRoot = "extracted";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r HiPixel.app $out/Applications/HiPixel.app

    runHook postInstall
  '';

  meta = {
    description = "Native macOS app for AI-powered image super-resolution, built on Upscayl's models";
    homepage = "https://hipixel.5km.tech";
    license = lib.licenses.agpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    platforms = lib.platforms.darwin;
  };
})
