#!/usr/bin/env bats

function setup {
  mkdir -p "$BATS_TMPDIR/src"
  touch "$BATS_TMPDIR/src/old_file.md"
  mkdir -p "$BATS_TMPDIR/posts"
  mkdir -p "$BATS_TMPDIR/projects"
}

@test "publish" {
  touch "$BATS_TMPDIR/src/new_file.md"
  bin/publish -s "$BATS_TMPDIR/src" -o "$BATS_TMPDIR/posts" -r "$BATS_TMPDIR"
  [[ -f "$BATS_TMPDIR/posts/new_file.html" ]]
}

@test "publish skips files older than output directory" {
  bin/publish -s "$BATS_TMPDIR/src" -o "$BATS_TMPDIR/posts" -r "$BATS_TMPDIR"
  [[ ! -f "$BATS_TMPDIR/posts/file.html" ]]
}

@test "publish updates when file is modified" {
  touch "$BATS_TMPDIR/src/old_file.md"
  bin/publish -s "$BATS_TMPDIR/src" -o "$BATS_TMPDIR/posts" -r "$BATS_TMPDIR"

  [[ -f "$BATS_TMPDIR/posts/old_file.html" ]]
}

@test "publish generates posts index" {
  bin/publish -s "$BATS_TMPDIR/src" -o "$BATS_TMPDIR/posts" -r "$BATS_TMPDIR"

  [[ -f "$BATS_TMPDIR/posts/index.html" ]]
}

@test "publish generates projects index" {
  bin/publish -s "$BATS_TMPDIR/src" -o "$BATS_TMPDIR/posts" -r "$BATS_TMPDIR"
  [[ -f "$BATS_TMPDIR/projects/index.html" ]]
}
