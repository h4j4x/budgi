# Budgi API

TODO: Project description.

## Technology Stack

- [Java SDK 21](https://www.oracle.com/java/technologies/downloads/#java21).
- [SpringBoot 3.2.1](https://spring.io/projects/spring-boot/).
- [JWT](https://jwt.io/) using [jwtk-jjwt](https://github.com/jwtk/jjwt).

## Configuration

All configurations should be done on [.env file](./.env), create it if not exists.

- Generate secret key for token generation:
  ```
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