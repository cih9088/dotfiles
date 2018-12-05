export PATH := ${HOME}/.local/bin:${PATH}
export PROJ_HOME := $(shell git rev-parse --show-toplevel)
export TMP_DIR= ${HOME}/tmp_install

scripts := $(PROJ_HOME)/script

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
	@( $(scripts)/prerequisites.sh )

installZsh: prepare
	@( $(scripts)/zsh_setup.sh )

installPrezto: prepare
	@( $(scripts)/prezto_setup.sh )

installNeovim: prepare
	@( $(scripts)/nvim_setup.sh $(nvim_version) )

installTmux: prepare
	@( $(scripts)/tmux_setup.sh $(tmux_version) )

installTPM:
	@echo
	@echo "[0;93m[+][0m Installing TPM..."
	@rm -rf ~/.tmux/plugins/tpm || true
	@git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm >/dev/null 2>&1
	@echo "[0;92m[*][0m TPM installed"

installBins: prepare
	@( $(scripts)/bin_setup.sh )

installDevShell:
	@( $(scripts)/shell_setup.sh )
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
	@( $(scripts)/virenv_setup.sh )

changeDefaultShell:
	@( $(scripts)/change_defualt_to_zsh.sh )

updateBins: prepare
	@( $(scripts)/custom_bin_setup.sh )

updatePrezto:
	@echo
	@echo "[0;93m[+][0m Updating prezto..."
	@cd ~/.zprezto
	@git pull >/dev/null >/dev/null 2>&1
	@git submodule update --init --recursive >/dev/null 2>&1
	@echo "[0;92m[*][0m prezto updated"

updateDotfiles:
	@( $(scripts)/dot_setup.sh )

updateNeovimPlugins:
	@echo
	@echo "[0;93m[+][0m Updating neovim plugins..."
	@nvim -E -s -u "${HOME}/.config/nvim/init.vim" +PlugInstall +PlugUpdate +PlugUpgrade +UpdateRemotePlugins +qall || true
	@echo "[0;92m[*][0m neovim plugins updated"

updateTmuxPlugins: installTPM
	@echo
	@echo "[0;93m[+][0m Updating tmux plugins..."
	@~/.tmux/plugins/tpm/scripts/install_plugins.sh >/dev/null 2>&1
	@echo "[0;92m[*][0m tmux plugins updated"

prepare_clean:
	@rm -rf $(TMP_DIR)

wipeout:
	@rm -rf ${HOME}/.zlogin ${HOME}/.zlogout ${HOME}/.zpreztorc ${HOME}/.zprofile \
		${HOME}/.zshenv ${HOME}/.zshrc ${HOME}/.zprezto ${HOME}/.fzf ${HOME}/.fzf.bash ${HOME}/.fzf.zsh \
		${HOME}/.grip ${HOME}/.pylintrc ${HOME}/.tmux ${HOME}/.tmux.conf \
		${HOME}/.vimrc ${HOME}/.vim \
		${HOME}/.config/nvim ${HOME}/.config/alacritty


updateAll: prepare updateDotfiles updateNeovimPlugins updateTmuxPlugins updateBins updatePrezto prepare_clean

installAll: prepare installZsh installPrezto installNeovim installTmux installTPM installBins prepare_clean

installUpdateAll: prepare installZsh changeDefaultShell installPrezto installNeovim installTmux \
	updateDotfiles \
	installTPM installBins \
	updateNeovimPlugins updateBins updatePrezto prepare_clean

installDevAll: installDevNodejs installDevPython installDevShell

.PHONY: prepare prerequisites installZsh installPrezto updatePrezto installNeovim installTmux \
	installBins installDevShell installDevPython installPythonVirtualenv changeDefaultShell \
	updateDotfiles updateNeovimPlugins updateTmuxPlugins prepare_clean updateAll installAll installDevAll \
	installTPM

