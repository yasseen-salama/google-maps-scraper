#!/bin/bash
echo "--- Docker PS ---" > debug_output.txt
docker ps -a >> debug_output.txt 2>&1
echo "--- Docker Logs ---" >> debug_output.txt
docker compose -f docker-compose.staging.yaml logs >> debug_output.txt 2>&1
echo "--- Curl Health ---" >> debug_output.txt
curl -v http://localhost:8080/health >> debug_output.txt 2>&1
echo "--- Done ---" >> debug_output.txt
