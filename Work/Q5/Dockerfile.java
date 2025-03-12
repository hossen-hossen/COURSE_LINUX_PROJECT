FROM openjdk:11-jdk-slim

# Install needed libraries for text/font rendering
RUN apt-get update && apt-get install -y \
  libfreetype6 \
  fontconfig \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Watermark.java .
RUN javac Watermark.java

ENTRYPOINT ["java", "Watermark"]
