#!/bin/bash
# exit on error
set -e

# Default config
NML_BASENAME=${INPUT_NML_BASENAME:-newgrf}
MIN_COMPATIBLE_REVISION=${INPUT_MIN_COMPATIBLE_REVISION:-1}
# get version and revision
GRF_REVISION=${INPUT_GRF_VERSION:-1}
GRF_TITLE=${INPUT_GRF_TITLE:-NewGRF}
####
CUSTOM_TAGS_FILE='custom-tags.txt'
NML_BASENAME_BASE=$(basename "$NML_BASENAME")

# create tags
echo "VERSION: $GRF_REVISION" > "$CUSTOM_TAGS_FILE"
echo "TITLE: $GRF_TITLE" >> "$CUSTOM_TAGS_FILE"
echo "MIN_COMPATIBLE_REVISION: $MIN_COMPATIBLE_REVISION" >> "$CUSTOM_TAGS_FILE"
echo "FILENAME: $NML_BASENAME_BASE" >> "$CUSTOM_TAGS_FILE"

# gcc
gcc -D REPO_REVISION="$GRF_REVISION" \
    -D MIN_COMPATIBLE_REVISION="$MIN_COMPATIBLE_REVISION" \
    -E -C -P -x c \
    -o "${NML_BASENAME}.nml" \
    "${NML_BASENAME}.pnml"

# change.pl
sed -i 's/) {/)\n{/g; s/} switch/}\nswitch/g; s/; /;\n/g' "${NML_BASENAME}.nml"
# nmlc
[ ! -d "build" ] && mkdir build
nmlc \
    --grf="build/${NML_BASENAME_BASE}.grf" \
    -c \
    --nfo="build/${NML_BASENAME_BASE}.nfo" \
    --nml="build/${NML_BASENAME_BASE}_optimized.nml" \
    --md5="build/${NML_BASENAME_BASE}.md5" \
    -M --MF="build/${NML_BASENAME_BASE}_dep.txt" \
    "${NML_BASENAME}.nml"

rm -f "$CUSTOM_TAGS_FILE"

echo "grf_path=build/${NML_BASENAME_BASE}.grf" >> "$GITHUB_OUTPUT"
echo "grf_md5=$(cat "build/${NML_BASENAME_BASE}.md5")" >> "$GITHUB_OUTPUT"

