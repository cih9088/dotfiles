#!/bin/bash

set -e

VIRENV_NAME=venv

pip install gpustat --user
pip install ipdb --user
pip install pylint --user
pip install jedi --user

pip install virtualenv --user
pip install virtualenvwrapper --user
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/working
export VIRTUALENVWRAPPER_PYTHON=`which python3`
export VIRTUALENVWRAPPER_VIRTUALENV_ARGS='--system-site-packages'
source $HOME/.local/bin/virtualenvwrapper.sh
mkvirtualenv -p `which python3` ${VIRENV_NAME} || true

# cd ~
# virtualenv --system-site-package -p python3 ${VIRENV_NAME}
# source ~/${VIRENV_NAME}/bin/activate

pip install --upgrade pip
pip install numpy scipy matplotlib ipython jupyter pandas sympy nose
pip install scikit-learn
pip install tqdm
pip install seaborn
pip install tabulate
# pip install paramiko

while true; do
    echo
    read -p "[?] Do you wish to install gpu supporting tensorflow? " yn
    case $yn in
        [Yy]* )
            echo "[*] installing tensorflow with gpu support..."
            pip install --upgrade tensorflow-gpu
            break;;
        [Nn]* )
            echo "[!] installing tensorflow with gpu support ...";
            pip install --upgrade tensorflow
            break;;
        * ) echo "Please answer yes or no.";;
    esac
done
