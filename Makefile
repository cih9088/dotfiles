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
	@mkdir -p $(TMP_DIR)

prerequisites:
	@( $(SCRIPTS_DIR)/prerequisites.sh )

installZsh: prepare
	@( $(SCRIPTS_DIR)/zsh_setup.sh )

installPrezto: prepare
	@( $(SCRIPTS_DIR)/prezto_setup.sh )

installNeovim: prepare
	@( $(SCRIPTS_DIR)/nvim_setup.sh $(nvim_version) )

installTmux: prepare
	@( $(SCRIPTS_DIR)/tmux_setup.sh $(tmux_version) )

installTPM:
	@echo
	@echo "[0;93m[+][0m Installing TPM..."
	@rm -rf ~/.tmux/plugins/tpm || true
	@git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm >/dev/null 2>&1
	@echo "[0;92m[*][0m TPM installed"

installBins: prepare
	@( $(SCRIPTS_DIR)/bin_setup.sh )

installDevShell:
	@( $(SCRIPTS_DIR)/shell_setup.sh )
	@echo
	@echo "[0;93m[+][0m Installing bash-language-server..."
	@npm i -g bash-language-server
	@echo "[0;92m[*][0m bash-language-server installed"

installDevPython:
	@echo
	@echo "[0;93m[+][0m Installing python dev..."
	@pip install glances --user >/dev/null 2>&1
	@pip install grip --user >/dev/null 2>&1
	@pip install gpustat --user >/dev/null 2>&1
	@pip install ipdb --user >/dev/null 2>&1
	@pip install pudb --user >/dev/null 2>&1
	@pip install pylint --user >/dev/null 2>&1
	@pip install pylint-venv --user >/dev/null 2>&1
	@pip install jedi --user >/dev/null 2>&1
	@pip install 'python-language-server[all]' --user >/dev/null 2>&1
	@pip install virtualenv --user >/dev/null 2>&1
	@pip install virtualenvwrapper --user >/dev/null 2>&1
	@pip3 install virtualenv --user >/dev/null 2>&1
	@pip3 install virtualenvwrapper --user >/dev/null 2>&1
	@echo "[0;92m[*][0m python dev installed"

installDevNodejs:
	@echo
	@echo "[0;93m[+][0m Installing Node.js..."
	@curl -sL install-node.now.sh/lts | sh -s -- --prefix=${HOME}/.local
	@echo "[0;92m[*][0m Node.js installed"

installPythonVirtualenv:
	@( $(SCRIPTS_DIR)/virenv_setup.sh )

changeDefaultShell:
	@( $(SCRIPTS_DIR)/change_defualt_to_zsh.sh )

updateBins: prepare
	@( $(SCRIPTS_DIR)/custom_bin_setup.sh )

updatePrezto:
	@echo
	@echo "[0;93m[+][0m Updating prezto..."
	@cd ~/.zprezto
	@git pull >/dev/null >/dev/null 2>&1
	@git submodule update --init --recursive >/dev/null 2>&1
	@echo "[0;92m[*][0m prezto updated"

updateDotfiles:
	@( $(SCRIPTS_DIR)/dot_setup.sh )

updateNeovimPlugins:
	@echo
	@echo "[0;93m[+][0m Updating neovim plugins..."
	@nvim -E -s -u "${HOME}/.config/nvim/init.vim" +PlugInstall +PlugUpdate +PlugUpgrade +UpdateRemotePlugins +qall || true
	@ln -snf $(PROJ_HOME)/vim/andy_lightline.vim ${HOME}/.local/share/nvim/plugged/lightline.vim/autoload/lightline/colorscheme
	@echo "[0;92m[*][0m neovim plugins updated"

updateTmuxPlugins: installTPM
	@echo
	@echo "[0;93m[+][0m Updating tmux plugins..."
	@${HOME}/.tmux/plugins/tpm/scripts/install_plugins.sh >/dev/null 2>&1
	@echo "[0;92m[*][0m tmux plugins updated"

prepare_clean:
	@echo
	@echo "[0;92m[*][0m Done."
	@rm -rf $(TMP_DIR)

clean:
	@echo "Remove dotfiles and folder itself"
	@rm -rf ${HOME}/.zlogin ${HOME}/.zlogout ${HOME}/.zpreztorc ${HOME}/.zprofile \
		${HOME}/.zshenv ${HOME}/.zshrc ${HOME}/.zprezto ${HOME}/.fzf ${HOME}/.fzf.bash ${HOME}/.fzf.zsh \
		${HOME}/.grip ${HOME}/.pylintrc ${HOME}/.tmux ${HOME}/.tmux.conf \
		${HOME}/.vimrc ${HOME}/.vim \
		${HOME}/.config/nvim ${HOME}/.config/alacritty
	@rm -rf $(PROJ_HOME)


update: prepare updateDotfiles updateNeovimPlugins updateTmuxPlugins updateBins updatePrezto prepare_clean

install: prepare installZsh changeDefaultShell installPrezto updateDotfiles \
	installNeovim installTmux installTPM installBins prepare_clean

installDev: installDevNodejs installDevPython installDevShell

init: install update installDev

.PHONY: prepare prerequisites installZsh installPrezto updatePrezto installNeovim installTmux \
	installBins installDevShell installDevPython installPythonVirtualenv changeDefaultShell \
	updateDotfiles updateNeovimPlugins updateTmuxPlugins prepare_clean installTPM \
	clean update install installDev init \

