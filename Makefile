scripts = ./script

prerequisites:
	( ${scripts}/prerequisites.sh )

installZsh:
	( ${scripts}/zsh_setup.sh )

installPrezto:
	( ${scripts}/prezto_setup.sh )

installNeovim:
	( ${scripts}/nvim_setup.sh )

installTmux:
	( ${scripts}/tmux_setsup.sh )
	# install tpm
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

installBins:
	( ${scripts}/bin_setup.sh )

installDevShell:
	( ${scripts}/shell_setup.sh )

installDevPython:
	pip install glances --user
	pip install grip --user
	pip install gpustat --user
	pip install ipdb --user
	pip install pudb --user
	pip install pylint --user
	pip install jedi --user
	pip install virtualenv --user || true
	pip install virtualenvwrapper --user || true
	pip3 install virtualenv --user || true
	pip3 install virtualenvwrapper --user || true

installPythonVirtualenv:
	( ${scripts}/virenv_setup.sh )

changeDefaultShell:
	( ${scripts}/change_defualtshell_zsh.sh )

updateDotfiles:
	( ${scripts}/dot_setup.sh )

updateNeovimPlugins:
	nvim +PlugInstall +PlugUpdate +PlugUpgrade +UpdateRemotePlugins +qall

updateTmuxPlugins:
	~/.tmux/plugins/tpm/scripts/install_plugins.sh

clean:
	rm -rf ${HOME}/tmp_install

updateAll: updateDotfiles updateNeovimPlugins updateTmuxPlugins

installAll: installZsh installPrezto changeDefaultShell updateDotfiles installNeovim installTmux \
	installBins updateNeovimPlugins updateTmuxPlugins clean

installDevAll: installDevPython installDevShell

