FROM rust:latest

# define timezone, in China
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# speedup apt-get, in China
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
RUN apt-get update && apt-get install -y build-essential git clang cmake libstdc++-10-dev libssl-dev libxxhash-dev zlib1g-dev

WORKDIR /tmp
RUN git clone https://github.com/rui314/mold.git
WORKDIR /tmp/mold
RUN git tag | tail -n 1 | git checkout
RUN make -j$(nproc) CXX=clang++ && make install

RUN echo '\ 
[target.x86_64-unknown-linux-gnu]\n\
linker = "clang"\n\
rustflags = ["-C", "link-arg=-fuse-ld=/usr/local/bin/mold"]\n\
\n\
[target.aarch64-unknown-linux-gnu]\n\
linker = "clang"\n\
rustflags = ["-C", "link-arg=-fuse-ld=/usr/local/bin/mold"]\n'\
> $CARGO_HOME/config.toml

WORKDIR /root

CMD ["/bin/bash"]
