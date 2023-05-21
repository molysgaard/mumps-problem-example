# Showing off minimal reproducible linker error with naersk, gfortran and nix

To reproduce:

```
nix develop
cargo build
```

observe linker error saying `gfortran` is not linked, even though `-lgfortran` is passed to the linker and:

```
env | grep gfortran 
```

shows that `NIX_LDFLAGS` contains a directory with the correct gfortran library.
```
