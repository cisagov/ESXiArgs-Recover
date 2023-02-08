# ESXiArgs-Recover

ESXiArgs-Recover is a tool to allow organizations to attempt recovery of virtual machines affected by the ESXiArgs ransomware attacks. 

CISA is aware that some organizations have reported success in recovering files without paying ransoms. CISA compiled this tool based on publicly available resources, including [a tutorial](http://enes.dev/) by Enes Sonmez and Ahmet Aykac. This tool works by reconstructing virtual machine metadata from virtual disks that were not encrypted by the malware. For more information, see CISA's [ESXiArgs Ransomware Virtual Machine Recovery Guidance](https://www.cisa.gov/uscert/ncas/alerts/aa23-039a).

## Disclaimer

CISA’s ESXiArgs script is based on findings published by the third-party researchers mentioned above. Any organization seeking to use CISA’s ESXiArgs recovery script should carefully review the script to determine if it is appropriate for their environment before deploying it. This script does not seek to delete the encrypted config files, but instead seeks to create new config files that enable access to the VMs. While CISA works to ensure that scripts like this one are safe and effective, this script is delivered without warranty, either implicit or explicit. Do not use this script without understanding how it may affect your system. CISA does not assume liability for damage caused by this script.

This script is being provided “as is” for informational purposes only. CISA does not endorse any commercial product or service, including any subjects of analysis. Any reference to specific commercial products, processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply endorsement, recommendation, or favoring by CISA.

## Usage

1. Download this script and save it as `/tmp/recover.sh`. For example, with wget: `wget -O /tmp/recover.sh https://raw.githubusercontent.com/cisagov/ESXiArgs-Recover/main/recover.sh`
2. Give the script execute permissions: `chmod +x /tmp/recover.sh`
3. Navigate to the folder of a virtual machine you would like to decrypt (you may browse these folders by running `ls /vmfs/volumes/datastore1`). For instance, if the folder is called `example`, run `cd /vmfs/volumes/datastore1/example`
4.	Run `ls` to view the files. Note the name of the VM (e.g. if there is a file `example.vmdk`, the name of the VM is `example`).
5.	Run the recovery script with `/tmp/recover.sh [name]`, where `[name]` is the name of the virtual machine determined in step 4. If the virtual machine is a thin format, run `/tmp/recover.sh [name] thin`.
6.	If successful, the decryptor script will output that it has successfully run. If unsuccessful, this may mean that your virtual machines cannot be recovered.
7.	If the script succeeded, the last step is to re-register the virtual machine.
8.	If the ESXi web interface is inaccessible, take the following steps to remove the ransom note and restore access (note that taking the steps below moves the ransom note to the file `ransom.html`. Cconsider archiving this file for future incident review).
    - Run `cd /usr/lib/vmware/hostd/docroot/ui/ && mv index.html ransom.html && mv index1.html index.html`
    - Run `cd /usr/lib/vmware/hostd/docroot && mv index.html ransom.html && rm index.html & mv index1.html index.html`
    - Reboot the ESXi server (e.g., with the `reboot` command). After a few minutes, you should be able to navigate to the web interface.
9.	In the ESXi web interface, navigate to the Virtual Machines page.
10.	If the VM you restored already exists, right click on the VM and select “Unregister”.
11.	Select “Create / Register VM”. 
12.	Select “Register an existing virtual machine”.
13.	 Click “Select one or more virtual machines, a datastore or a directory” to navigate to the folder of the VM you restored. Select the vmx file in the folder.
14.	Select “Next” and “Finish”. You should now be able to use the VM as normal.

If needed, the script will save encrypted files in a new `encrypted_files` folder within each virtual machine’s directory.

## Contributing

Contributions are always welcome! Navigate [here](https://github.com/cisagov/ESXiArgs-Recover/pulls) to submit a pull request or submit an issue [here](https://github.com/cisagov/ESXiArgs-Recover/issues/new).

## Public domain
This project is in the worldwide public domain.

This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the CC0 1.0 Universal public domain dedication.

All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
