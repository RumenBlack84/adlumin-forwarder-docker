#!/bin/bash

# Log file location
LOGFILE="/usr/local/adlumin/adlumin_forwarder.log"

echo "**** Configuring /usr/local/adlumin/adlumin_config.txt with tenant id and office365 token if provided ****"
cat <<EOF > /usr/local/adlumin/adlumin_config.txt
# Enter the Tenant ID provided to you by Adlumin

TENANT_ID = ${TENANT_ID}

OFFICE365_TOKEN = ${OFFICE365_TOKEN}

ENDPOINT1 = https://master-ingest-1.securityeco.com
EOF

echo "**** Configuring /usr/local/adlumin/sophos_config.txt with api token if provided ****"
echo "${SOPHOS_API}" > /usr/local/adlumin/sophos_config.txt

# Debugging: Check if the script exists and has execute permissions
if [ -f /usr/local/bin/adlumin310edit.sh ]; then
    echo "adlumin310edit.sh exists"
else
    echo "adlumin310edit.sh does not exist"
fi

if [ -x /usr/local/bin/adlumin310edit.sh ]; then
    echo "adlumin310edit.sh is executable"
else
    echo "adlumin310edit.sh is not executable"
fi


# Check if the variable RUN_EDIT_SCRIPT is set to "yes" (case-insensitive)
if [ "$(echo "${RUN_EDIT_SCRIPT}" | tr '[:upper:]' '[:lower:]')" = "yes" ]; then
    echo "###########################################################################################"
    echo "This is an unsupported workaround to enable python 3.10 instead of 3.6 USE AT YOUR OWN RISK"
    echo "###########################################################################################"

    #Set filepath to updater.py
    file_path="/usr/local/adlumin/updater.py"

    # Check if the file is executable
    if [[ -x "$file_path" ]]; then
        echo "The file '$file_path' is already executable."
    else
        echo "The file '$file_path' is not executable or does not exist."
        echo "Attempting to show '$file_path' permissions"
        ls -lh $(file_path)
        chmod +x $(file_path)
    fi

    # Verify the variables are set
    echo "S3_AKEY = $S3_AKEY"
    echo "S3_SKEY = $S3_SKEY"

    #Updating the update script to use python 3.10 instead of 3.6 this script does not need any refactoring to work properly
    # Read the first line of the file
    first_line=$(head -n 1 "$file_path")
    # Check if the first line is the shebang line
    if [ "$first_line" != "#!/usr/bin/env python3.10" ]; then
    # Insert the shebang line at the beginning of the file
        (echo "#!/usr/bin/env python3.10"; cat "$file_path") > temp_file && mv temp_file "$file_path"
    fi

    echo "Running the Adlumin Script Updater"
    /usr/local/adlumin/updater.py
    echo "The Adlumin Script Updater has exited, please read above to ensure it was successfull"

    echo "Changing the script to use python 3.10 instead of 3.6"
    sed -i '1s|python3.6|python3.10|' /usr/local/adlumin/adlumin_forwarder.py

    echo 'Correcting "import zstd" to "import zstandard as zstd" instead to avoid issues with running under python3.10'
    sed -i 's|import zstd|import zstandard as zstd|' /usr/local/adlumin/adlumin_forwarder.py

    echo 'Commenting out the update function of the script so it does not get overwritten'
    sed -i '/updater = threading.Thread(target=update/,+1 s/^/#/' /usr/local/adlumin/adlumin_forwarder.py
fi

# Start the Python script for the log forwarder in the background
exec python /usr/local/adlumin/adlumin_forwarder.py
# If script doesn't launch cat the log file
cat /usr/local/adlumin/adlumin_forwarder.log
