{
  lib,
  stdenvNoCC,
  fetchzip,
  makeWrapper,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "supacode";
  version = "0.10.5";

  src = fetchzip {
    url = "https://github.com/supabitapp/supacode/releases/download/v${finalAttrs.version}/supacode.app.zip";
    # The zip has two top-level entries (__MACOSX/ and supacode.app/), so
    # fetchzip's default single-root requirement fails without this flag.
    stripRoot = false;
    hash = "sha256-ub2tik7hcjL5w9ySx7x24KxizReulTJzxivENpQ428U=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications $out/bin
    cp -r supacode.app $out/Applications/Supacode.app

    # The app ships a dedicated CLI binary separate from the GUI launcher.
    # Wrap it so the shell can locate it while keeping the working directory
    # context intact (the binary resolves resources relative to its own path
    # inside the bundle, so a bare symlink would break resource lookup).
    makeWrapper $out/Applications/Supacode.app/Contents/Resources/bin/supacode \
      $out/bin/supacode

    runHook postInstall
  '';

  meta = {
    description = "Worktree coding agents command center";
    homepage = "https://github.com/supabitapp/supacode";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    platforms = lib.platforms.darwin;
  };
})
