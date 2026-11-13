{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "hipixel";
  version = "0.4.4";

  src = fetchurl {
    url = "https://github.com/okooo5km/HiPixel/releases/download/v${finalAttrs.version}/HiPixel-v${finalAttrs.version}.dmg";
    hash = "sha256-O67T8lU0L532bfp5XQpbvt+CsRXBE+QJxLPG6ArgFLs=";
  };

  # `undmg` only reads HFS+ images. Upstream has shipped both APFS (<= 0.4.3)
  # and HFS+ (0.4.4) payloads, so unpack with 7-Zip, which understands both.
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

    # The bundle's location inside the extraction depends on the dmg's
    # filesystem: 7-Zip puts APFS payloads (<= 0.4.3) at the root, but
    # prefixes HFS+ payloads (0.4.4+) with the volume name
    # ("HiPixel Installer/HiPixel.app"). Locate it instead of hardcoding
    # either layout; -prune keeps find from descending into the bundle.
    app=$(find . -type d -name HiPixel.app -prune -print -quit)
    if [ -z "$app" ]; then
      echo "HiPixel.app not found in dmg" >&2
      exit 1
    fi

    mkdir -p $out/Applications
    cp -r "$app" $out/Applications/HiPixel.app

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
