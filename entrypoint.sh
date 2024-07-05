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
    echo "**** Running the /usr/local/bin/adlumin310edit.sh script ****"
    /usr/local/bin/adlumin310edit.sh
fi

# Start the Python script for the log forwarder in the background
exec python /usr/local/adlumin/adlumin_forwarder.py
