export PROJ_HOME := $(shell git rev-parse --show-toplevel)
export SCRIPTS_DIR := $(PROJ_HOME)/script

# ====================================================
# ETC.
# ====================================================

initMac:
	@( $(SCRIPTS_DIR)/mac/prepare.sh )
	@( $(SCRIPTS_DIR)/mac/brew.sh )
	@( $(SCRIPTS_DIR)/mac/init.sh )

prerequisites:
	@( $(SCRIPTS_DIR)/prerequisites.sh )

prerequisitesTest:
	@( $(SCRIPTS_DIR)/prerequisites_test.sh )

changeShell:
	@( $(SCRIPTS_DIR)/change_shell.sh )

# ====================================================
# TARGETS
# ====================================================

pkg-config:
	@( $(SCRIPTS_DIR)/libs/pkg_config.sh )

ncurses: \
	pkg-config
	@( $(SCRIPTS_DIR)/libs/ncurses.sh )

libevent: \
	openssl
	@( $(SCRIPTS_DIR)/libs/libevent.sh )

readline: \
	ncurses
	@( $(SCRIPTS_DIR)/libs/readline.sh )

patch:
	@( $(SCRIPTS_DIR)/apps/patch.sh )

help2man:
	@( $(SCRIPTS_DIR)/apps/help2man.sh )

# libiconv:
#   @( $(SCRIPTS_DIR)/apps/libiconv.sh )

gettext: \
	# libiconv
	@( $(SCRIPTS_DIR)/apps/gettext.sh )

sqlite3:
	@( $(SCRIPTS_DIR)/libs/sqlite3.sh )

libffi:
	@( $(SCRIPTS_DIR)/libs/libffi.sh )

# openldap
# -----------------------------------------------------
libsodium:
	@( $(SCRIPTS_DIR)/libs/libsodium.sh )

groff: \
	texinfo
	@( $(SCRIPTS_DIR)/libs/groff.sh )

openldap: \
	groff openssl libevent libsodium
	@( $(SCRIPTS_DIR)/libs/openldap.sh )
# -----------------------------------------------------

# glibc
# -----------------------------------------------------
texinfo: \
	ncurses
	@( $(SCRIPTS_DIR)/libs/texinfo.sh )

bison: \
	m4 texinfo
	@( $(SCRIPTS_DIR)/libs/bison.sh )

# glibc: \
#   bison bzip2 gettext texinfo
#   @( $(SCRIPTS_DIR)/libs/glibc.sh )
# -----------------------------------------------------

cmake: \
	openssl
	@( $(SCRIPTS_DIR)/libs/cmake.sh )

# compressions
# -----------------------------------------------------
zlib:
	@( $(SCRIPTS_DIR)/libs/zlib.sh )

bzip2:
	@( $(SCRIPTS_DIR)/apps/bzip2.sh )

unzip:
	@( $(SCRIPTS_DIR)/apps/unzip.sh )

gzip:
	@( $(SCRIPTS_DIR)/apps/gzip.sh )

xz: \
	autotools gettext
	@( $(SCRIPTS_DIR)/apps/xz.sh )
# -----------------------------------------------------

openssl: \
	zlib
	@( $(SCRIPTS_DIR)/apps/openssl.sh )

# autotools
# -----------------------------------------------------
m4:
	@( $(SCRIPTS_DIR)/apps/m4.sh )

autoconf: m4
	@( $(SCRIPTS_DIR)/apps/autoconf.sh )

automake: autoconf
	@( $(SCRIPTS_DIR)/apps/automake.sh )

libtool: automake
	@( $(SCRIPTS_DIR)/apps/libtool.sh )

autotools: \
	m4 autoconf automake libtool
# -----------------------------------------------------

# gnutls
# -----------------------------------------------------
gmp: \
	xz
	@( $(SCRIPTS_DIR)/libs/gmp.sh )

libnettle: \
	gmp
	@( $(SCRIPTS_DIR)/libs/libnettle.sh )

libtasn1:
	@( $(SCRIPTS_DIR)/libs/libtasn1.sh )

p11-kit: \
	libtasn1 libffi xz
	@( $(SCRIPTS_DIR)/apps/p11_kit.sh )

gnutls: \
	gmp libnettle p11-kit
	@( $(SCRIPTS_DIR)/apps/gnutls.sh )
# -----------------------------------------------------

# gnupg
# -----------------------------------------------------
libgpg-error: \
	bzip2
	@( $(SCRIPTS_DIR)/libs/libgpg_error.sh )

libgcrypt: \
	bzip2
	@( $(SCRIPTS_DIR)/libs/libgcrypt.sh )

libassuan: \
	bzip2
	@( $(SCRIPTS_DIR)/libs/libassuan.sh )

libksba: \
	bzip2
	@( $(SCRIPTS_DIR)/libs/libksba.sh )

npth: \
	bzip2
	@( $(SCRIPTS_DIR)/apps/npth.sh )

gnupg: \
	libgpg-error libgcrypt libassuan \
	libksba readline openldap npth bzip2 gnutls
	@( $(SCRIPTS_DIR)/apps/gnupg.sh )
# -----------------------------------------------------

# x11
# -----------------------------------------------------
xorgproto:
	@( $(SCRIPTS_DIR)/libs/X11/xorgproto.sh )

xtrans:
	@( $(SCRIPTS_DIR)/libs/X11/xtrans.sh )

libxau:
	@( $(SCRIPTS_DIR)/libs/X11/libxau.sh )

# # need python interpreter
xcb-proto:
	@( $(SCRIPTS_DIR)/libs/X11/xcb_proto.sh )

libxcb: \
	libxau xcb-proto
	@( $(SCRIPTS_DIR)/libs/X11/libxcb.sh )

# (xproto >= 7.0.25 xextproto xtrans xcb >= 1.11.1 kbproto inputproto
libx11: \
	pkg-config xorgproto xtrans libxcb
	@( $(SCRIPTS_DIR)/libs/X11/libx11.sh )
# -----------------------------------------------------

tcl:
	@( $(SCRIPTS_DIR)/libs/tcl.sh )

tk: \
	tcl libx11
	@( $(SCRIPTS_DIR)/libs/tk.sh )

nasm:
	@( $(SCRIPTS_DIR)/libs/nasm.sh )

libjpeg-turbo: \
	nasm cmake
	@( $(SCRIPTS_DIR)/libs/libjpeg_turbo.sh )

opencv: \
	cmake
	@( $(SCRIPTS_DIR)/libs/opencv.sh )

# sox
# -----------------------------------------------------
libogg:
	@( $(SCRIPTS_DIR)/libs/libogg.sh )

libsndfile: \
	libogg
	@( $(SCRIPTS_DIR)/libs/libsndfile.sh )

flac: \
	libogg xz
	@( $(SCRIPTS_DIR)/libs/flac.sh )

sox: \
	flac libogg libsndfile
	@( $(SCRIPTS_DIR)/apps/sox.sh )
# -----------------------------------------------------

# tcptump
# -----------------------------------------------------
flex: \
	autotools gettext help2man
	@( $(SCRIPTS_DIR)/libs/flex.sh )

libpcap: \
	flex bison
	@( $(SCRIPTS_DIR)/libs/libpcap.sh )

tcpdump: \
	libpcap
	@( $(SCRIPTS_DIR)/apps/tcpdump.sh )
# -----------------------------------------------------

terminfo:
	@( $(SCRIPTS_DIR)/libs/terminfo.sh )

zsh: \
	ncurses xz
	@( $(SCRIPTS_DIR)/apps/zsh.sh )

fish: \
	ncurses gettext xz cmake
	@( $(SCRIPTS_DIR)/apps/fish.sh )

prezto:
	@( $(SCRIPTS_DIR)/apps/prezto.sh )

neovim: \
	patch pkg-config cmake autotools unzip gettext
	@( $(SCRIPTS_DIR)/apps/neovim.sh )

tmux: \
	ncurses libevent terminfo
	@( $(SCRIPTS_DIR)/apps/tmux.sh )

wget: \
	pkg-config gnutls gzip
	@( $(SCRIPTS_DIR)/apps/wget.sh )

tree:
	@( $(SCRIPTS_DIR)/apps/tree.sh )

fd:
	@( $(SCRIPTS_DIR)/apps/fd.sh )

rg:
	@( $(SCRIPTS_DIR)/apps/rg.sh )

thefuck:
	@( $(SCRIPTS_DIR)/apps/thefuck.sh )

tldr:
	@( $(SCRIPTS_DIR)/apps/tldr.sh )

bash-snippets:
	@( $(SCRIPTS_DIR)/apps/bash_snippets.sh )

up:
	@( $(SCRIPTS_DIR)/apps/up.sh )

# jq
# -----------------------------------------------------
oniguruma:
	@( $(SCRIPTS_DIR)/libs/oniguruma.sh )

jq: \
	oniguruma
	@( $(SCRIPTS_DIR)/apps/jq.sh )
# -----------------------------------------------------

pyenv: \
	openssl readline zlib bzip2 sqlite3 libffi tcl tk
	@ ( $(SCRIPTS_DIR)/apps/pyenv.sh )

goenv:
	@( $(SCRIPTS_DIR)/apps/goenv.sh )

asdf:
	@ ( $(SCRIPTS_DIR)/apps/asdf.sh )

tpm: \
	tmux
	@( $(SCRIPTS_DIR)/apps/tpm.sh )

# ====================================================
# DOTS
# ====================================================

bins:
	@( $(SCRIPTS_DIR)/dots/bins.sh )

configs:
	@( $(SCRIPTS_DIR)/dots/configs.sh )

tmux-plugins:
	@( $(SCRIPTS_DIR)/dots/tmux_plugins.sh )

neovim-plugins:
	@( $(SCRIPTS_DIR)/dots/neovim_plugins.sh )

neovim-providers:
	@( $(SCRIPTS_DIR)/dots/neovim_providers.sh )

# ====================================================
# ENVIRONMENTS
# ====================================================

python: \
	patch openssl readline zlib bzip2 sqlite3 libffi tcl tk xz ncurses
	@( $(SCRIPTS_DIR)/environments/python.sh )

golang:
	@( $(SCRIPTS_DIR)/environments/golang.sh )

rust:
	@( $(SCRIPTS_DIR)/environments/rust.sh )

nodejs: \
	gnupg
	@( $(SCRIPTS_DIR)/environments/nodejs.sh )

lua: \
	unzip
	@( $(SCRIPTS_DIR)/environments/lua.sh )

perl:
	@( $(SCRIPTS_DIR)/environments/perl.sh )

python-env: \
	python-env--virtualenv python-env--black python-env--isort \
	python-env--flake8 python-env--debugpy

python-env--virtualenv:
	@( $(SCRIPTS_DIR)/environments/python_env__virtualenv.sh )

python-env--black:
	@( $(SCRIPTS_DIR)/environments/python_env__black.sh )

python-env--isort:
	@( $(SCRIPTS_DIR)/environments/python_env__isort.sh )

python-env--flake8:
	@( $(SCRIPTS_DIR)/environments/python_env__flake8.sh )

python-env--debugpy:
	@( $(SCRIPTS_DIR)/environments/python_env__debugpy.sh )

lua-env: \
	lua-env-stylua

lua-env-stylua: \
	unzip
	@( $(SCRIPTS_DIR)/environments/lua_env__stylua.sh )

sh-env: \
	sh-env--shellcheck sh-env--shfmt

sh-env--shellcheck: \
	xz
	@( $(SCRIPTS_DIR)/environments/sh_env__shellcheck.sh )

sh-env--shfmt:
	@( $(SCRIPTS_DIR)/environments/sh_env__shfmt.sh )

nodejs-env:
	@( $(SCRIPTS_DIR)/environments/nodejs_env.sh )

# ====================================================

.PHONY: initMac prerequisites prerequisitesTest changeShell \
	pkg-config ncurses libevent readline patch help2man gettext sqlite3 libffi \
	libsodium groff openldap \
	texinfo bison \
	cmake  \
	zlib bzip2 unzip gzip xz \
	openssl \
	m4 autoconf automake libtool autotools \
	gmp libnettle libtasn1 p11-kit gnutls \
	libgpg-error libgcrypt libassuan libksba npth gnupg \
	xorgproto xtrans libxau xcb-proto libxcb libx11 \
	tcl tk \
	nasm libjpeg-turbo opencv \
	libogg libsndfile flac sox \
	flex libpcap tcpdump \
	terminfo zsh fish prezto neovim tmux \
	wget tree fd rg thefuck tldr bash-snippets up oniguruma jq \
	pyenv goenv asdf tpm \
	bins configs tmux-plugins neovim-plugins neovim-providers \
	python golang rust nodejs lua perl \
	python-env lua-env sh-env nodejs-env
