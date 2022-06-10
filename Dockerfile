FROM jupyter/scipy-notebook:66c99628f4b8 

USER root

RUN apt-get update

RUN apt-get install -y mono-devel

#COPY ./pabc_kernel /pascal_kernel
#COPY ./PABCNETC /pabc
RUN mkdir -p /pascal_kernel && mkdir -p /pabc

WORKDIR /pascal_kernel
RUN wget -nv http://pascalabc.net/downloads/pabc_kernel_master.zip && \
    unzip pabc_kernel_master.zip && \
    mv pabc_kernel_master/* . && rm -rf pabc_kernel_master

WORKDIR /pabc
RUN wget -nv http://pascalabc.net/downloads/PABCNETC.zip && \
    unzip PABCNETC.zip

ENV PATH="/pabc:${PATH}"

RUN DST="        args = \['mono', r'\/pabc\/pabcnetcclear\.exe', source_filename]" \
    bash -c 'sed -i "s/^        args = \[.*$/$DST/" /pascal_kernel/pabc_kernel/kernel.py'

RUN DST="                p = self\.create_jupyter_subprocess(\['mono', exe_name\])" \
    bash -c 'sed -i "s/^                p = self\.create_jupyter_subprocess.*$/$DST/" /pascal_kernel/pabc_kernel/kernel.py'

RUN cd /pascal_kernel && python setup.py install && python -m pabc_kernel.install

RUN ls -al /home/jovyan/

WORKDIR /JupyterPABC_kernel
RUN wget -nv https://yunohost.corvato.ru/nextcloud/s/nEZw2oRzDT9cMcc/download/JPABC.zip && \
    unzip JPABC.zip

USER jovyan

RUN cd /JupyterPABC_kernel && jupyter kernelspec install --user kernel-spec --name=pabc_release

WORKDIR /home/jovyan/work

#USER jovyan
