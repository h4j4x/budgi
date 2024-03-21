FROM ubuntu:noble

RUN apt update
RUN apt install -y curl git unzip xz-utils zip libglu1-mesa

RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="${PATH}:/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin"

RUN flutter channel stable
RUN flutter config --no-enable-android
RUN flutter config --no-enable-ios
RUN flutter config --enable-web
RUN flutter doctor -v

RUN mkdir /app/
COPY . /app/
WORKDIR /app/

RUN flutter pub get

EXPOSE 3000

CMD flutter run -d web-server --web-port=3000 --dart-define="DATA_PROVIDER=$DATA_PROVIDER" --dart-define="SPRING_URL=$SPRING_URL"
