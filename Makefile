# export PATH := ${HOME}/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:${PATH}
# export LD_LIBRARY_PATH := ${HOME}/.local/lib:${LD_LIBRARY_PATH}
# export PKG_CONFIG_PATH := ${HOME}/.local/lib/pkgconfig:${PKG_CONFIG_PATH}
#
# export CFLAGS := -I${HOME}/.local/include
# export CPPFLAGS := -I${HOME}/.local/include
# export LDFLAGS := -L${HOME}/.local/lib
#
# export BIN_DIR := $(PROJ_HOME)/bin
export PROJ_HOME := $(shell git rev-parse --show-toplevel)
export SCRIPTS_DIR := $(PROJ_HOME)/script

# ifeq (installNeovim,$(firstword $(MAKECMDGOALS)))
#   nvim_version := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
#   $(eval $(nvim_version):;@:)
# endif

initMac:
	@( $(SCRIPTS_DIR)/mac/prepare.sh )
	@( $(SCRIPTS_DIR)/mac/brew.sh )
	@( $(SCRIPTS_DIR)/mac/init.sh )

prerequisites:
	@( $(SCRIPTS_DIR)/prerequisites.sh )

prerequisitesTest:
	@( $(SCRIPTS_DIR)/prerequisites_test.sh )

# ====================================================
# LIBRARIES
# ====================================================

libraryHelp2man:
	@( $(SCRIPTS_DIR)/library/help2man.sh )

libraryPkgConfig:
	@( $(SCRIPTS_DIR)/library/pkg_config.sh )

libraryZlib:
	@( $(SCRIPTS_DIR)/library/zlib.sh )

libraryBzip2:
	@( $(SCRIPTS_DIR)/library/bzip2.sh )

libraryOpenssl: libraryZlib
	@( $(SCRIPTS_DIR)/library/openssl.sh )

libraryNcurses:
	@( $(SCRIPTS_DIR)/library/ncurses.sh )

libraryLibevent:
	@( $(SCRIPTS_DIR)/library/libevent.sh )

libraryReadline: libraryNcurses
	@( $(SCRIPTS_DIR)/library/readline.sh )

# autotools
# -----------------------------------------------------
libraryM4:
	@( $(SCRIPTS_DIR)/library/m4.sh )

libraryAutoconf: libraryM4
	@( $(SCRIPTS_DIR)/library/autoconf.sh )

libraryAutomake: libraryAutoconf
	@( $(SCRIPTS_DIR)/library/automake.sh )

libraryLibtool: libraryAutomake
	@( $(SCRIPTS_DIR)/library/libtool.sh )

libraryAutotools: \
	libraryM4 libraryAutoconf libraryAutomake libraryLibtool
# -----------------------------------------------------

libraryGettext:
	@( $(SCRIPTS_DIR)/library/gettext.sh )

libraryPatch:
	@( $(SCRIPTS_DIR)/library/patch.sh )

librarySqlite3:
	@( $(SCRIPTS_DIR)/library/sqlite3.sh )

libraryLibffi:
	@( $(SCRIPTS_DIR)/library/libffi.sh )

# # openldap
# # -----------------------------------------------------
# libraryCyrusSASL:
#   @( $(SCRIPTS_DIR)/library/cyrus_sasl.sh )
#
# libraryLibsodium:
#   @( $(SCRIPTS_DIR)/library/libsodium.sh )
#
# libraryOpenLDAP: \
#   libraryCyrusSASL libraryLibsodium libraryLibevent
#   @( $(SCRIPTS_DIR)/library/openldap.sh )
# # -----------------------------------------------------
#
# libraryTexinfo:
#   @( $(SCRIPTS_DIR)/library/texinfo.sh )
#
# libraryGroff: \
#   libraryTexinfo
#   @( $(SCRIPTS_DIR)/library/groff.sh )

# gnutls
# -----------------------------------------------------
libraryGMP:
	@( $(SCRIPTS_DIR)/library/gmp.sh )

libraryLibnettle: \
	libraryGMP
	@( $(SCRIPTS_DIR)/library/libnettle.sh )

libraryLibtasn1:
	@( $(SCRIPTS_DIR)/library/libtasn1.sh )

libraryP11Kit: \
	libraryLibtasn1 libraryLibffi
	@( $(SCRIPTS_DIR)/library/p11_kit.sh )

libraryGnuTLS: \
	libraryGMP libraryLibnettle libraryP11Kit
	@( $(SCRIPTS_DIR)/library/gnutls.sh )
# -----------------------------------------------------

# gnupg
# -----------------------------------------------------
libraryLibgpgError:
	@( $(SCRIPTS_DIR)/library/libgpg_error.sh )

libraryLibgcrypt:
	@( $(SCRIPTS_DIR)/library/libgcrypt.sh )

libraryLibassuan:
	@( $(SCRIPTS_DIR)/library/libassuan.sh )

libraryLibksba:
	@( $(SCRIPTS_DIR)/library/libksba.sh )

libraryNpth:
	@( $(SCRIPTS_DIR)/library/npth.sh )

libraryGnuPG: \
	libraryLibgpgError libraryLibgcrypt libraryLibassuan \
	libraryLibksba libraryNpth libraryGnuTLS
	@( $(SCRIPTS_DIR)/library/gnupg.sh )
# -----------------------------------------------------

# x11
# -----------------------------------------------------
libraryXorgproto:
	@( $(SCRIPTS_DIR)/library/X11/xorgproto.sh )

libraryXtrans:
	@( $(SCRIPTS_DIR)/library/X11/xtrans.sh )

libraryLibxau:
	@( $(SCRIPTS_DIR)/library/X11/libxau.sh )

libraryXcbProto:
	@( $(SCRIPTS_DIR)/library/X11/xcb_proto.sh )

libraryLibxcb: libraryLibxau libraryXcbProto
	@( $(SCRIPTS_DIR)/library/X11/libxcb.sh )

# (xproto >= 7.0.25 xextproto xtrans xcb >= 1.11.1 kbproto inputproto
libraryLibx11: \
	libraryPkgConfig libraryXorgproto libraryXtrans libraryLibxcb
	@( $(SCRIPTS_DIR)/library/X11/libx11.sh )
# -----------------------------------------------------

libraryTcl:
	@( $(SCRIPTS_DIR)/library/tcl.sh )

libraryTk: \
	libraryTcl libraryLibx11
	@( $(SCRIPTS_DIR)/library/tk.sh )

# libraryBoost:
#   @( $(SCRIPTS_DIR)/library/boost.sh )

libraryLzma:
	@( $(SCRIPTS_DIR)/library/liblzma.sh )

# ====================================================
# APPS
# ====================================================

installTermInfo:
	@( $(SCRIPTS_DIR)/install/terminfo.sh )

# libraryNcurses
installZsh:
	@( $(SCRIPTS_DIR)/install/zsh.sh )

# libraryNcurses
installFish:
	@( $(SCRIPTS_DIR)/install/fish.sh )

installPrezto:
	@( $(SCRIPTS_DIR)/install/prezto.sh )

installNeovim:
	@( $(SCRIPTS_DIR)/install/neovim.sh )

# libraryNcurses libraryLibevent
installTmux:
	@( $(SCRIPTS_DIR)/install/tmux.sh )

installTree:
	@( $(SCRIPTS_DIR)/install/tree.sh )

installFd:
	@( $(SCRIPTS_DIR)/install/fd.sh )

installRg:
	@( $(SCRIPTS_DIR)/install/rg.sh )

installThefuck:
	@( $(SCRIPTS_DIR)/install/thefuck.sh )

installRanger:
	@( $(SCRIPTS_DIR)/install/ranger.sh )

installTldr:
	@( $(SCRIPTS_DIR)/install/tldr.sh )

installBashSnippets:
	@( $(SCRIPTS_DIR)/install/bash_snippets.sh )

installBpytop:
	@( $(SCRIPTS_DIR)/install/bpytop.sh )

installUp:
	@( $(SCRIPTS_DIR)/install/up.sh )

# # libraryBoost
# installHighlight:
#   @( $(SCRIPTS_DIR)/install/highlight.sh )

installPyenv:
	@ ( $(SCRIPTS_DIR)/install/pyenv.sh )

installGoenv:
	@( $(SCRIPTS_DIR)/install/goenv.sh )

installAsdf:
	@ ( $(SCRIPTS_DIR)/install/asdf.sh )

updatePrezto:
	@( $(SCRIPTS_DIR)/update/prezto.sh )

updateBins:
	@( $(SCRIPTS_DIR)/update/bins.sh )

updateConfigs:
	@( $(SCRIPTS_DIR)/update/configs.sh )

updateNeovimPlugins:
	@( $(SCRIPTS_DIR)/update/neovim_plugins.sh )

updateTPM:
	@( $(SCRIPTS_DIR)/update/tpm.sh )

updateTmuxPlugins: updateTPM
	@( $(SCRIPTS_DIR)/update/tmux_plugins.sh )

updateDevEnv:
	@( $(SCRIPTS_DIR)/update/dev_env.sh )

# ====================================================
# ENVIRONMENT
# ====================================================

# libraryOpenssl libraryReadline libraryZlib libraryBzip2 librarySqlite3 libraryLibffi libraryTcl libraryTk
environmentPython:
	@( $(SCRIPTS_DIR)/environment/python.sh )

environmentGolang:
	@( $(SCRIPTS_DIR)/environment/golang.sh )

environmentRust:
	@( $(SCRIPTS_DIR)/environment/rust.sh )

# libraryGnuPG
environmentNodejs:
	@( $(SCRIPTS_DIR)/environment/nodejs.sh )

environmentLua:
	@( $(SCRIPTS_DIR)/environment/lua.sh )

environmentSh:
	@( $(SCRIPTS_DIR)/environment/sh.sh )

changeDefaultShell:
	@( $(SCRIPTS_DIR)/change_default_shell.sh )

clean:
	@( sed -i -e '/# added from andys dotfiles/,/^fi$$/d' ${HOME}/.bashrc )
	@( rm -rf \
		${HOME}/.vimrc ${HOME}/.vim \
		${HOME}/.tmux ${HOME}/.tmux.conf \
		${HOME}/.zlogin ${HOME}/.zlogout ${HOME}/.zpreztorc ${HOME}/.zprofile \
		${HOME}/.zshenv ${HOME}/.zshrc ${HOME}/.zprezto \
		${HOME}/.fzf ${HOME}/.fzf.bash ${HOME}/.fzf.zsh \
		${HOME}/.config/nvim ${HOME}/.config/alacritty ${HOME}/.config/iterm2 \
		${HOME}/.config/yabai ${HOME}/.config/skhd \
		${HOME}/.config/spacebar ${HOME}/.config/swiftbar ${HOME}/.config/bitbar \
		${HOME}/.config/git ${HOME}/.config/flake8 ${HOME}/.config/pylintrc \
		${HOME}/.config/fish ${HOME}/.config/tealdeer ${HOME}/.config/vivid \
		${HOME}/.config/simplebar ${HOME}/.simplebarrc \
		|| true )
	@rm -rf $(PROJ_HOME)
	@find ${HOME}/.local/bin -type l -exec test ! -e {} \; -print | xargs rm -rf
	@echo "[0;92m[*][0m Remove all configurations files and custom functions"

installLibraries: \
	libraryHelp2man libraryPkgConfig \
	libraryZlib libraryBzip2 \
	libraryOpenssl \
	libraryNcurses libraryLibevent libraryReadline \
	libraryAutotools \
	libraryGettext libraryPatch \
	librarySqlite3 libraryLibffi \
	libraryGnuTLS libraryGnuPG \
	libraryLibx11 \
	libraryTcl libraryTk \
	libraryLzma

installEnvironmentUtilities: \
	installPyenv installGoenv installAsdf \
	updateDevEnv

installEnvironment: \
	environmentPython environmentGolang environmentRust environmentNodejs environmentLua \
	environmentSh

installEssentials: \
	installTermInfo installZsh installFish installPrezto \
	installNeovim installTmux

installUtilities: \
	installTree installFd installRg installRanger \
	installThefuck installTldr installBashSnippets installBpytop installUp

update: \
	updatePrezto \
	updateBins updateConfigs \
	updateNeovimPlugins \
	updateTPM \
	updateTmuxPlugins \
	updateDevEnv
	@echo
	@echo "[42m[30m[*] Update has been finished.[0m"

install: \
	installLibraries \
	installEnvironmentUtilities installEnvironment \
	installEssentials installUtilities
	@echo
	@echo "[42m[30m[*] Install has been finished.[0m"

init: \
	install \
	update \
	changeDefaultShell
	@echo
	@echo "[42m[30m[*] Init has been finished.[0m"

.PHONY: prerequisites prerequisitesTest \
	libraryHelp2man libraryHelp2man libraryNcurses \
	libraryOpenssl libraryLibevent \
	libraryM4 libraryAutoconf libraryAutomake libraryLibtool libraryAutotools \
	libraryGettext libraryPatch libraryReadline libraryZlib \
	libraryBzip2  librarySqlite3 libraryLibffi\
	libraryGMP libraryLibnettle libraryLibtasn1 libraryP11Kit libraryGnuTLS \
	libraryLibgpgError libraryLibgcrypt libraryLibassuan libraryLibksba libraryNpth libraryGnuPG \
	libraryPth libraryDirmngr \
	libraryXorgproto libraryXtrans libraryLibxau libraryXcbProto libraryLibxcb libraryLibx11 \
	libraryTcl libraryTk \
	installTermInfo installZsh installFish installPrezto \
	installNeovim installTmux \
	installTree installFd installRg installThefuck installRanger installTldr \
	installBashSnippets installBpytop installUp \
	installPyenv installGoenv installAsdf \
	updatePrezto updateBins updateConfigs updateNeovimPlugins updateTPM updateTmuxPlugins updateDevEnv \
	environmentPython environmentGo environmentRust environmentNodejs environmentLua environmentSh\
	changeDefaultShell \
	clean installLibraries installEnvironmentUtilities installEnvironment \
	installEssentials installUtilities \
	update install init
