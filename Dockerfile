FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV CONDA_DIR=/opt/conda
ENV NOTEBOOK_ENV_NAME=notebook
ENV PATH=${CONDA_DIR}/envs/${NOTEBOOK_ENV_NAME}/bin:${CONDA_DIR}/bin:${PATH}

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    git \
    bzip2 \
    ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /tmp/miniforge.sh \
    https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-$(uname -m).sh && \
    bash /tmp/miniforge.sh -b -p ${CONDA_DIR} && \
    rm /tmp/miniforge.sh && \
    (conda config --system --remove-key channels || true) && \
    conda config --system --append channels conda-forge && \
    conda config --system --append channels defaults && \
    conda config --system --set channel_priority strict && \
    conda create -y -n ${NOTEBOOK_ENV_NAME} \
    python=3.12 \
    numpy \
    matplotlib \
    jupyter \
    ipykernel && \
    conda run -n ${NOTEBOOK_ENV_NAME} pip install --no-cache-dir jupyterquiz && \
    conda run -n ${NOTEBOOK_ENV_NAME} python -m ipykernel install \
    --sys-prefix \
    --name ${NOTEBOOK_ENV_NAME} \
    --display-name "Python (${NOTEBOOK_ENV_NAME})" && \
    conda clean -afy && \
    ln -s ${CONDA_DIR}/envs/${NOTEBOOK_ENV_NAME}/bin/python /usr/local/bin/python
