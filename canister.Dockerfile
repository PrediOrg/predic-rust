FROM biconomy/myconister
RUN apt -yq install netcat libunwind8 git psmisc
# RUN cargo install cargo-audit
ENV PATH="/root/.local/share/dfx/bin/:${PATH}"
RUN dfx identity new taro --storage-mode=plaintext || true
RUN dfx identity use taro
EXPOSE 4943