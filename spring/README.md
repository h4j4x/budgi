# Budgi API

TODO: Project description.

## Technology Stack

- [Java SDK 21](https://www.oracle.com/java/technologies/downloads/#java21).
- [SpringBoot 3.2.1](https://spring.io/projects/spring-boot/).
- [JWT](https://jwt.io/) using [jwtk-jjwt](https://github.com/jwtk/jjwt).
- [Postgres](https://www.postgresql.org/).

## Development

You can use [DevBox](https://www.jetpack.io/devbox/) for a portable dev environment.
Launch the shell to have Java 21 and Newman:
```shell
devbox shell
```

### Configuration

All configurations should be done in [.env file](./.env), create it if not exists.

- Generate secret key for token generation:
  ```shell
  openssl rand -base64 64 | paste --delimiters '' --serial
  ```
  Place generated value:
  ```properties
  TOKEN_SECRET=<YOUR_BASE_64_GENERATED_SECRET>
  ```
- Token expiration is seven (7) days by default, you can modify it:
  ```properties
  TOKEN_EXPIRATION_IN_DAYS=<YOUR_EXPIRATION_DAYS>
  ```
- Setup your database properties:
  ```properties
  DATASOURCE_URL=jdbc:postgresql://localhost:5432/budgi
  DATASOURCE_USERNAME=budgi
  DATASOURCE_PASSWORD=budgi
  DATASOURCE_DRIVER=org.postgresql.Driver
  DATASOURCE_DDL=create-drop
  ```

### Run server

- Start [Docker](https://www.docker.com/) postgres server using [Docker Compose](https://docs.docker.com/compose/):
  ```shell
  cd ./docker
  docker compose up -d
  ```
- Start server:
  ```shell
  ./gradlew bootRun
  ```

### Test API

- Install [Newman](https://learning.postman.com/docs/collections/using-newman-cli/installing-running-newman/) or [Postman CLI](https://learning.postman.com/docs/postman-cli/postman-cli-installation/).
- Run tests:
  ```shell
  newman run ./postman_collection.json
  # OR
  postman collection run ./postman_collection.json
  ```
