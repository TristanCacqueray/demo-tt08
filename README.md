# a clash demo

The goal is to demonstrate how to create a verilog circuit using the Haskell clash compiler.

## Setup on archlinux

- Install toolchains
```ShellSession
$ pacman -Sy ghc-static clash-ghc
```

- Install library
```ShellSession
$ cabal update
$ cabal install --ghc-options=-dynamic --lib retroclash-lib
```

## Usage

- Start a REPL
```ShellSession
$ clashi -package clash-prelude -package ghc-typelits-knownnat -package ghc-typelits-extra -package ghc-typelits-natnormalise -package retroclash-lib SoundPlayer.hs
[1 of 1] Compiling SoundPlayer      ( SoundPlayer.hs, interpreted )
Ok, one module loaded.
clashi>
```

- REPL Commands:

 - `:reload`: reload code change
 - `:verilog`: compile to `./verilog/SoundPlayer.topEntity/topEntity.v`

- Simulate

```ShellSession
clashi> sampleN 42 $ playSound
[0,0,2,5,7,10,12,15,17,20,22,25,28,30,33,35,38,40,43,45,48,51,53,56,58,61,63,66,68,71,73,76,79,81,84,86,89,91,94,96,99,102]
```
