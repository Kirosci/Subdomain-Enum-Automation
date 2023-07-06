#!/bin/bash

echo -n "Paste the Domains here: "
read domains
mkdir $domains
clear

# Run commands simultaneously
(
  echo "$domains" | assetfinder | tee $domains/asset.txt
) &

(
  echo "$domains" | haktrails subdomains | tee $domains/haktrails.txt
) &

(
  echo "$domains" | subfinder -pc /home/kali/.config/subfinder/provider-config.yaml | tee $domains/subfinder.txt
) &

(
  amass enum -d "$domains" | tee $domains/amass.txt
) &


  python3 ../tools/knock/knockpy.py $domains | tee $domains/knockpy_full.txt
  cat $domains/knockpy_full.txt | awk '{print $5}' | tee $domains/knockpy_subsonly.txt &

# Wait for all background processes to finish
wait

echo "---------------Sorting...--------------------"
cat $domains/asset.txt $domains/haktrails.txt $domains/subfinder.txt $domains/amass.txt $domains/knockpy_subsonly.txt | sort -u | tee $domains/subdomains.txt

# Use "chmod 777 script.sh" to give it permissions for soomth run