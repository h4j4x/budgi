# Budgi API

## Configuration

- Generate secret key for jwt token generation:
```
openssl rand -base64 64 | paste --delimiters '' --serial
```