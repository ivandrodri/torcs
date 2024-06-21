#-------------- Base Image -------------------
FROM python:3.11-slim as BASE

ARG CODE_DIR=/tmp/code
ARG POETRY_VERSION=1.6.1

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1 \
    POETRY_VERSION=$POETRY_VERSION \
    POETRY_HOME="/opt/poetry" \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    CODE_DIR=$CODE_DIR

ENV PATH="${POETRY_HOME}/bin:$PATH"

# ToDo: Delete unnecessary dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl make \
    pandoc git-lfs rsync ffmpeg  make g++ gdb\
    x11-xserver-utils patchelf libglew-dev  \
    libglib2.0-dev libgl1-mesa-dev libglu1-mesa-dev freeglut3-dev  \
    libplib-dev libopenal-dev libalut-dev libxi-dev libxmu-dev libosmesa6-dev \
    libxrender-dev libxrandr-dev libpng-dev libxxf86vm-dev libvorbis-dev xautomation\
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://install.python-poetry.org | python -

WORKDIR $CODE_DIR

COPY poetry.lock pyproject.toml ./

RUN poetry install --no-interaction --no-ansi --no-root --only main
RUN poetry install --no-interaction --no-ansi --no-root --with add1
RUN poetry install --no-interaction --no-ansi --no-root --with add2

COPY  src/ src/
COPY  README.md .

WORKDIR "$CODE_DIR"/src/torcs
ENV CFLAGS="-fPIC"
ENV CPPFLAGS=$CFLAGS
ENV CXXFLAGS=$CFLAGS
RUN make clean
RUN rm -rf BUILD
RUN ./configure --prefix=$(pwd)/BUILD
RUN make
RUN make install
RUN make datainstall

RUN poetry build

VOLUME "$CODE_DIR"/src/torcs/BUILD

#-------------- Main Image -------------------
FROM python:3.11-slim as MAIN

ARG CODE_DIR=/tmp/code

ENV DEBIAN_FRONTEND=noninteractive\
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1 \
    POETRY_HOME="/opt/poetry" \
    CODE_DIR=$CODE_DIR

ENV PATH="${CODE_DIR}/.venv/bin:$PATH"
ENV PATH="${CODE_DIR}/src/torcs/BUILD/bin:$PATH"

# pandoc needed for docs, see https://nbsphinx.readthedocs.io/en/0.7.1/installation.html?highlight=pandoc#pandoc
# gh-pages action uses rsync
# opengl and ffmpeg needed for rendering envs. These packages are needed for torcs and mujoco.

RUN touch ~/.Xauthority

WORKDIR ${CODE_DIR}

# ToDo: Delete unnecessary dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    x11-xserver-utils patchelf libglew-dev  \
    libglib2.0-dev libgl1-mesa-dev libglu1-mesa-dev freeglut3-dev  \
    libplib-dev libopenal-dev libalut-dev libxi-dev libxmu-dev libosmesa6-dev \
    libxrender-dev libxrandr-dev libpng-dev libxxf86vm-dev libvorbis-dev xautomation\
    && rm -rf /var/lib/apt/lists/*

#RUN curl -sSL https://install.python-poetry.org | python -

COPY --from=BASE ${CODE_DIR}/.venv ${CODE_DIR}/.venv
COPY --from=BASE ${CODE_DIR}/dist ${CODE_DIR}/dist
COPY --from=BASE ${CODE_DIR}/src/torcs/BUILD ${CODE_DIR}/src/torcs/BUILD

VOLUME "$CODE_DIR"/src/torcs/BUILD

WORKDIR "${HOME}"

COPY  . $CODE_DIR

# Ensure Poetry is available
ENV PATH="${POETRY_HOME}/bin:$PATH"
COPY --from=BASE ${POETRY_HOME} ${POETRY_HOME}

RUN curl -sSL https://install.python-poetry.org | python -
#RUN python poetry_install.py
RUN poetry install --no-interaction --no-ansi --no-root --only main
RUN poetry install --no-interaction --no-ansi --no-root --with add1
RUN poetry install --no-interaction --no-ansi --no-root --with add2
