#!/bin/bash

set -e

VIRENV_NAME=venv

export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=$(which python3)
# export VIRTUALENVWRAPPER_VIRTUALENV_ARGS='--system-site-packages'
export VIRTUALENVWRAPPER_VIRTUALENV_ARGS='--no-site-packages'
source $(which virtualenvwrapper.sh)
mkvirtualenv -p `which python3` ${VIRENV_NAME} || true

# cd ~
# virtualenv --system-site-package -p python3 ${VIRENV_NAME}
# source ~/${VIRENV_NAME}/bin/activate

# pip install --upgrade pip
pip install --no-cache-dir numpy scipy matplotlib ipython jupyter pandas sympy nose
pip install --no-cache-dir scikit-learn
pip install --no-cache-dir tqdm
pip install --no-cache-dir seaborn
pip install --no-cache-dir tabulate
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
