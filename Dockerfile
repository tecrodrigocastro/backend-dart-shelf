FROM dart:2.17.6 AS build

WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

COPY . .

RUN dart pub get --offline
RUN dart compile exe bin/backend_shelf.dart -o bin/server


FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /

EXPOSE 4466
CMD ["/server"]