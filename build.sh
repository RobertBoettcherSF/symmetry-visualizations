#!/bin/sh
# Compiles src/*.adb to WebAssembly and embeds it into dist/index.html.
set -e
cd "$(dirname "$0")"
T=$PWD/toolchain/usr
[ -x "$T/bin/llvm-gcc" ] || { echo "Run tools/get-toolchain.sh first"; exit 1; }
export LD_LIBRARY_PATH="$PWD/toolchain/lib"
LD=$(command -v wasm-ld || ls /usr/bin/wasm-ld-* | tail -1)
mkdir -p obj/wasm dist
cd obj/wasm
for F in ../../src/*.adb; do
  "$T/bin/llvm-gcc" -c --target=wasm32 -O2 -gnat2012 -gnatp -gnatwa -gnatwe \
    --RTS="$T/lib/rts-native" -I../../src "$F"
done
# memcpy/memmove/memset come from the Ada runtime library
ar x "$T/lib/rts-native/adalib/libgnat.a" s-memcop.o s-memmov.o s-memset.o
"$LD" --no-entry --strip-all --export=sv_frame --export=sv_width --export=sv_height \
  --export=sv_set_param --export=sv_start --export=sv_tick --initial-memory=16777216 \
  -o sv.wasm *.o
cd ../..
awk -v B="$(base64 -w0 obj/wasm/sv.wasm)" '{ sub(/__WASM_BASE64__/, B) } 1' \
  web/template.html > dist/index.html
echo "Built dist/index.html ($(wc -c < obj/wasm/sv.wasm) bytes of WebAssembly)"
