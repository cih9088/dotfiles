export PATH := ${HOME}/.local/bin:${PATH}
export PROJ_HOME := $(shell git rev-parse --show-toplevel)
export BIN_DIR := $(PROJ_HOME)/bin
export SCRIPTS_DIR := $(PROJ_HOME)/script

ifeq (installNeovim,$(firstword $(MAKECMDGOALS)))
    nvim_version := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
    $(eval $(nvim_version):;@:)
endif

ifeq (installTmux,$(firstword $(MAKECMDGOALS)))
    tmux_version := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
    $(eval $(tmux_version):;@:)
endif

ifeq (installZsh,$(firstword $(MAKECMDGOALS)))
    zsh_version := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
    $(eval $(zsh_version):;@:)
endif

ifeq (installFish,$(firstword $(MAKECMDGOALS)))
    fish_version := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
    $(eval $(fish_version):;@:)
endif

ifeq (installTree,$(firstword $(MAKECMDGOALS)))
    tree_version := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
    $(eval $(tree_version):;@:)
endif

ifeq (installFd,$(firstword $(MAKECMDGOALS)))
    fd_version := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
    $(eval $(fd_version):;@:)
endif

ifeq (installRg,$(firstword $(MAKECMDGOALS)))
    rg_version := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
    $(eval $(rg_version):;@:)
endif

prepare:
	@mkdir -p ${HOME}/.local/bin
	@mkdir -p ${HOME}/.local/src
	@mkdir -p ${HOME}/.local/shared
	@mkdir -p ${HOME}/.local/man/man1
	@mkdir -p ${HOME}/.config/alacritty
	@mkdir -p ${HOME}/.config/yabai
	@mkdir -p ${HOME}/.config/skhd
	@mkdir -p ${HOME}/.config/spacebar

initOSX:
	@( $(SCRIPTS_DIR)/osx_prep.sh )
	@( $(SCRIPTS_DIR)/osx_brew.sh )

prerequisites:
	@( $(SCRIPTS_DIR)/prerequisites.sh )

prerequisitesTest:
	@( $(SCRIPTS_DIR)/prerequisites_test.sh )

installTermInfo:
	@( $(SCRIPTS_DIR)/install_terminfo.sh )

installZsh: prepare
	@( $(SCRIPTS_DIR)/install_zsh.sh $(zsh_version) )

installFish: prepare
	@( $(SCRIPTS_DIR)/install_fish.sh $(fish_version) )

installPrezto: prepare
	@( $(SCRIPTS_DIR)/install_prezto.sh )

installNeovim: prepare installDevPython installDevNodejs installDevGo
	@( $(SCRIPTS_DIR)/install_neovim.sh $(nvim_version) )

installTmux: prepare
	@( $(SCRIPTS_DIR)/install_tmux.sh $(tmux_version) )

installTree: prepare
	@( $(SCRIPTS_DIR)/install_tree.sh $(tree_version) )

installFd: prepare
	@( $(SCRIPTS_DIR)/install_fd.sh $(fd_version) )

installRg: prepare
	@( $(SCRIPTS_DIR)/install_rg.sh $(rg_version) )

installRanger: prepare
	@( $(SCRIPTS_DIR)/install_ranger.sh )

installThefuck: prepare
	@( $(SCRIPTS_DIR)/install_thefuck.sh )

installTldr: prepare
	@( $(SCRIPTS_DIR)/install_tldr.sh )

installBashSnippets: prepare
	@( $(SCRIPTS_DIR)/install_bash_snippets.sh )

installDevShell:
	@( $(SCRIPTS_DIR)/installDev_shell.sh )

installDevPython:
	@( $(SCRIPTS_DIR)/installDev_python.sh )

installDevNodejs:
	@( $(SCRIPTS_DIR)/installDev_nodejs.sh )

installDevC:
	@( $(SCRIPTS_DIR)/installDev_c.sh )

installDevGo:
	@( $(SCRIPTS_DIR)/installDev_go.sh )

installDevAsdf:
	@ ( $(SCRIPTS_DIR)/installDev_asdf.sh )

installPythonVirtualenv:
	@( $(SCRIPTS_DIR)/virenv_setup.sh )

changeDefaultShell:
	@( $(SCRIPTS_DIR)/change_defualt_shell.sh )

updateCustomBins: prepare
	@( $(SCRIPTS_DIR)/update_custom_bins.sh )

updatePrezto:
	@( $(SCRIPTS_DIR)/update_prezto.sh )

updateDotfiles:
	@( $(SCRIPTS_DIR)/update_dotfiles.sh )

updateNeovimPlugins:
	@( $(SCRIPTS_DIR)/update_neovim_plugins.sh )

updateTPM:
	@( $(SCRIPTS_DIR)/update_tpm.sh )

updateTmuxPlugins: updateTPM
	@( $(SCRIPTS_DIR)/update_tmux_plugins.sh )

updateDevEnv:
	@( $(SCRIPTS_DIR)/update_dev_env.sh )

clean:
	@( sed -i -e '/# added from andys dotfiles/,/^fi$$/d' ${HOME}/.bashrc )
	@( rm -rf ${HOME}/.zlogin ${HOME}/.zlogout ${HOME}/.zpreztorc ${HOME}/.zprofile \
		${HOME}/.zshenv ${HOME}/.zshrc ${HOME}/.zprezto \
		${HOME}/.fzf ${HOME}/.fzf.bash ${HOME}/.fzf.zsh \
		${HOME}/.gitignore \
		${HOME}/.grip ${HOME}/.pylintrc ${HOME}/.flake8 ${HOME}/.tmux ${HOME}/.tmux.conf \
		${HOME}/.vimrc ${HOME}/.vim \
		${HOME}/.config/nvim ${HOME}/.config/alacritty ${HOME}/.config/coc ${HOME}/.config/ranger \
		${HOME}/.config/yabai ${HOME}/.config/skhd ${HOME}/.config/spacebar ${HOME}/.config/tealdeer || true )
	@rm -rf $(PROJ_HOME)
	@find ${HOME}/.local/bin -type l -exec test ! -e {} \; -print | xargs rm -rf
	@echo "[0;92m[*][0m Remove all configurations files and custom functions"

installBins: prepare installTree installFd installRg installRanger \
	installThefuck installTldr installBashSnippets

update: prepare updateDotfiles updateNeovimPlugins updateTPM updateTmuxPlugins updateCustomBins \
	updatePrezto updateDevEnv
	@echo
	@echo "[42m[30m[*] Update has Finished.[0m"

install: prepare installTermInfo installZsh changeDefaultShell installPrezto installDevAsdf \
	installNeovim installTmux installBins
	@echo
	@echo "[42m[30m[*] Install has Finished.[0m"

init: prepare install update
	@echo
	@echo "[42m[30m[*] Init has Finished.[0m"

.PHONY: prepare prerequisites prerequisitesTest \
	installZsh installFish installPrezto installNeovim installTmux \
	installBins installPythonVirtualenv \
	installDevShell installDevPython installDevNodejs installDevC installDevGo changeDefaultShell \
	installDevAsdf updateDevEnv\
	updateDotfiles updateNeovimPlugins updateTmuxPlugins updateTPM updateCustomBins updatePrezto \
	clean update install init initOSX \

