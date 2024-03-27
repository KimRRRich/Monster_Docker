FROM ubuntu

RUN apt-get update -y && DEBIAN_FRONTEND="noninteractive" apt-get -y install cmake git python3 curl unzip xz-utils

COPY emsdk /opt/emsdk
RUN cd /opt&& cd emsdk && \
    ./emsdk install latest && ./emsdk activate latest

COPY third_party /app/third_party

COPY data /app/data
COPY src /app/src
RUN /bin/bash -c "source "/opt/emsdk/emsdk_env.sh" && \
    cd /app/src && \
    mkdir -p build/Release && cd build/Release && \
    cmake ../../. -D CMAKE_C_COMPILER=emcc -D CMAKE_CXX_COMPILER=em++ -D CMAKE_BUILD_TYPE=Release && \
    make"

WORKDIR /app/src/build/Release

RUN mkdir includes && cd includes && \
    cp -r ../../../ui/* . && \
    cp -r ../../../ui/imgs . &&\
    cp ../../../../third_party/FileSaver/FileSaver.js . && \
    cp ../../../../third_party/emscripten-ui/module.js .

EXPOSE 8000

ENTRYPOINT [ "python3" ]
CMD [ "-m", "http.server", "8000" ]
