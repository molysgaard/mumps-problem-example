{
  nixConfig.bash-prompt-prefix = "\[minimal-mumps-error\]$ ";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    naersk.url = "github:nix-community/naersk";

    nixpkgs-mozilla = {
      url = "github:mozilla/nixpkgs-mozilla";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-mozilla,
    naersk,
    ...
  }: let
    pkgs = import nixpkgs {
      system = "x86_64-linux";

      overlays = [
        (import nixpkgs-mozilla)
      ];
    };

    toolchain = (pkgs.rustChannelOf {
      rustToolchain = ./rust-toolchain.toml;
      sha256 = "sha256-Zk2rxv6vwKFkTTidgjPm6gDsseVmmljVt201H7zuDkk=";
    }).rust;


    naersk' = pkgs.callPackage naersk {
      cargo = toolchain;
      rustc = toolchain;
    };

    nativeDeps = with pkgs; [ self.packages.x86_64-linux.mumps suitesparse openblas lapack gfortran9 gfortran9.cc ];


  in {
    packages.x86_64-linux.mumps = pkgs.callPackage ./nix/mumps/mumps.nix {};
    packages.x86_64-linux.default = naersk'.buildPackage {
      src = ./.;
      gitSubmodules = true;
      buildInputs = nativeDeps;
    };

    devShells.x86_64-linux.default = pkgs.mkShell {
      nativeBuildInputs = nativeDeps;
    };
  };
}
