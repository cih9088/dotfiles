#!/bin/bash

VIRENV_NAME=venv

cd ~
virtualenv -p python3 ${VIRENV_NAME}
source ~/${VIRENV_NAME}/bin/activate

pip install --upgrade pip
pip install numpy scipy matplotlib ipython jupyter pandas sympy nose
pip install scikit-learn
pip install tqdm
pip install seaborn
pip install tabulate
# pip install paramiko
pip install --upgrade tensorflow-gpu
