# symmetry-visualizations

Animated visualizations (cellular automata, symmetry patterns from a book), written in **plain Ada**
and compiled to **WebAssembly**. Everything is in one self-contained file.

## View it

Open `dist/index.html` in any modern browser (double-click it). You don't need a server or an install.

* On start it **cycles** through all visualizations with random parameters (15 s each).
* The **menu** (top left) selects one visualization, which then runs until you change it.
* **Settings** lets you set every parameter of every visualization. Click *Apply*; values are remembered.
* **F9** downloads a feedback file (`feedback-*.json`). It contains the version, browser, the current visualization and parameters, settings, fps, errors and the recent event log.
* **Crash reports:** the last 200 events are kept in the browser's localStorage. If the previous session did not end cleanly (tab crash, hang, WebAssembly trap), a red notice offers `crash-report-*.json`. That file holds the events before the crash and the first events after the reload.

Visualizations: **Rule 30** (any elementary rule 0–255, scrolling), **Conway's Game of Life**,
**Star Mandala** (rotating star medallion; its spin speeds and directions are randomized on every run).

## Layout

```
src/sv.ads, sv.adb        shared frame buffer, parameters, random numbers, colours
src/sv-rule_30.ad?        Rule 30 / elementary cellular automaton
src/sv-life.ad?           Game of Life
src/sv-mandala.ad?        Star Mandala
src/sv-api.ad?            the functions the browser calls (sv_start, sv_tick, ...)
web/template.html         thin JavaScript: drawing, menu, settings, F9, crash log
build.sh                  compiles Ada -> WebAssembly, embeds it into dist/index.html
tools/get-toolchain.sh    downloads the Ada -> WebAssembly compiler into ./toolchain
tests/smoke.adb, .gpr     tiny native check (normal GNAT)
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
