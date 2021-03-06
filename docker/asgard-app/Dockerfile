FROM navitia/asgard-build-deps:latest as builder

RUN wget --progress=bar:force:noscroll https://github.com/CanalTP/asgard-query/releases/download/v1.0.0/asgard-query

RUN git clone --depth=1 https://github.com/canaltp/asgard asgard

WORKDIR /asgard
RUN sed -i 's,git\@github.com:\([^/]*\)/\(.*\).git,https://github.com/\1/\2,' .gitmodules && git submodule update --init --recursive \
  && mkdir build && cd build \
  && cmake -DCMAKE_BUILD_TYPE=Release .. && make -j$(nproc)

FROM debian:9
# We have to create a group and a user with the same gid and uid than the docker-data
RUN groupadd -g 1234 -r asgard-user && useradd --no-log-init -r -g asgard-user -u 1234 asgard-user
COPY --from=builder /asgard-query /usr/bin/asgard-query
RUN chmod +x /usr/bin/asgard-query
USER asgard-user
COPY --from=builder /asgard/build/asgard/asgard /usr/bin/asgard
COPY --from=builder /usr/lib/ /usr/lib/
COPY --from=builder /lib/ /lib/
EXPOSE 6000 8080
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
CMD /data/valhalla/healthcheck.sh || exit 1

ENTRYPOINT ["/usr/bin/asgard"]
