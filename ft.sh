#!/bin/bash

# URL of the HTML page
url="https://www.pea.co.th/%E0%B8%84%E0%B8%A7%E0%B8%B2%E0%B8%A1%E0%B8%A3%E0%B8%B9%E0%B9%89%E0%B9%80%E0%B8%81%E0%B8%B5%E0%B9%88%E0%B8%A2%E0%B8%A7%E0%B8%81%E0%B8%B1%E0%B8%9A%E0%B9%84%E0%B8%9F%E0%B8%9F%E0%B9%89%E0%B8%B2/%E0%B8%84%E0%B9%88%E0%B8%B2FT"
json_file="thailand_electric_rate.json"

# Fetch the HTML content
html_content=$(curl -s "$url")

# Parse the number from the span with id "currentFt"
new_ft_value=$(echo "$html_content" | grep -oP '<span[^>]*id="currentFt"[^>]*>\K[^<]+')

if [ -n "$new_ft_value" ]; then
  jq --arg newFt "$new_ft_value" '.ft = ($newFt | tonumber)' "$json_file" > tmp.json && mv tmp.json "$json_file"
  echo "The value of 'ft' in $json_file has been updated to: $new_ft_value"
else
  echo "Failed to parse the value from the HTML."
fi
