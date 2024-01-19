#!/bin/bash

# https://docs.liquibase.com/commands/inspection/generate-changelog.html
liquibase generate-changelog --url jdbc:postgresql://127.0.0.1:5432/budgi --username=budgi --password=budgi --author=budgi --changelog-file=changelog.yml
