#!/bin/bash
docker-compose run --rm quiet-logistics-integration \
               bundle exec rspec ${@}
