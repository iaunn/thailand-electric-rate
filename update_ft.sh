#!/bin/bash

# URL of the HTML page
url="https://www.pea.co.th/our-services/tariff/ft"
json_file="thailand_electric_rate.json"

# Fetch the HTML content (PEA blocks the default curl UA, so pretend to be a browser)
user_agent="Mozilla/5.0 (X11; Linux x86_64; rv:124.0) Gecko/20100101 Firefox/124.0"
html_content=$(curl -sSL \
  --retry 5 --retry-delay 5 --retry-all-errors \
  --connect-timeout 15 --max-time 60 \
  -A "$user_agent" \
  -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
  -H "Accept-Language: en-US,en;q=0.5" \
  "$url")
curl_exit=$?

if [ $curl_exit -ne 0 ] || [ -z "$html_content" ]; then
  echo "Failed to fetch $url (curl exit $curl_exit, bytes=${#html_content})."
  exit 1
fi

# Parse the number from the span with id "current-ft"
new_ft_value=$(printf '%s' "$html_content" | perl -0777 -ne 'print $1 if /<span[^>]*id="current-ft"[^>]*>([^<]+)/')

if [ -n "$new_ft_value" ]; then
  current_ft_value=$(jq -r '.ft' "$json_file")
  if [ "$current_ft_value" != "$new_ft_value" ]; then
    jq --arg newFt "$new_ft_value" '.ft = ($newFt | tonumber)' "$json_file" > tmp.json && mv tmp.json "$json_file"
    echo "The value of 'ft' in $json_file has been updated to: $new_ft_value"
  else
    echo "The value of 'ft' has not changed."
  fi
  exit 0
else
  echo "Failed to parse the value from the HTML."
  echo "Fetched ${#html_content} bytes. First 500 chars for debugging:"
  echo "${html_content:0:500}"
  exit 1
fi
