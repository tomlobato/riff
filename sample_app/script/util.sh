#!/bin/bash

# exit

curl -v -XPOST -H 'Content-Type: application/json' -d '{"username": "tom", "password": "asd123"}' http://localhost:3000/session/login

token='eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCem9NZFhObGNsOXBaR2tHT2hsaGRYUm9aVzUwYVdOaGRHbHZibDkwYjJ0bGJra2lWVFl5TlRSbE5qVTFNalExWXpWaE5EazRNek5qT1RZNFl6VTFaVGt5WkRJeFptVTRPV0UwT0RJellUWTJNVEExWVRkbE5qVTRNemt5TWpJNU9HRXlaRGM0WkRjM056UXpOekl5WXpnM1lUZGlCam9HUlZRPSIsImV4cCI6IjIwMjMtMDMtMDFUMTM6NTU6MjFaIiwicHVyIjoiYWNjZXNzX3Rva2VuIn19--8869892e408ce80a1a9f9c4631fb58a98bd9a86571a2d504477ac5f802ba32bc2759299d5655b64c4c52efbb9fd58b7be4b2d64cda7c68ef037f3117cf990184'

curl -v -XPOST -H 'Content-Type: application/json' -H "Authorization: $token" http://localhost:3000/session/refresh

# curl -v -XGET -H 'Content-Type: application/json' -H "Authorization: $token" http://localhost:3000/actions/posts

# curl -v -XPOST -H 'Content-Type: application/json' -d '{}' http://localhost:3000/actions/users
# curl -v http://localhost:3000/actions/posts
# RACK_ENV=development bundle exec rake db:migrate
# RACK_ENV=test bundle exec rake db:migrate
