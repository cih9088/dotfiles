export PATH := ${HOME}/.local/bin:${PATH}
export PROJ_HOME := $(shell git rev-parse --show-toplevel)
export TMP_DIR := ${HOME}/tmp_install
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

prepare:
	@mkdir -p ${HOME}/.local/bin
	@mkdir -p ${HOME}/.local/src
	@mkdir -p ${HOME}/.local/shared
	@mkdir -p ${HOME}/.local/man/man1
	@mkdir -p ${HOME}/.config/alacritty

prerequisites:
	@( $(SCRIPTS_DIR)/prerequisites.sh )

prerequisitesTest:
	@which -a python || echo "[0;91mpython is not installed[0m"
	@which -a pip || echo "[0;91mpip is not installed[0m"
	@which -a python2 || echo "[0;91mpython2 is not installed[0m"
	@which -a pip3 || echo "[0;91mpip2 is not installed[0m"
	@which -a python3 || echo "[0;91mpython3 is not installed[0m"
	@which -a pip3 || echo "[0;91mpip3 is not installed[0m"
	@which -a wget || echo "[0;91mwget is not installed[0m"
	@which -a xclip || echo "[0;91mxclip is not installed (for ubuntu)[0m"
	@which -a pbcopy || echo "[0;91mpbcopy is not installed (for osx specific)[0m"
	@which -a reattatch-to-user-namespace || echo "[0;91mreattatch-to-user-namepsace is not installed (for osx specific)[0m"
	@which -a git || echo "[0;91mgit is not installed[0m"

installZsh: prepare
	@( $(SCRIPTS_DIR)/install_zsh.sh )

installPrezto: prepare
	@( $(SCRIPTS_DIR)/install_prezto.sh )

installNeovim: prepare
	@( $(SCRIPTS_DIR)/install_neovim.sh $(nvim_version) )

installTmux: prepare
	@( $(SCRIPTS_DIR)/install_tmux.sh $(tmux_version) )

installBins: prepare
	@( $(SCRIPTS_DIR)/install_bins.sh )

installDevShell:
	@( $(SCRIPTS_DIR)/installDev_shell.sh )

installDevPython:
	@( $(SCRIPTS_DIR)/installDev_python.sh )

installDevNodejs:
	@( $(SCRIPTS_DIR)/installDev_nodejs.sh )

installPythonVirtualenv:
	@( $(SCRIPTS_DIR)/virenv_setup.sh )

changeDefaultShell:
	@( $(SCRIPTS_DIR)/change_defualt_to_zsh.sh )

updateBins: prepare
	@( $(SCRIPTS_DIR)/custom_bin_setup.sh )

updatePrezto:
	@echo
	@echo "[0;93m[+][0m Updating prezto..."
	@cd ~/.zprezto; git pull >/dev/null 2>&1; git submodule update --init --recursive >/dev/null 2>&1
	@echo "[0;92m[*][0m prezto updated"

updateDotfiles:
	@( $(SCRIPTS_DIR)/dot_setup.sh )

updateNeovimPlugins:
	@echo
	@echo "[0;93m[+][0m Updating neovim plugins..."
	@nvim -E -s -u "${HOME}/.config/nvim/init.vim" +PlugInstall +PlugUpdate +PlugUpgrade +UpdateRemotePlugins +qall || true
	@ln -snf $(PROJ_HOME)/vim/andy_lightline.vim ${HOME}/.local/share/nvim/plugged/lightline.vim/autoload/lightline/colorscheme
	@echo "[0;92m[*][0m neovim plugins updated"

updateTPM:
	@echo
	@echo "[0;93m[+][0m Updating TPM..."
	@rm -rf ~/.tmux/plugins/tpm || true
	@git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm >/dev/null 2>&1
	@echo "[0;92m[*][0m TPM updated"

updateTmuxPlugins: updateTPM 
	@echo
	@echo "[0;93m[+][0m Updating tmux plugins..."
	@${HOME}/.tmux/plugins/tpm/scripts/install_plugins.sh >/dev/null 2>&1
	@${HOME}/.tmux/plugins/tpm/scripts/update_plugin.sh "" all >/dev/null 2>&1
	@echo "[0;92m[*][0m tmux plugins updated"

clean:
	@echo "[0;92m[*][0m Remove dotfiles and configuration folders"
	@rm -rf $(TMP_DIR)
	@rm -rf ${HOME}/.zlogin ${HOME}/.zlogout ${HOME}/.zpreztorc ${HOME}/.zprofile \
		${HOME}/.zshenv ${HOME}/.zshrc ${HOME}/.zprezto ${HOME}/.fzf ${HOME}/.fzf.bash ${HOME}/.fzf.zsh \
		${HOME}/.grip ${HOME}/.pylintrc ${HOME}/.tmux ${HOME}/.tmux.conf \
		${HOME}/.vimrc ${HOME}/.vim \
		${HOME}/.config/nvim ${HOME}/.config/alacritty
	@rm -rf $(PROJ_HOME)

update: prepare updateDotfiles updateNeovimPlugins updateTPM updateTmuxPlugins updateBins updatePrezto
	@echo
	@echo "[42m[*] Update has Finished.[0m"

install: prepare installZsh changeDefaultShell installPrezto \
	installNeovim installTmux installBins
	@echo
	@echo "[42m[*] Install has Finished.[0m"

installDev: installDevNodejs installDevPython installDevShell
	@echo
	@echo "[42m[*] InstallDev has Finished.[0m"

init: prepare install update installDev
	@echo
	@echo "[42m[*] Init has Finished.[0m"

.PHONY: prepare prerequisites prerequisitesTest \
	installZsh installPrezto updatePrezto installNeovim installTmux \
	installBins installDevShell installDevPython installPythonVirtualenv changeDefaultShell \
	updateDotfiles updateNeovimPlugins updateTmuxPlugins updateTPM\
	clean update install installDev init \

