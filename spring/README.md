# Budg1 Spring API

Budg1 Spring project.

![Test](https://github.com/h4j4x/budgi/actions/workflows/spring-test.yml/badge.svg)

## Technology Stack

- [Java SDK 21](https://www.oracle.com/java/technologies/downloads/#java21).
- [SpringBoot 3.2.1](https://spring.io/projects/spring-boot/).
- [JWT](https://jwt.io/) using [jwtk-jjwt](https://github.com/jwtk/jjwt).
- [Postgres](https://www.postgresql.org/).
- [Liquibase](https://docs.liquibase.com/home.html).

## Development

### Technology Stack

- [H2](https://h2database.com/html/main.html).
- [Jib](https://github.com/GoogleContainerTools/jib).
- [Docker](https://www.docker.com/).
- [Postman](https://www.postman.com/).
- [Newman](https://github.com/postmanlabs/newman).

You can use [DevEnv](https://devenv.sh/) for a portable dev environment. Launch the shell to have Java 21 and Newman:
```shell
devenv shell
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
  ```

### Generate docker image

- Dockerize with [Jib](https://github.com/GoogleContainerTools/jib/tree/master/jib-gradle-plugin):
  ```shell
  ./gradlew jibDockerBuild
  ```

### Run server

#### Java

- Start [Docker](https://www.docker.com/) Postgres server using [Docker Compose](https://docs.docker.com/compose/):
  ```shell
  cd ./docker
  docker compose up -d
  ```
- Start server:
  ```shell
  ./gradlew bootRun
  ```

#### Docker

- Start [Docker](https://www.docker.com/) server using [Docker Compose](https://docs.docker.com/compose/):
  ```shell
  cd ./docker
  docker compose -f ./compose-app.yml up -d
  ```

---

Check status navigating to [health page](http://localhost:8080/manage/health).

### Integrations tests

- Install [Newman](https://learning.postman.com/docs/collections/using-newman-cli/installing-running-newman/) or [Postman CLI](https://learning.postman.com/docs/postman-cli/postman-cli-installation/).
- Run tests:
  ```shell
  newman run ./postman_collection.json
  # OR
  postman collection run ./postman_collection.json
  ```
