{
  lib,
  stdenv,
  unzip,
  dpkg,
  glibc,
  gcc-unwrapped,
  zlib,
  libjpeg8,
  libtiff,
  jasper,
  autoPatchelfHook,
  requireFile,
  makeWrapper,
}: let
  version = "2.0.0";
in
  stdenv.mkDerivation {
    name = "insta360-sdk-${version}";
    system = "x86_64-linux";

    src = requireFile {
      name = "LinuxSDK20231211.zip";
      url = "https://www.insta360.com/sdk/home";
      sha256 = "1flinpba490nj63yl727dsy6p3r0gnhbp7jlvmpw4r3z9z7b7ibf";
    };

    # Required for compilation
    nativeBuildInputs = [
      dpkg
      glibc
      unzip

      makeWrapper
    ];

    # Required at running time
    buildInputs = [
      stdenv.cc.cc.lib
      gcc-unwrapped
      zlib
      libjpeg8
      jasper
      libtiff
    ];

    unpackPhase = ''
      runHook preUnpack
      find $src -type f | xargs -I {} unzip {}
      export package="libMediaSDK-dev_2.0-0_ubuntu18.04_amd64"
      unzip LinuxSDK20231211/$package.zip -d .
      dpkg -x $package/libMediaSDK-dev_2.0-0_amd64_ubuntu18.04.deb ./
      runHook postUnpack
    '';

    # Extract and copy executable in $out/bin
    installPhase = let
      rpath = lib.makeLibraryPath [stdenv.cc.cc.lib zlib libjpeg8 jasper libtiff];
    in ''
      runHook preInstall
      mkdir -p $out
      mv usr/* $out
      chmod 755 "$out"
      ln -s ${zlib}/lib/libz.so.1 $out/lib/libz.so.1
      patchelf --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" \
        --set-rpath "$out/lib:${rpath}" "$out/bin/MediaSDKTest"
      wrapProgram $out/bin/MediaSDKTest --prefix LD_LIBRARY_PATH : "${rpath}:$out/lib"
      mv $out/bin/MediaSDKTest $out/bin/insta360sdk
      runHook postInstall
    '';

    preFixup = ''
      patchelf --replace-needed libtiff.so.5 libtiff.so $out/lib/libMediaSDK.so \
      --replace-needed libjpeg.so.8 libjpeg.so $out/lib/libMediaSDK.so \
      --replace-needed libjasper.so.1 libjasper.so $out/lib/libMediaSDK.so
    '';

    meta = with lib; {
      description = "Instal360 SDK";
      homepage = https://www.insta360.com/sdk;
      license = licenses.unfree;
      maintainers = with stdenv.lib.maintainers; [ abraverm ];
      platforms = ["x86_64-linux"];
    };
  }
