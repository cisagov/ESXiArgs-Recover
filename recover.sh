#!/usr/bin/env bash

if ! command -v vmkfstools; then
    echo -e "Not found command: \`vmkfstools\`"
    exit 1
fi

mkdir -p encrypted_files
echo -e "Moving encrypted $1.vmdk to encrypted_files"
mv -f "$1.vmdk" "encrypted_files/$1.vmdk.encrypted"
file_size=$(ls -la "$1-flat.vmdk" | awk '{print $5}')

echo -e "\nCreating copy of $1-flat.vmdk"
vmkfstools -c $file_size -d thin temp.vmdk
rm -f temp-flat.vmdk

echo -e "\nAdding $1.vmdk"
sed -i "s/temp-flat/${1}-flat/" temp.vmdk
if [ "$#" = 1 ] || [ $2 != "thin" ]; then
  sed -i '/ddb.thinProvisioned/d' temp.vmdk
fi
mv -f temp.vmdk "$1.vmdk"

echo -e "\nCopying $1.vmx"
mv -f "$1.vmx" "encrypted_files/$1.vmx.encrypted"

if ! cp -f "$1.vmx~" "$1.vmx"; then
    echo -e "Error: unable to find vmx backup. You may be unable to re-register the virtual machine."
    exit 1
fi

echo -e "\nMoving encrypted $1.vmsd to encrypted_files"
mv -f "$1.vmsd" "encrypted_files/$1.vmsd.encrypted"

echo -e "\nMoving encrypted $1.nvram to encrypted_files"
mv -f "$1.nvram" "encrypted_files/$1.nvram.encrypted"

echo -e "\n\nValidating..."
if ! vmkfstools -e "$1.vmdk"; then
    echo -e "\nError. Trying to update the file size."
    file_size_num=$(( file_size / 512 ))
    file_size_num_plus_one=$(( file_size_num + 1 ))
    sed -i "s/${file_size_num_plus_one}/${file_size_num}/" "$1.vmdk"
    if ! vmkfstools -e "$1.vmdk"; then
        echo -e "\nError. Could not recover. Please consult CISA's guidance for further information: https://www.cisa.gov/uscert/ncas/alerts/aa23-039a"
        exit 1
    fi
fi
echo -e "\nSuccess! Unregister the virtual machine and re-register it and you should be good to go.\n"
exit 0
