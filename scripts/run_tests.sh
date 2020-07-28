#!/bin/bash
docker-compose -f docker-compose.yml \
               -f docker-compose.dev.yml \
               run --rm quiet-logistics-integration \
               bundle exec rspec ${@}
