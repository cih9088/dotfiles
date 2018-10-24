scripts := ./script

export PROJ_HOME := $(shell git rev-parse --show-toplevel)
export TMP_DIR= ${HOME}/tmp_install

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
	@mkdir -p $(TMP_DIR)

prerequisites:
	@( $(scripts)/prerequisites.sh )

installZsh:
	@( $(scripts)/zsh_setup.sh )

installPrezto:
	@( $(scripts)/prezto_setup.sh )

installNeovim:
	@( $(scripts)/nvim_setup.sh $(nvim_version) )

installTmux:
	@( $(scripts)/tmux_setup.sh $(tmux_version) )

installTPM:
	@echo "[*] Install TPM..."
	@rm -rf ~/.tmux/plugins/tpm || true
	@git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

installBins:
	@( $(scripts)/bin_setup.sh )

installDevShell:
	@( $(scripts)/shell_setup.sh )

installDevPython:
	@pip install glances --user
	@pip install grip --user
	@pip install gpustat --user
	@pip install ipdb --user
	@pip install pudb --user
	@pip install pylint --user
	@pip install jedi --user
	@pip install virtualenv --user || true
	@pip install virtualenvwrapper --user || true
	@pip3 install virtualenv --user || true
	@pip3 install virtualenvwrapper --user || true

installPythonVirtualenv:
	@( $(scripts)/virenv_setup.sh )

changeDefaultShell:
	@( $(scripts)/change_defualt_to_zsh.sh )

updateBins:
	@( $(scripts)/custom_bin_setup.sh )

updatePrezto:
	@cd ~/.zprezto
	@git pull
	@git submodule update --init --recursive

updateDotfiles:
	@( $(scripts)/dot_setup.sh )

updateNeovimPlugins:
	@echo
	@echo "[*] Install neovim plugins..."
	@nvim -E -s -u "${HOME}/.config/nvim/init.vim" +PlugInstall +PlugUpdate +PlugUpgrade +UpdateRemotePlugins +qall

updateTmuxPlugins: installTPM
	@echo
	@echo "[*] Install tmux plugin..."
	@~/.tmux/plugins/tpm/scripts/install_plugins.sh

clean:
	@rm -rf $(TMP_DIR)

updateAll: updateDotfiles updateNeovimPlugins updateTmuxPlugins updateBins

installAll: prepare installZsh installPrezto changeDefaultShell updateDotfiles installNeovim \
	installTmux installTPM installBins updateBins updateNeovimPlugins updateTmuxPlugins clean

installDevAll: installDevPython installDevShell

.PHONY: prerequisites installZsh installPrezto updatePrezto installNeovim installTmux \
	installBins installDevShell installDevPython installPythonVirtualenv changeDefaultShell \
	updateDotfiles updateNeovimPlugins updateTmuxPlugins clean updateAll installAll installDevAll \
	installTPM

