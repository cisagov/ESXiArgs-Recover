mkdir encrypted_files

echo -e "Moving encrypted $1.vmdk to encrypted_files"
mv "$1.vmdk" "encrypted_files/$1.vmdk.encrypted"
file_size=$(ls -la "$1-flat.vmdk" | awk '{print $5}')

echo -e "\nCreating copy of $1-flat.vmdk"
vmkfstools -c $file_size -d thin temp.vmdk
rm temp-flat.vmdk

echo -e "\nAdding $1.vmdk"
sed -i "s/temp-flat/${1}-flat/" temp.vmdk
if [ "$#" = 1 ] || [ $2 != "thin" ]; then
  sed -i '/ddb.thinProvisioned/d' temp.vmdk
fi
mv temp.vmdk "$1.vmdk"

echo -e "\nCopying $1.vmx"
mv "$1.vmx" "encrypted_files/$1.vmx.encrypted"
cp "$1.vmx~" "$1.vmx"

retVal=$?
if [ $retVal -ne 0 ]; then
    echo -e "Error: unable to find vmx backup. You may be unable to re-register the virtual machine."
fi

echo -e "\nMoving encrypted $1.vmsd to encrypted_files"
mv "$1.vmsd" "encrypted_files/$1.vmsd.encrypted"

echo -e "\nMoving encrypted $1.nvram to encrypted_files"
mv "$1.nvram" "encrypted_files/$1.nvram.encrypted"

echo -e ""

echo -e "\nValidating..."
vmkfstools -e "$1.vmdk"

retVal=$?
if [ $retVal -ne 0 ]; then
    echo -e "\nError. Trying to update the file size."
    file_size_num=$(( file_size / 512 ))
    file_size_num_plus_one=$(( file_size_num + 1 ))
    sed -i "s/${file_size_num_plus_one}/${file_size_num}/" "$1.vmdk"
    vmkfstools -e "$1.vmdk"
    retVal=$?
    if [ $retVal -ne 0 ]; then
        echo -e "\nError. Could not recover. Please consult CISA's guidance for further information: https://www.cisa.gov/uscert/ncas/alerts/aa23-039a"
    else
        echo -e "\nSuccess! Unregister the virtual machine and re-register it and you should be good to go.\n"
    fi
else
    echo -e "\nSuccess! Unregister the virtual machine and re-register it and you should be good to go.\n"
fi
exit $retVal
