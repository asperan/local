# LoCAl is a simple Certificate Authority bot.
# Copyright (C) 2023  Alex Speranza

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

ARG RUBY_VERSION
FROM ruby:${RUBY_VERSION}-slim AS build

RUN apt-get update \
 && apt-get install -y --no-install-recommends make gcc git \
 && apt-get autoclean \
 && rm -rf /var/lib/apt/lists/*

RUN gem install gem-compiler

RUN mkdir -p /native-gems

RUN git clone --branch "v2.6.3" --single-branch "https://github.com/flori/json.git" /native-gems/json
WORKDIR /native-gems/json
RUN gem build json.gemspec \
 && gem compile json-2.6.3.gem

RUN git clone --branch "v3.0.4" --single-branch "https://github.com/ruby/stringio.git" /native-gems/stringio
WORKDIR /native-gems/stringio
RUN gem build stringio.gemspec \
 && gem compile stringio-3.0.4.gem

RUN git clone --branch "v5.0.1" --single-branch "https://github.com/ruby/psych.git" /native-gems/psych
WORKDIR /native-gems/psych
RUN gem build psych.gemspec \
 && gem compile psych-5.0.1.gem

FROM ruby:${RUBY_VERSION}-slim AS app
# RUN export PLATFORM="-$(uname -m)-$(uname -s | tr 'A-Z' 'a-z')"

COPY ./ /app
COPY --from=build /native-gems/json/json-2.6.3-x86_64-linux.gem /app/vendor/cache/
COPY --from=build /native-gems/stringio/stringio-3.0.4-x86_64-linux.gem /app/vendor/cache/
COPY --from=build /native-gems/psych/psych-5.0.1-x86_64-linux.gem /app/vendor/cache/

WORKDIR /app

RUN bundle install --prefer-local

CMD [ "./exe/local" ]
