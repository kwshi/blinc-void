#!/bin/sh -e

DOWNLOAD_DIR="$OUTPUT_DIR/download"

log 'fetching rootfs filename and sha256...'
read filename sha256 << EOF
  $(curl -fsSL "$REPO_LIVE_URL/sha256.txt" \
    | sed -e 's/^SHA256 (\([0-9A-Za-z_.-]\+\)) = \([0-9a-f]\+\)$/\1 \2/' \
    | grep 'void-x86_64-ROOTFS-[0-9]\{8\}\.tar\.xz'
  )
EOF
log 'obtained rootfs filename: %s' "$filename"
log 'obtained rootfs sha256 (expected): %s' "$sha256"

log 'downloading rootfs...'
curl -fL --create-dirs \
  -o "$DOWNLOAD_DIR/$filename" \
  "$REPO_LIVE_URL/$filename" 

log 'checking sha256...'
sha256sum -c --status --strict << EOF
  $sha256 $DOWNLOAD_DIR/$filename
EOF
