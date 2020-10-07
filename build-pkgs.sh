#!/usr/bin/env sh

set -o errexit -o nounset

WORKDIR=$HOME/build
DEST=/tmp/pkgs

die() { echo "[-] $1"; exit 1; }

cleanup() {
  [ -d "$WORKDIR" ] && rm -rf "$WORKDIR"
  [ -d "$DEST" ] && rm -rf "$DEST"

  [ -d "$WORKDIR" ] || mkdir -p "$WORKDIR"
  [ -d "$DEST" ] || mkdir -p "$DEST"
}

check_permission() {
  myid=$(id -u)
  [ "$myid" -ne 0 ] || die "Permission too high, use a normal user"
}

aur() {
  echo "Building $1"
  (cd "$WORKDIR" \
    && wget -cv https://aur.archlinux.org/cgit/aur.git/snapshot/$1.tar.gz \
    && tar xvf $1.tar.gz \
    && cd $1 \
    && makepkg --noconfirm -sC \
    && cp "$1"-*-x86_64.pkg.tar.zst "$DEST"/
  )
  rm -rf "$WORKDIR/$1"
}

check_permission() {
  myid=$(id -u)
  [ "$myid" -ne 0 ] || die "Permission too high, use a normal user"
}

aur() {
  echo "Building $1"
  (cd "$WORKDIR" \
    && wget -cv https://aur.archlinux.org/cgit/aur.git/snapshot/$1.tar.gz \
    && tar xvf $1.tar.gz \
    && cd $1 \
    && makepkg --noconfirm -sC \
    && cp "$1"-*.pkg.tar.zst "$DEST"/
  )
  rm -rf "$WORKDIR/$1"
  echo "Done with $1"
}

create_repo() {
  echo "Creating repo pkgs $DEST"
  cd "$DEST"
  pkgs=$(ls *.pkg.tar.zst)
  for i in $pkgs ; do
    repo-add pkgs.db.tar.gz "$i"
  done
}

main() {
  cleanup
  check_permission
  aur yay
  aur xst
  aur nerd-fonts-iosevka
  aur ttf-material-design-icons
  create_repo
}

main "$@"