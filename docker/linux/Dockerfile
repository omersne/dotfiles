ARG BASE_IMAGE
FROM $BASE_IMAGE
ARG DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_FRONTEND=noninteractive

ARG INT_TMP
COPY $INT_TMP /tmp/build
RUN chmod +x /tmp/build/prerequisites.sh
RUN /tmp/build/prerequisites.sh

COPY docker_startup.sh /docker_startup.sh

ENV SHELL /usr/bin/zsh
ENV TERM xterm-256color
WORKDIR /root
ENTRYPOINT ["/docker_startup.sh"]
CMD ["zsh"]
