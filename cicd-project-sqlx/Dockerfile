FROM rust:1.67 as build

RUN cargo install sqlx-cli --no-default-features --features native-tls,postgres


FROM debian:bullseye-slim

COPY --from=build /usr/local/cargo/bin/sqlx /usr/local/bin/sqlx
