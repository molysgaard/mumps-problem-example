{
  stdenv,
  gnumake,
  gfortran9,
  lapack,
  blas,
  fetchurl,
  pkg-config,
}:
stdenv.mkDerivation rec {
    pname = "mumps";
    version = "5.6.0";
  
    src = fetchurl {
      url = "https://zenodo.org/record/7888117/files/MUMPS_5.6.0.tar.gz?download=1";
      sha256 = "sha256-PgjBvep6qrowPTzwMFnztDNvpJvvk/QmD0ePBn9Rgok=";
    };

    pkgConfigDir = builtins.path { name = "pkgconfig"; path = ./pkgconfig; };

    nativeBuildInputs = [
      pkg-config
      gfortran9
      lapack
      blas
    ];
  
    buildInputs = [
      gnumake
    ];
  
    configurePhase = ''
      # use generic config
      cp Make.inc/Makefile.inc.generic.SEQ ./Makefile.inc
  
      # rewrite to use gfortran
      sed -i 's/f90/gfortran/g' ./Makefile.inc
    '';
  
    buildPhase = ''
      make -j $NIX_BUILD_CORES all
    '';
  
    installPhase = ''
      mkdir -p $out/include
      mv include/* $out/include
  
      mkdir -p $out/lib
      mv lib/* $out/lib

      cd $out/lib

      ln -s libmumps_common.a libmumps_common_seq.a
      ln -s libsmumps.a libsmumps_seq.a
      ln -s libdmumps.a libdmumps_seq.a
      ln -s libcmumps.a libcmumps_seq.a
      ln -s libzmumps.a libzmumps_seq.a

      cp -r $pkgConfigDir $out/lib/pkgconfig
    '';
}
