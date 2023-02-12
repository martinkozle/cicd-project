FROM rust:1.67 as build

ARG SQLX_OFFLINE=true

# create a new empty shell project
RUN USER=root cargo new --bin app
WORKDIR /app

# copy over your manifests
COPY ./Cargo.toml ./Cargo.toml

# this build step will cache your dependencies
RUN cargo build --release
RUN rm src/*

# copy your source tree
COPY ./src ./src

# copy sqlx-data.json for offline build
COPY ./sqlx-data.json ./sqlx-data.json

# build for release
RUN rm ./target/release/deps/cicd_project*
RUN cargo build --release


FROM build as test

# run linter
RUN cargo clippy --all-targets --all-features -- -D warnings

# run tests
CMD ["cargo", "test" "--release"]


# our final base
FROM debian:buster-slim

# copy the build artifact from the build stage
COPY --from=build /app/target/release/cicd-project .

# set default environment variables
ENV RUST_BACKTRACE=1

# set the startup command to run your binary
CMD ["./cicd-project"]
