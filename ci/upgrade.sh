#!/bin/sh

git pull && docker compose down && docker compose pull && docker compose up
