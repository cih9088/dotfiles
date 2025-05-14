export PROJ_HOME := $(shell git rev-parse --show-toplevel)
export SCRIPTS_DIR := $(PROJ_HOME)/script

# ====================================================
# ETC.
# ====================================================

.PHONY: initMac
initMac:
	@( $(SCRIPTS_DIR)/mac/prepare.sh )
	@( $(SCRIPTS_DIR)/mac/brew.sh )
	@( $(SCRIPTS_DIR)/mac/init.sh )

.PHONY: prerequisites
prerequisites:
	@( $(SCRIPTS_DIR)/prerequisites.sh )

.PHONY: prerequisitesTest
prerequisitesTest:
	@( $(SCRIPTS_DIR)/prerequisites_test.sh )

.PHONY: changeShell
changeShell:
	@( $(SCRIPTS_DIR)/change_shell.sh )

# ====================================================
# TARGETS
# ====================================================

.PHONY: pkg-config
pkg-config:
	@( $(SCRIPTS_DIR)/libs/pkg_config.sh )

.PHONY: ncurses
ncurses: \
	pkg-config
	@( $(SCRIPTS_DIR)/libs/ncurses.sh )

.PHONY: libevent
libevent: \
	openssl
	@( $(SCRIPTS_DIR)/libs/libevent.sh )

.PHONY: readline
readline: \
	ncurses
	@( $(SCRIPTS_DIR)/libs/readline.sh )

.PHONY: patch
patch:
	@( $(SCRIPTS_DIR)/apps/patch.sh )

.PHONY: help2man
help2man:
	@( $(SCRIPTS_DIR)/apps/help2man.sh )

.PHONY: libiconv
libiconv:
	@( $(SCRIPTS_DIR)/apps/libiconv.sh )

.PHONY: gettext
gettext: \
	# libiconv
	@( $(SCRIPTS_DIR)/apps/gettext.sh )

.PHONY: sqlite3
sqlite3: \
	tcl libtool
	@( $(SCRIPTS_DIR)/libs/sqlite3.sh )

.PHONY: libffi
libffi:
	@( $(SCRIPTS_DIR)/libs/libffi.sh )

# openldap
# -----------------------------------------------------
.PHONY: libsodium
libsodium:
	@( $(SCRIPTS_DIR)/libs/libsodium.sh )

.PHONY: groff
groff: \
	texinfo m4
	@( $(SCRIPTS_DIR)/libs/groff.sh )

.PHONY: openldap
openldap: \
	groff openssl libevent libsodium
	@( $(SCRIPTS_DIR)/libs/openldap.sh )
# -----------------------------------------------------

# glibc
# -----------------------------------------------------
.PHONY: texinfo
texinfo: \
	ncurses
	@( $(SCRIPTS_DIR)/libs/texinfo.sh )

.PHONY: bison
bison: \
	m4 texinfo
	@( $(SCRIPTS_DIR)/libs/bison.sh )

.PHONY: glibc
glibc: \
	bison bzip2 gettext texinfo
	@( $(SCRIPTS_DIR)/libs/glibc.sh )
# -----------------------------------------------------

.PHONY: cmake
cmake: \
	openssl
	@( $(SCRIPTS_DIR)/libs/cmake.sh )

# compressions
# -----------------------------------------------------
.PHONY: zlib
zlib:
	@( $(SCRIPTS_DIR)/libs/zlib.sh )

.PHONY: bzip2
bzip2:
	@( $(SCRIPTS_DIR)/apps/bzip2.sh )

.PHONY: unzip
unzip:
	@( $(SCRIPTS_DIR)/apps/unzip.sh )

.PHONY: gzip
gzip:
	@( $(SCRIPTS_DIR)/apps/gzip.sh )

.PHONY: xz
xz: \
	autotools gettext
	@( $(SCRIPTS_DIR)/apps/xz.sh )
# -----------------------------------------------------

.PHONY: openssl
openssl: \
	zlib
	@( $(SCRIPTS_DIR)/apps/openssl.sh )

# autotools
# -----------------------------------------------------
.PHONY: m4
m4:
	@( $(SCRIPTS_DIR)/apps/m4.sh )

.PHONY: autoconf
autoconf: m4
	@( $(SCRIPTS_DIR)/apps/autoconf.sh )

.PHONY: automake
automake: autoconf
	@( $(SCRIPTS_DIR)/apps/automake.sh )

.PHONY: libtool
libtool: automake
	@( $(SCRIPTS_DIR)/apps/libtool.sh )

.PHONY: autotools
autotools: \
	m4 autoconf automake libtool
# -----------------------------------------------------

# gnutls
# -----------------------------------------------------
.PHONY: gmp
gmp: \
	xz
	@( $(SCRIPTS_DIR)/libs/gmp.sh )

.PHONY: libnettle
libnettle: \
	gmp
	@( $(SCRIPTS_DIR)/libs/libnettle.sh )

.PHONY: libtasn1
libtasn1:
	@( $(SCRIPTS_DIR)/libs/libtasn1.sh )

.PHONY: p11-kit
p11-kit: \
	libtasn1 libffi xz
	@( $(SCRIPTS_DIR)/apps/p11_kit.sh )

.PHONY: gnutls
gnutls: \
	gmp libnettle p11-kit
	@( $(SCRIPTS_DIR)/apps/gnutls.sh )
# -----------------------------------------------------

# gnupg
# -----------------------------------------------------
.PHONY: libgpg-error
libgpg-error: \
	bzip2
	@( $(SCRIPTS_DIR)/libs/libgpg_error.sh )

.PHONY: libgcrypt
libgcrypt: \
	bzip2
	@( $(SCRIPTS_DIR)/libs/libgcrypt.sh )

.PHONY: libassuan
libassuan: \
	bzip2
	@( $(SCRIPTS_DIR)/libs/libassuan.sh )

.PHONY: libksba
libksba: \
	bzip2
	@( $(SCRIPTS_DIR)/libs/libksba.sh )

.PHONY: npth
npth: \
	bzip2
	@( $(SCRIPTS_DIR)/apps/npth.sh )

.PHONY: gnupg
gnupg: \
	libgpg-error libgcrypt libassuan \
	libksba readline openldap npth bzip2 gnutls
	@( $(SCRIPTS_DIR)/apps/gnupg.sh )
# -----------------------------------------------------

# x11
# -----------------------------------------------------
.PHONY: xorgproto
xorgproto:
	@( $(SCRIPTS_DIR)/libs/X11/xorgproto.sh )

.PHONY: xtrans
xtrans:
	@( $(SCRIPTS_DIR)/libs/X11/xtrans.sh )

.PHONY: libxau
libxau:
	@( $(SCRIPTS_DIR)/libs/X11/libxau.sh )

# # need python interpreter
.PHONY: xcb-proto
xcb-proto:
	@( $(SCRIPTS_DIR)/libs/X11/xcb_proto.sh )

.PHONY: libxcb
libxcb: \
	libxau xcb-proto
	@( $(SCRIPTS_DIR)/libs/X11/libxcb.sh )

# (xproto >= 7.0.25 xextproto xtrans xcb >= 1.11.1 kbproto inputproto
.PHONY: libx11
libx11: \
	pkg-config xorgproto xtrans libxcb
	@( $(SCRIPTS_DIR)/libs/X11/libx11.sh )
# -----------------------------------------------------

.PHONY: tcl
tcl:
	@( $(SCRIPTS_DIR)/libs/tcl.sh )

.PHONY: tk
tk: \
	tcl libx11
	@( $(SCRIPTS_DIR)/libs/tk.sh )

.PHONY: nasm
nasm:
	@( $(SCRIPTS_DIR)/libs/nasm.sh )

.PHONY: libjpeg-turbo
libjpeg-turbo: \
	nasm cmake
	@( $(SCRIPTS_DIR)/libs/libjpeg_turbo.sh )

.PHONY: opencv
opencv: \
	cmake
	@( $(SCRIPTS_DIR)/libs/opencv.sh )

.PHONY: openmpi
openmpi:
	@( $(SCRIPTS_DIR)/libs/openmpi.sh )

# sox
# -----------------------------------------------------
.PHONY: libogg
libogg:
	@( $(SCRIPTS_DIR)/libs/libogg.sh )

.PHONY: libsndfile
libsndfile: \
	libogg
	@( $(SCRIPTS_DIR)/libs/libsndfile.sh )

.PHONY: flac
flac: \
	libogg xz
	@( $(SCRIPTS_DIR)/libs/flac.sh )

.PHONY: sox
sox: \
	flac libogg libsndfile
	@( $(SCRIPTS_DIR)/apps/sox.sh )
# -----------------------------------------------------

.PHONY: pandoc
pandoc: \
	unzip
	@( $(SCRIPTS_DIR)/apps/pandoc.sh )

# tcptump
# -----------------------------------------------------
.PHONY: flex
flex: \
	autotools gettext help2man
	@( $(SCRIPTS_DIR)/libs/flex.sh )

.PHONY: libpcap
libpcap: \
	flex bison
	@( $(SCRIPTS_DIR)/libs/libpcap.sh )

.PHONY: tcpdump
tcpdump: \
	libpcap
	@( $(SCRIPTS_DIR)/apps/tcpdump.sh )
# -----------------------------------------------------

.PHONY: terminfo
terminfo:
	@( $(SCRIPTS_DIR)/libs/terminfo.sh )

.PHONY: zsh
zsh: \
	ncurses xz
	@( $(SCRIPTS_DIR)/apps/zsh.sh )

.PHONY: fish
fish: \
	ncurses gettext xz cmake
	@( $(SCRIPTS_DIR)/apps/fish.sh )

.PHONY: prezto
prezto:
	@( $(SCRIPTS_DIR)/apps/prezto.sh )

.PHONY: neovim
neovim: \
	patch pkg-config cmake autotools unzip gettext
	@( $(SCRIPTS_DIR)/apps/neovim.sh )

.PHONY: tmux
tmux: \
	ncurses libevent bison
	@( $(SCRIPTS_DIR)/apps/tmux.sh )

.PHONY: wget
wget: \
	pkg-config gnutls gzip
	@( $(SCRIPTS_DIR)/apps/wget.sh )

.PHONY: tree
tree:
	@( $(SCRIPTS_DIR)/apps/tree.sh )

.PHONY: fd
fd:
	@( $(SCRIPTS_DIR)/apps/fd.sh )

.PHONY: rg
rg:
	@( $(SCRIPTS_DIR)/apps/rg.sh )

.PHONY: thefuck
thefuck:
	@( $(SCRIPTS_DIR)/apps/thefuck.sh )

.PHONY: tldr
tldr:
	@( $(SCRIPTS_DIR)/apps/tldr.sh )

.PHONY: bash-snippets
bash-snippets:
	@( $(SCRIPTS_DIR)/apps/bash_snippets.sh )

.PHONY: up
up:
	@( $(SCRIPTS_DIR)/apps/up.sh )

# jq
# -----------------------------------------------------
.PHONY: oniguruma
oniguruma:
	@( $(SCRIPTS_DIR)/libs/oniguruma.sh )

.PHONY: jq
jq: \
	oniguruma
	@( $(SCRIPTS_DIR)/apps/jq.sh )
# -----------------------------------------------------

.PHONY: btop
btop: \
	bzip2
	@( $(SCRIPTS_DIR)/apps/btop.sh )

.PHONY: pyenv
pyenv:
	@ ( $(SCRIPTS_DIR)/apps/pyenv.sh )

.PHONY: goenv
goenv:
	@( $(SCRIPTS_DIR)/apps/goenv.sh )

.PHONY: asdf
asdf:
	@ ( $(SCRIPTS_DIR)/apps/asdf.sh )

.PHONY: mise
mise:
	@ ( $(SCRIPTS_DIR)/apps/mise.sh )

.PHONY: tpm
tpm: \
	tmux
	@( $(SCRIPTS_DIR)/apps/tpm.sh )

# ====================================================
# DOTS
# ====================================================

.PHONY: bins
bins:
	@( $(SCRIPTS_DIR)/dots/bins.sh )

.PHONY: configs
configs:
	@( $(SCRIPTS_DIR)/dots/configs.sh )

.PHONY: tmux-plugins
tmux-plugins:
	@( $(SCRIPTS_DIR)/dots/tmux_plugins.sh )

.PHONY: neovim-plugins
neovim-plugins:
	@( $(SCRIPTS_DIR)/dots/neovim_plugins.sh )

.PHONY: neovim-providers
neovim-providers:
	@( $(SCRIPTS_DIR)/dots/neovim_providers.sh )

# ====================================================
# ENVIRONMENTS
# ====================================================

.PHONY: python
python: \
	patch openssl readline zlib bzip2 sqlite3 libffi tcl tk xz ncurses
	@( $(SCRIPTS_DIR)/environments/python.sh )

.PHONY: golang
golang:
	@( $(SCRIPTS_DIR)/environments/golang.sh )

.PHONY: rust
rust:
	@( $(SCRIPTS_DIR)/environments/rust.sh )

.PHONY: nodejs
nodejs: \
	gnupg
	@( $(SCRIPTS_DIR)/environments/nodejs.sh )

.PHONY: lua
lua: \
	unzip
	@( $(SCRIPTS_DIR)/environments/lua.sh )

.PHONY: perl
perl:
	@( $(SCRIPTS_DIR)/environments/perl.sh )

.PHONY: python-env
python-env: \
	python-env--virtualenv python-env--black python-env--isort \
	python-env--flake8 python-env--debugpy

.PHONY: python-env--virtualenv
python-env--virtualenv:
	@( $(SCRIPTS_DIR)/environments/python_env__virtualenv.sh )

.PHONY: python-env--black
python-env--black:
	@( $(SCRIPTS_DIR)/environments/python_env__black.sh )

.PHONY: python-env--isort
python-env--isort:
	@( $(SCRIPTS_DIR)/environments/python_env__isort.sh )

.PHONY: python-env--flake8
python-env--flake8:
	@( $(SCRIPTS_DIR)/environments/python_env__flake8.sh )

.PHONY: python-env--debugpy
python-env--debugpy:
	@( $(SCRIPTS_DIR)/environments/python_env__debugpy.sh )

.PHONY: lua-env
lua-env: \
	lua-env-stylua

.PHONY: lua-env-stylua
lua-env-stylua: \
	unzip
	@( $(SCRIPTS_DIR)/environments/lua_env__stylua.sh )

.PHONY: sh-env
sh-env: \
	sh-env--shellcheck sh-env--shfmt

.PHONY: sh-env--shellcheck
sh-env--shellcheck: \
	xz
	@( $(SCRIPTS_DIR)/environments/sh_env__shellcheck.sh )

.PHONY: sh-env--shfmt
sh-env--shfmt:
	@( $(SCRIPTS_DIR)/environments/sh_env__shfmt.sh )

.PHONY: nodejs-env
nodejs-env:
	@( $(SCRIPTS_DIR)/environments/nodejs_env.sh )
