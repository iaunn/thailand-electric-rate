#!/bin/bash

# URL of the HTML page
url="https://www.pea.co.th/our-services/tariff/ft"
json_file="thailand_electric_rate.json"

# Fetch the HTML content
html_content=$(curl -s "$url")

# Parse the number from the span with id "currentFt"
new_ft_value=$(echo "$html_content" | grep -oP '<span[^>]*id="current-ft"[^>]*>\K[^<]+')

if [ -n "$new_ft_value" ]; then
  current_ft_value=$(jq -r '.ft' "$json_file")
  if [ "$current_ft_value" != "$new_ft_value" ]; then
    jq --arg newFt "$new_ft_value" '.ft = ($newFt | tonumber)' "$json_file" > tmp.json && mv tmp.json "$json_file"
    echo "The value of 'ft' in $json_file has been updated to: $new_ft_value"
    exit 0
  else
    echo "The value of 'ft' has not changed."
    exit 1
  fi
else
  echo "Failed to parse the value from the HTML."
  exit 1
fi