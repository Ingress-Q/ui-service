# Build stage
FROM public.ecr.aws/amazonlinux/amazonlinux:2023 AS build-env

RUN dnf --setopt=install_weak_deps=False install -q -y \
    maven java-21-amazon-corretto-headless \
    && dnf clean all

WORKDIR /build
COPY . .

RUN ./mvnw clean package -DskipTests -q \
    && cp target/*.jar app.jar


# Runtime stage
FROM public.ecr.aws/amazonlinux/amazonlinux:2023

RUN dnf --setopt=install_weak_deps=False install -q -y \
    java-21-amazon-corretto-headless shadow-utils \
    && dnf clean all

WORKDIR /app

COPY --from=build-env /build/app.jar /app/app.jar

ENTRYPOINT ["java","-jar","/app/app.jar"]