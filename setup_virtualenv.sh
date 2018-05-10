#!/bin/bash

set -e

VIRENV_NAME=venv

cd ~
virtualenv --system-site-package -p python3 ${VIRENV_NAME}
source ~/${VIRENV_NAME}/bin/activate

pip install --upgrade pip
pip install numpy scipy matplotlib ipython jupyter pandas sympy nose
pip install scikit-learn
pip install tqdm
pip install seaborn
pip install tabulate
pip install ipdb
# pip install paramiko

while true; do
    read -p "\nDo you wish to install gpu supporting tensorflow? " yn
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
