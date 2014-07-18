#!/bin/bash
set -e
[ -z $EM_DIR] && EM_DIR=~/src/emscripten

do_config() {
    build/gyp_pdfium
}

do_make() {
$EM_DIR/emmake make BUILDTYPE=Release -j8
}

do_link() {
mkdir web || true
cp out/Release/pdfium_test pdfium_test.bc

$EM_DIR/emcc \
    -O3 \
    --js-library web/pdfium_lib.js \
    -s ALLOW_MEMORY_GROWTH=1 \
    -s EXPORTED_FUNCTIONS="['_PDFiumJS_init', '_load', '_render_page', '_get_page_count', '_set_scale', '_get_content_buffer']" \
    -o web/pdfium_test1.js \
    pdfium_test.bc \

}

do_link2() {
mkdir web || true
$EM_DIR/em++ \
    -Oz \
    --llvm-lto 1 \
    --js-library web/pdfium_lib.js \
    -s EXPORTED_FUNCTIONS="['_init', '_load', '_render_page', '_get_page_count', '_set_scale', '_get_content_buffer']" \
    -o web/pdfium.js \
    -Wl,--start-group out/Release/obj.target/pdfium_test/samples/pdfium_test.o out/Release/obj.target/libpdfium.a out/Release/obj.target/libfdrm.a out/Release/obj.target/libfpdfdoc.a out/Release/obj.target/libfpdfapi.a out/Release/obj.target/libfpdftext.a out/Release/obj.target/libformfiller.a out/Release/obj.target/libfxcodec.a out/Release/obj.target/libfxcrt.a out/Release/obj.target/libfxedit.a out/Release/obj.target/libfxge.a out/Release/obj.target/libpdfwindow.a -Wl,--end-group

}

do_config
do_make
#do_link
#do_link2

