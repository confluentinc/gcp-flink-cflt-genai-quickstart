#
# Copyright 2025 Confluent Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM confluentinc/cp-base-new:latest-ubi8

WORKDIR /build

ENV STREAMS_USER="streams"
ENV STREAMS_GROUP=$STREAMS_USER

####################################################################
# Replace with the proper values:
####################################################################
ENV FAT_JAR=kstreams-build-query-8.0.0-0-jar-with-dependencies.jar
ENV APP_CLASS=io.confluent.quickstart.BuildQuery
####################################################################

ENV LANG="C.UTF-8"

USER root

RUN groupadd $STREAMS_GROUP && useradd -r -g $STREAMS_GROUP $STREAMS_USER
RUN mkdir /app && chown $STREAMS_USER:$STREAMS_GROUP /app

COPY --chown=appuser:appuser target/$FAT_JAR /app/$FAT_JAR
COPY --chown=appuser:appuser launch.sh /app/launch.sh

USER $STREAMS_USER

EXPOSE 8080
CMD ["sh", "/app/launch.sh"]
