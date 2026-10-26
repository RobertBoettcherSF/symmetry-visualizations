# symmetry-visualizations

Animated visualizations (cellular automata, symmetry patterns from a book), written in **plain Ada**
and compiled to **WebAssembly**. Everything is in one self-contained file.

## View it

Open `dist/index.html` in any modern browser (double-click it). You don't need a server or an install.

* On start it **cycles** through all visualizations with random parameters (15 s each).
* The **menu** (top left) selects one visualization, which then runs until you change it.
* **Settings** shows the parameters of the visualization that is playing now. *Apply* runs it with those values (and leaves cycle mode); values are remembered.
* **Space** jumps to the next visualization. In cycle mode it gets random parameters and the 15 s timer restarts. Otherwise the menu moves on and the next one runs with your settings.
* **F9** downloads a feedback file (`feedback-*.json`). It contains the version, browser, the current visualization and parameters, settings, fps, errors and the recent event log.
* **Crash reports:** the last 200 events are kept in the browser's localStorage. If the previous session did not end cleanly (tab crash, hang, WebAssembly trap), a red notice offers `crash-report-*.json`. That file holds the events before the crash and the first events after the reload.

Visualizations: **Rule 30** (any elementary rule 0–255, scrolling), **Conway's Game of Life**,
**Star Mandala** (rotating star medallion), and **Field 1–5**, five field-line diagrams of point charges: dipole with pulsing equipotentials, four-lobed loops with orbiting charges, two dipoles with flowing dots, a rotating grid globe, and a fan of lines that grows and fades. Also **Growth Tree** (a segmented bar opens into a fan of strips and then a branching tree, folds back, and regrows differently) and **Balance** (squares on a beam that tilts with the real torque until w1·d1 = w2·d2). New: **Lorenz Attractor** (RK4, glowing head with fading dotted trail, slowly turning 3D view), **Sierpinski Triangle**, **Koch Snowflake** and **Sierpinski Hexagon** (built level by level with holes and bumps growing in, then folding back), **Evolute Spiral** (a spiral that draws out and unwinds, with counter-rotating dotted radials and chords) and **Crystal Diffraction** (breathing circles, a turning node network and pulses on loops through the centre). Spin and flow speeds and charge strengths are randomized on every run.

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
