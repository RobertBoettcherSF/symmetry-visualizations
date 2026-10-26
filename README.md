# symmetry-visualizations

16 animated visualizations (cellular automata, field lines, fractals, a strange attractor and
symmetry patterns from a book) written in **plain Ada** and compiled to **WebAssembly**.
The purpose: **help Ada students program beautiful things.**

![All 16 visualizations](screenshots/hero.png)

Everything fits in one self-contained file, `dist/index.html`: **under 50 KB for 16 visualizations,
about 3 KB each** (about 26 KB of WebAssembly plus a thin JavaScript layer).

## View it

Open `dist/index.html` in any modern browser (download it and double-click). No server, no install.
Or view it online: https://robertboettchersf.github.io/symmetry-visualizations/dist/

## Controls

* On start it **cycles** through all visualizations with random parameters (15 s each).
* The **menu** (top left) picks one visualization, which then runs until you change it.
* **Settings** shows the parameters of the visualization that is playing. *Apply* runs it with those values; they are remembered.
* **Space** jumps to the next visualization.
* **F9** downloads a feedback file (`feedback-*.json`): version, browser, current visualization and parameters, settings, fps, errors and the recent event log.
* **Crash report:** the last 200 events are kept in localStorage. If the previous session did not end cleanly (tab crash, hang, WebAssembly trap), a red notice offers `crash-report-*.json` with the events before the crash and after the reload.

## The visualizations

Motion speeds and other details are randomized on every run.

| | | |
|---|---|---|
| <img src="screenshots/rule30.png" width="260"><br>**Rule 30**<br>any elementary cellular automaton rule 0–255, scrolling | <img src="screenshots/game-of-life.png" width="260"><br>**Game of Life**<br>Conway's cellular automaton | <img src="screenshots/star-mandala.png" width="260"><br>**Star Mandala**<br>rotating star medallion with counter-spinning rosettes |
| <img src="screenshots/field-1.png" width="260"><br>**Field 1**<br>dipole with pulsing equipotentials | <img src="screenshots/field-2.png" width="260"><br>**Field 2**<br>four-lobed loops with orbiting charges | <img src="screenshots/field-3.png" width="260"><br>**Field 3**<br>two dipoles with flowing dots |
| <img src="screenshots/field-4.png" width="260"><br>**Field 4**<br>rotating grid globe | <img src="screenshots/field-5.png" width="260"><br>**Field 5**<br>a fan of field lines that grows and fades | <img src="screenshots/tree.png" width="260"><br>**Growth Tree**<br>a bar opens into a fan and a branching tree, folds back, regrows |
| <img src="screenshots/balance.png" width="260"><br>**Balance**<br>two squares on a beam that tilts with the real torque | <img src="screenshots/lorenz.png" width="260"><br>**Lorenz Attractor**<br>RK4 solution with a glowing head and fading trail, turning 3D view | <img src="screenshots/sierpinski-triangle.png" width="260"><br>**Sierpinski Triangle**<br>holes grow in level by level |
| <img src="screenshots/koch.png" width="260"><br>**Koch Snowflake**<br>filled, bumps grow in level by level | <img src="screenshots/sierpinski-hexagon.png" width="260"><br>**Sierpinski Hexagon**<br>hexagon to ring of six, and so on | <img src="screenshots/evolute.png" width="260"><br>**Evolute Spiral**<br>spiral draws and unwinds, dotted radials and chords counter-rotate |
| <img src="screenshots/crystal.png" width="260"><br>**Crystal Diffraction**<br>breathing circles, turning node network, pulses through the centre |

## Learn from it

The project is meant to help Ada students program beautiful things. Each package is a small,
self-contained example with a header comment saying what the maths is. A good reading order:

1. `sv.ads/adb` - a frame of pixels, parameters, a tiny random generator, colours
2. `sv-rule_30` - one row of bits, a lookup in the rule number
3. `sv-life` - a 2D grid and neighbour counting
4. `sv-geometry` - vectors, sin/cos and 1/sqrt from series, lines, circles, polygon fill
5. `sv-evolute` - a spiral in polar coordinates, r as a function of the angle
6. `sv-lorenz` - a differential equation solved with Runge-Kutta, a ring buffer, 3D to 2D
7. `sv-fractals` - recursion: point-in-fractal tests and a recursive polygon (Koch)
8. `sv-tree` - a recursive tree whose opening angle is animated
9. `sv-mandala`, `sv-crystal` - building pictures from symmetry (rotations of one piece)
10. `sv-balance` - physics: torque, easing, a follower chasing equilibrium
11. `sv-fields` - electric field lines and equipotentials traced through a potential

## Rebuild (Linux Mint 21.3 / Ubuntu 22.04)

Only needed if you change the Ada code. You also need [Alire](https://alire.ada.dev) (`alr`).

```sh
sudo apt install rpm2cpio cpio lld libedit2   # once
./tools/get-toolchain.sh                      # once: AdaWebPack 24 (GNAT-LLVM) + LLVM 16 libs, ~150 MB in ./toolchain
./build.sh                                    # -> dist/index.html
```

`get-toolchain.sh` fetches the AdaWebPack 24.0.0 compiler (Fedora 40 RPM) and the LLVM 16 libraries it needs,
and uses Alire to fetch the GNAT 14 runtime the compiler requires. Nothing is installed system-wide.

Native check with your normal GNAT (zero warnings with `-gnatwa -gnatwe`):

```sh
gprbuild -P tests/smoke.gpr && ./obj/native/smoke && ./obj/native/balance_stress
```

Browser check (Node with `playwright-core` and Chrome): `node tests/browser/browser-check.js`

## Layout

```
src/sv.ads, sv.adb        shared frame buffer, parameters, random numbers, colours
src/sv-rule_30.ad?        Rule 30 / elementary cellular automaton
src/sv-life.ad?           Game of Life
src/sv-mandala.ad?        Star Mandala
src/sv-fields.ad?         Field 1-5: shared field-line tracer and equipotentials
src/sv-tree.ad?           Growth Tree (one recursive tree, only the opening angle changes)
src/sv-balance.ad?        Balance (torque, easing)
src/sv-lorenz.ad?         Lorenz Attractor (RK4)
src/sv-fractals.ad?       Sierpinski Triangle, Koch Snowflake, Sierpinski Hexagon
src/sv-evolute.ad?        Evolute Spiral
src/sv-crystal.ad?        Crystal Diffraction
src/sv-geometry.ad?       vectors, sin/cos, 1/sqrt, easing, filled strips in plain Ada (no maths library)
src/sv-api.ad?            the functions the browser calls (sv_start, sv_tick, ...)
web/template.html         thin JavaScript: drawing, menu, settings, F9, crash log
build.sh                  compiles Ada -> WebAssembly, embeds it into dist/index.html
tools/get-toolchain.sh    downloads the Ada -> WebAssembly compiler into ./toolchain
tests/smoke.adb, .gpr     tiny native check (normal GNAT); balance_stress.adb checks Balance never stalls
tests/browser/            headless browser checks (browser-check.js runs all 16 and takes the screenshots)
dist/index.html           the result
```

Each visualization is an Ada package with `Start` and `Tick`. It reads `Params` and writes pixels into `Frame`.
To add one, write `src/sv-<name>.ads/.adb`, add a `case` branch in `src/sv-api.adb`, and add one line
(name, parameter names, min/max/default) to the `VIZ` table in `web/template.html`.

## Rebuild (Linux Mint 21.3 / Ubuntu 22.04)

You need this only if you change the Ada code. You also need [Alire](https://alire.ada.dev) (`alr`).

```sh
sudo apt install rpm2cpio cpio lld libedit2   # once
./tools/get-toolchain.sh                      # once: AdaWebPack 24 (GNAT-LLVM) + LLVM 16 libs, ~150 MB in ./toolchain
./build.sh                                    # -> dist/index.html
```

`get-toolchain.sh` fetches the AdaWebPack 24.0.0 compiler package (Fedora 40 RPM) and the LLVM 16 libraries it needs.
It also uses Alire to fetch the GNAT 14 runtime library that the compiler itself requires.
Nothing is installed system-wide.

Native check with your normal GNAT (zero warnings with `-gnatwa -gnatwe`):

```sh
gprbuild -P tests/smoke.gpr && ./obj/native/smoke
```

## License

MIT, see `LICENSE`.

AI assistance was used for this project.
