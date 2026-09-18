{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
  makeWrapper,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "cmux";
  version = "0.64.25";

  src = fetchurl {
    url = "https://github.com/manaflow-ai/cmux/releases/download/v${finalAttrs.version}/cmux-macos.dmg";
    hash = "sha256-zTAwDBAJXmIZchxl3SbKKphvjgChD5YNusn+++SHccE=";
  };

  # Upstream's dmg is APFS-formatted, which undmg (HFS+ only) can't read.
  # 7zz extracts APFS dmgs directly, no mount step needed. Same workaround
  # as nixpkgs' lmstudio package.
  nativeBuildInputs = [
    _7zz
    makeWrapper
  ];

  sourceRoot = ".";

  unpackPhase = ''
    runHook preUnpack
    7zz x -snld $src
    runHook postUnpack
  '';

  # 7zz extraction of an APFS dmg drops the resource-fork/xattr data the
  # original CodeResources seal depends on: `spctl --assess` on the extracted
  # bundle reports "a sealed resource is missing or invalid" even though the
  # main executable's own Developer ID signature (over its own bytes) is
  # untouched and still verifies fine. Re-sign ad hoc to rebuild a consistent
  # seal — confirmed via `open` on the resigned bundle that it launches with
  # no Gatekeeper prompt (Nix store paths never carry the quarantine xattr
  # that would trigger LaunchServices' Gatekeeper check in the first place).
  # `darwin.sigtool` (the hermetic in-nixpkgs codesign replacement) can't do
  # this: it has no --deep/bundle-reseal support, so this shells out to the
  # real /usr/bin/codesign, which ships with every macOS install.
  #
  # The default fixupPhase (strip/patchShebangs) would touch files after
  # signing and re-break the seal, so skip it entirely.
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications $out/bin
    cp -r cmux.app $out/Applications/cmux.app
    /usr/bin/codesign --force --deep --sign - $out/Applications/cmux.app

    # The app ships a dedicated CLI binary separate from the GUI launcher,
    # same layout as supacode.
    makeWrapper $out/Applications/cmux.app/Contents/Resources/bin/cmux \
      $out/bin/cmux

    runHook postInstall
  '';

  meta = {
    description = "Ghostty-based macOS terminal with vertical tabs for AI coding agents";
    homepage = "https://github.com/manaflow-ai/cmux";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    platforms = lib.platforms.darwin;
  };
})
