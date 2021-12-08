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
#
# ifeq (installNeovim,$(firstword $(MAKECMDGOALS)))
#   nvim_version := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
#   $(eval $(nvim_version):;@:)
# endif

prepare:
	@mkdir -p ${HOME}/.config
	@mkdir -p ${HOME}/.local/bin
	@mkdir -p ${HOME}/.local/src
	@mkdir -p ${HOME}/.local/shared
	@mkdir -p ${HOME}/.local/man/man1
	@mkdir -p ${HOME}/.local/include
	@mkdir -p ${HOME}/.local/lib
	@mkdir -p ${HOME}/.local/lib/pkgconfig

initMac:
	@( $(SCRIPTS_DIR)/mac/prepare.sh )
	@( $(SCRIPTS_DIR)/mac/brew.sh )
	@( $(SCRIPTS_DIR)/mac/init.sh )

prerequisites:
	@( $(SCRIPTS_DIR)/prerequisites.sh )

prerequisitesTest:
	@( $(SCRIPTS_DIR)/prerequisites_test.sh )

installLibraryHelp2man: prepare
	@( $(SCRIPTS_DIR)/library/help2man.sh )

installLibraryPkgConfig: prepare
	@( $(SCRIPTS_DIR)/library/pkg_config.sh )

installLibraryNcurses: prepare
	@( $(SCRIPTS_DIR)/library/ncurses.sh )

installLibraryOpenssl: prepare
	@( $(SCRIPTS_DIR)/library/openssl.sh )

installLibraryLibevent: prepare
	@( $(SCRIPTS_DIR)/library/libevent.sh )

########################################################
installLibraryM4: prepare
	@( $(SCRIPTS_DIR)/library/m4.sh )

installLibraryAutoconf: prepare installLibraryM4
	@( $(SCRIPTS_DIR)/library/autoconf.sh )

installLibraryAutomake: prepare installLibraryAutoconf
	@( $(SCRIPTS_DIR)/library/automake.sh )

installLibraryLibtool: prepare installLibraryAutomake
	@( $(SCRIPTS_DIR)/library/libtool.sh )

installLibraryAutotools: \
	installLibraryM4 installLibraryAutoconf installLibraryAutomake installLibraryLibtool
########################################################

installLibraryGettext: prepare
	@( $(SCRIPTS_DIR)/library/gettext.sh )

installLibraryPatch: prepare
	@( $(SCRIPTS_DIR)/library/patch.sh )

installLibraryReadline: prepare installLibraryNcurses
	@( $(SCRIPTS_DIR)/library/readline.sh )

installLibraryZlib: prepare
	@( $(SCRIPTS_DIR)/library/zlib.sh )

installLibraryBzip2: prepare
	@( $(SCRIPTS_DIR)/library/bzip2.sh )

installLibrarySqlite3: prepare
	@( $(SCRIPTS_DIR)/library/sqlite3.sh )

########################################################
installLibraryLibgpgError: prepare
	@( $(SCRIPTS_DIR)/library/libgpg_error.sh )

installLibraryLibgcrypt: prepare
	@( $(SCRIPTS_DIR)/library/libgcrypt.sh )

installLibraryLibassuan: prepare
	@( $(SCRIPTS_DIR)/library/libassuan.sh )

installLibraryLibksba: prepare
	@( $(SCRIPTS_DIR)/library/libksba.sh )

installLibraryNpth: prepare
	@( $(SCRIPTS_DIR)/library/npth.sh )

installLibraryGpg: prepare \
	installLibraryLibgpgError installLibraryLibgcrypt installLibraryLibassuan \
	installLibraryLibksba installLibraryNpth
	@( $(SCRIPTS_DIR)/install/gpg.sh )

installLibraryPth: prepare
	@( $(SCRIPTS_DIR)/library/pth.sh )

# openldap library
# installLibraryLibgpgError installLibraryLibgcrypt installLibraryLibassuan installLibraryAutomake installLibraryPth
installLibraryDirmngr: prepare
	@( $(SCRIPTS_DIR)/install/dirmngr.sh )
########################################################

########################################################
installLibraryXorgproto: prepare
	@( $(SCRIPTS_DIR)/library/X11/xorgproto.sh )

installLibraryXtrans: prepare
	@( $(SCRIPTS_DIR)/library/X11/xtrans.sh )

installLibraryLibxau: prepare
	@( $(SCRIPTS_DIR)/library/X11/libxau.sh )

installLibraryXcbProto: prepare
	@( $(SCRIPTS_DIR)/library/X11/xcb_proto.sh )

installLibraryLibxcb: prepare installLibraryLibxau installLibraryXcbProto
	@( $(SCRIPTS_DIR)/library/X11/libxcb.sh )

# (xproto >= 7.0.25 xextproto xtrans xcb >= 1.11.1 kbproto inputproto
installLibraryLibx11: prepare \
	installLibraryPkgConfig installLibraryXorgproto installLibraryXtrans installLibraryLibxcb
	@( $(SCRIPTS_DIR)/library/X11/libx11.sh )
########################################################

installLibraryLibffi: prepare
	@( $(SCRIPTS_DIR)/library/libffi.sh )

installLibraryTcl: prepare
	@( $(SCRIPTS_DIR)/library/tcl.sh )

installLibraryTk: prepare \
	installLibraryTcl installLibraryLibx11
	@( $(SCRIPTS_DIR)/library/tk.sh )

installLibraryBoost: prepare
	@( $(SCRIPTS_DIR)/library/boost.sh )

installTermInfo: prepare
	@( $(SCRIPTS_DIR)/install/terminfo.sh )

# installLibraryNcurses
installZsh: prepare
	@( $(SCRIPTS_DIR)/install/zsh.sh )

# installLibraryNcurses
installFish: prepare
	@( $(SCRIPTS_DIR)/install/fish.sh )

installPrezto: prepare
	@( $(SCRIPTS_DIR)/install/prezto.sh )

installNeovim: prepare
	@( $(SCRIPTS_DIR)/install/neovim.sh )

# installLibraryNcurses installLibraryLibevent
installTmux: prepare
	@( $(SCRIPTS_DIR)/install/tmux.sh )

# installTmux
installTPM: prepare
	@( $(SCRIPTS_DIR)/install/tpm.sh )

installTree: prepare
	@( $(SCRIPTS_DIR)/install/tree.sh )

installFd: prepare
	@( $(SCRIPTS_DIR)/install/fd.sh )

installRg: prepare
	@( $(SCRIPTS_DIR)/install/rg.sh )

installThefuck: prepare
	@( $(SCRIPTS_DIR)/install/thefuck.sh )

installRanger: prepare
	@( $(SCRIPTS_DIR)/install/ranger.sh )

installTldr: prepare
	@( $(SCRIPTS_DIR)/install/tldr.sh )

installBashSnippets: prepare
	@( $(SCRIPTS_DIR)/install/bash_snippets.sh )

installBpytop: prepare
	@( $(SCRIPTS_DIR)/install/bpytop.sh )

installUp: prepare
	@( $(SCRIPTS_DIR)/install/up.sh )

# installLibraryBoost
installHighlight: prepare
	@( $(SCRIPTS_DIR)/install/highlight.sh )

installPyenv: prepare
	@ ( $(SCRIPTS_DIR)/install/pyenv.sh )

installGoenv: prepare
	@( $(SCRIPTS_DIR)/install/goenv.sh )

installAsdf: prepare
	@ ( $(SCRIPTS_DIR)/install/asdf.sh )

installShellcheck: prepare
	@( $(SCRIPTS_DIR)/install/shellcheck.sh )

updatePrezto: prepare
	@( $(SCRIPTS_DIR)/update/prezto.sh )

updateBins: prepare
	@( $(SCRIPTS_DIR)/update/bins.sh )

updateConfigs: prepare
	@( $(SCRIPTS_DIR)/update/configs.sh )

updateNeovimPlugins: prepare
	@( $(SCRIPTS_DIR)/update/neovim_plugins.sh )

updateTmuxPlugins: installTPM
	@( $(SCRIPTS_DIR)/update/tmux_plugins.sh )

updateDevEnv: prepare
	@( $(SCRIPTS_DIR)/update/dev_env.sh )

# installLibraryOpenssl installLibraryReadline installLibraryZlib installLibraryBzip2 installLibrarySqlite3 installLibraryLibffi installLibraryTcl installLibraryTk
environmentPython: prepare
	@( $(SCRIPTS_DIR)/environment/python.sh )

environmentGo: prepare
	@( $(SCRIPTS_DIR)/environment/go.sh )

environmentRust: prepare
	@( $(SCRIPTS_DIR)/environment/rust.sh )

# installLibraryGpg installLibraryDirmngr
environmentNodejs: prepare
	@( $(SCRIPTS_DIR)/environment/nodejs.sh )

changeDefaultShell:
	@( $(SCRIPTS_DIR)/change_defualt_shell.sh )

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

installLibraries: prepare \
	installLibraryHelp2man installLibraryPkgConfig installLibraryNcurses \
	installLibraryOpenssl installLibraryLibevent installLibraryAutotools \
	installLibraryGettext installLibraryPatch installLibraryReadline \
	installLibraryZlib installLibraryBzip2 installLibrarySqlite3 \
	installLibraryLibx11 \
	installLibraryLibffi installLibraryTcl installLibraryTk

installEnvironmentUtilities: prepare \
	installPyenv installGoenv installAsdf \
	installShellcheck updateDevEnv

installEnvironment: prepare \
	environmentPython environmentGo environmentRust environmentNodejs

installEssentials: prepare \
	installTermInfo installZsh installFish installPrezto \
	installNeovim installTmux

installUtilities: prepare \
	installTree installFd installRg installRanger \
	installThefuck installTldr installBashSnippets installBpytop installUp

update: prepare \
	updatePrezto \
	updateBins updateConfigs \
	updateNeovimPlugins \
	installTPM \
	updateTmuxPlugins \
	updateDevEnv
	@echo
	@echo "[42m[30m[*] Update has been finished.[0m"

install: prepare \
	installLibraries \
	installEnvironmentUtilities installEnvironment \
	installEssentials installUtilities
	@echo
	@echo "[42m[30m[*] Install has been finished.[0m"

init: prepare \
	install \
	update \
	changeDefaultShell
	@echo
	@echo "[42m[30m[*] Init has been finished.[0m"

.PHONY: prepare prerequisites prerequisitesTest \
	installLibraryHelp2man installLibraryHelp2man installLibraryNcurses \
	installLibraryOpenssl installLibraryLibevent \
	installLibraryM4 installLibraryAutoconf installLibraryAutomake installLibraryLibtool installLibraryAutotools \
	installLibraryGettext installLibraryPatch installLibraryReadline installLibraryZlib \
	installLibraryBzip2  installLibrarySqlite3 \
	installLibraryLibgpgError installLibraryLibgcrypt installLibraryLibassuan installLibraryLibksba installLibraryNpth installLibraryGpg \
	installLibraryPth installLibraryDirmngr \
	installLibraryXorgproto installLibraryXtrans installLibraryLibxau installLibraryXcbProto installLibraryLibxcb installLibraryLibx11 \
	installLibraryLibffi installLibraryTcl installLibraryTk \
	installLibraryBoost \
	installTermInfo installZsh installFish installPrezto \
	installNeovim installTmux installTPM \
	installTree installFd installRg installThefuck installRanger installTldr \
	installBashSnippets installBpytop installUp installHighlight \
	installPyenv installGoenv installAsdf installShellcheck \
	updatePrezto updateBins updateConfigs updateNeovimPlugins updateTmuxPlugins updateDevEnv \
	environmentPython environmentGo environmentRust environmentNodejs \
	changeDefaultShell \
	clean installLibraries installEnvironmentUtilities installEnvironment \
	installEssentials installUtilities \
	update install init
