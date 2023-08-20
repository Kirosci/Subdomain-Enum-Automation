#!/bin/bash

read -p "Enter domain name: " domain
dir=$domain
if [ -d $domain ]; then
read -p "Enter directory name to save results in: " dir
mkdir $dir
echo "All results will be saved in" "$dir/" "directory."
else
mkdir $dir
echo "All results will be saved in" "$dir/" "directory."
fi

(
  echo "$domain" | assetfinder | tee $dir/assetfinder_subdomains.txt
) &

(
  echo "$domain" | haktrails subdomains | tee $dir/haktrails_subdomains.txt
) &

(
  echo "$domain" | subfinder | tee $dir/subfinder_subdomains.txt
) &

(
  amass enum -d "$domain" | tee $dir/amass_subdomains.txt
) &


python3 tools/knock/knockpy.py $domain | tee $dir/knockpy_full.txt
cat $dir/knockpy_full.txt | awk '{print $5}' | tee $dir/knockpy_subdomains.txt &

wait

cat $dir/assetfinder_subdomains.txt $dir/haktrails_subdomains.txt $dir/subfinder_subdomains.txt $dir/amass_subdomains.txt $dir/knockpy_subdomains.txt | sort -u | tee $dir/all_assets.txt &


#----------------------------Assets_Sorting_Done-----------------------------------------


wait

cat $dir/all_assets.txt | grep $domain | awk '{print$1}' | sort -u | tee $dir/subdomains.txt &


#---------------------------Subdomain_Main_Done--------------------------------------------


wait

cat $dir/subdomains.txt | httpx | tee $dir/live_subdomains.txt &


#-----------------------------Live_Domains_Done---------------------------------------------


wait

(
cat $dir/live_subdomains.txt | waybackurls | tee $dir/wayback_urls.txt
) &

(
cat $dir/live_subdomains.txt | gau | tee $dir/gau_urls.txt 
) &

wait

cat $dir/wayback_urls.txt $dir/gau_urls.txt | sort -u |tee $dir/urls.txt &


#-------------------------------------URLs_Done------------------------------------------------


wait

mkdir $dir/deep

mv $dir/assetfinder_subdomains.txt $dir/haktrails_subdomains.txt $dir/subfinder_subdomains.txt $dir/amass_subdomains.txt $dir/knockpy_full.txt $dir/knockpy_subdomains.txt $dir/gau_urls.txt $dir/wayback_urls.txt $dir/all_assets.txt $dir/deep/


#-----------------------------------------Organizing_Done---------------------------------------


clear

echo "Mission Completed Respect+"

tree $dir


# Use "chmod 777 script.sh" to give it permissions for soomth run
# Need to add subdomains takeover check
