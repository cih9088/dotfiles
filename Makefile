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

ifeq (installAsh,$(firstword $(MAKECMDGOALS)))
    zsh_version := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
    $(eval $(zsh_version):;@:)
endif

prepare:
	@mkdir -p ${HOME}/.local/bin
	@mkdir -p ${HOME}/.local/src
	@mkdir -p ${HOME}/.local/shared
	@mkdir -p ${HOME}/.local/man/man1
	@mkdir -p ${HOME}/.config/alacritty

initOSX:
	@( $(SCRIPTS_DIR)/osx_prep.sh )
	@( $(SCRIPTS_DIR)/osx_brew.sh )

prerequisites:
	@( $(SCRIPTS_DIR)/prerequisites.sh )

prerequisitesTest:
	@( $(SCRIPTS_DIR)/prerequisites_test.sh )

installZsh: prepare
	@( $(SCRIPTS_DIR)/install_zsh.sh $(zsh_version) )

installPrezto: prepare
	@( $(SCRIPTS_DIR)/install_prezto.sh )

installNeovim: prepare installDevPython
	@( $(SCRIPTS_DIR)/install_neovim.sh $(nvim_version) )

installTmux: prepare
	@( $(SCRIPTS_DIR)/install_tmux.sh $(tmux_version) )

installBins: prepare
	@( $(SCRIPTS_DIR)/install_bins.sh )

installDevShell: installDevNodejs
	@( $(SCRIPTS_DIR)/installDev_shell.sh )

installDevPython:
	@( $(SCRIPTS_DIR)/installDev_python.sh )

installDevNodejs:
	@( $(SCRIPTS_DIR)/installDev_nodejs.sh )

installDevC:
	@( $(SCRIPTS_DIR)/installDev_c.sh )

installPythonVirtualenv:
	@( $(SCRIPTS_DIR)/virenv_setup.sh )

changeDefaultShell:
	@( $(SCRIPTS_DIR)/change_defualt_to_zsh.sh )

updateCustomBins: prepare
	@( $(SCRIPTS_DIR)/update_custom_bins.sh )

updatePrezto:
	@( $(SCRIPTS_DIR)/update_prezto.sh )

updateDotfiles:
	@( $(SCRIPTS_DIR)/update_dotfiles.sh )

updateNeovimPlugins:
	@( $(SCRIPTS_DIR)/install_coc.sh )
	@( $(SCRIPTS_DIR)/update_neovim_plugins.sh )

updateTPM:
	@( $(SCRIPTS_DIR)/update_tpm.sh )

updateTmuxPlugins: updateTPM
	@( $(SCRIPTS_DIR)/update_tmux_plugins.sh )

clean:
	@echo "[0;92m[*][0m Remove dotfiles and configuration folders"
	@rm -rf $(TMP_DIR)
	@rm -rf ${HOME}/.zlogin ${HOME}/.zlogout ${HOME}/.zpreztorc ${HOME}/.zprofile \
		${HOME}/.zshenv ${HOME}/.zshrc ${HOME}/.zprezto \
		${HOME}/.fzf ${HOME}/.fzf.bash ${HOME}/.fzf.zsh \
		${HOME}/.gitignore \
		${HOME}/.grip ${HOME}/.pylintrc ${HOME}/.tmux ${HOME}/.tmux.conf \
		${HOME}/.vimrc ${HOME}/.vim \
		${HOME}/.config/nvim ${HOME}/.config/alacritty ${HOME}/.config/coc ${HOME}/.config/ranger
	@find ${HOME}/.local/bin -type l ! -exec test -e {}\; -print | xargs rm -rf
	@rm -rf $(PROJ_HOME)

update: prepare updateDotfiles updateNeovimPlugins updateTPM updateTmuxPlugins updateCustomBins updatePrezto
	@echo
	@echo "[42m[*] Update has Finished.[0m"

install: prepare installZsh changeDefaultShell installPrezto \
	installNeovim installTmux installBins
	@echo
	@echo "[42m[*] Install has Finished.[0m"

installDev: installDevNodejs installDevPython
	@echo
	@echo "[42m[*] InstallDev has Finished.[0m"

init: prepare install update installDev
	@echo
	@echo "[42m[*] Init has Finished.[0m"

.PHONY: prepare prerequisites prerequisitesTest \
	installZsh installPrezto installNeovim installTmux \
	installBins installDevShell installDevPython installDevNodejs installDevC installPythonVirtualenv changeDefaultShell \
	updateDotfiles updateNeovimPlugins updateTmuxPlugins updateTPM updateCustomBins updatePrezto \
	clean update install installDev init initOSX \

