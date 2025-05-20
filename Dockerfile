FROM --platform=linux/amd64 amazoncorretto:17-alpine AS builder

WORKDIR /app

COPY gradlew build.gradle settings.gradle ./
COPY gradle ./gradle

RUN ./gradlew build --no-daemon -x test || true

COPY src ./src

RUN chmod +x ./gradlew && ./gradlew clean build --no-daemon -x test

FROM --platform=linux/amd64 amazoncorretto:17-alpine


WORKDIR /app

RUN apk add --no-cache libstdc++
RUN apk add --no-cache tzdata \
    && cp /usr/share/zoneinfo/Asia/Seoul /etc/localtime \
    && echo "Asia/Seoul" > /etc/timezone

ENV TZ=Asia/Seoul

COPY --from=builder /app/build/libs/test-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]