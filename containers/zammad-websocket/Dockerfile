FROM tamtsin/zammad-docker-compose:zammad
MAINTAINER Zammad <info@zammad.org>
ARG BUILD_DATE

ENV ZAMMAD_DIR /home/zammad
ENV RAILS_ENV production
ENV RAILS_SERVER puma
ENV GIT_URL https://github.com/zammad/zammad.git
ENV GIT_BRANCH stable

LABEL org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.name="Zammad" \
      org.label-schema.license="AGPL-3.0" \
      org.label-schema.description="Docker container for Zammad - Wenbscocket server" \
      org.label-schema.url="https://zammad.org" \
      org.label-schema.vcs-url="https://github.com/zammad/zammad" \
      org.label-schema.vcs-type="Git" \
      org.label-schema.vendor="Zammad" \
      org.label-schema.schema-version="1.2" \
      org.label-schema.docker.cmd="sysctl -w vm.max_map_count=262144;docker-compose up"

# Expose ports
EXPOSE 6042

# docker init
USER root
COPY containers/zammad-websocket/docker-entrypoint.sh /
RUN chown zammad:zammad /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh
USER zammad
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["zammad-websocket"]
