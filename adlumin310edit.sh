#!/bin/bash
# This is an unsupported workaround please use at your own risk.
# This is an unsupported workaround please use at your own risk.
# This is an unsupported workaround please use at your own risk.
# Usage: 
# Ensure you've already put your tenantid into the adlumin_config.txt on the desktop of the system
# just run the script as the adlumin user there are no switches or other considerations
#
# Written by Brian Grant
# brian.grant@n-able.com
# 
# The purpose of this script is to act as an refactor and update script 
# for the adlumin_forwarder.py script so that it can run properly under 
# python 3.10 which is supported until October 2026, it seemed like the
# logical choice as the version of Ubuntu the log forwarder images are 
# using by default right now is 22.04 LTS which comes with 3.10 as its
# preinstalled version of python3
#
# As for the edits to adlumin_forwarder.py to get it working with python
# 3.10 they were relatively minor. At the top of the script there is a 
# shebang that is setting the script to run as 3.6 that is being changed
# to 3.10. Further more there were issues importing the zstd module in
# 3.10 so it's line was changed from "import ztd" to "import zstandard as ztd".
# Lastly I am commenting out the updater function in the script as this was 
# causing some issues overwriting the file and making the service fail to start.
# Just for good measure I'm using chattr to make the file immutable once changed
# so that nothing on the system can change it.
#
# This of course raises the problem that the script can no longer be updated.
# I've set this script to first unlock the adlumin_forwarder.py script and then
# run the updater.py script to update it. From there re-edits the forwarder script
# with sed to include the above edits and relocks the file.
#
# The updater.py script is also being updated. Normally the updater script pulls it's 
#creds from the session variables set in .bashrc of the adlumin user. This does not 
# translate well to scripting or automation such as ansible so we are editing that script
# to plug in the values from the bashrc directly to the updater script rather than have 
# to pull them from the environment variables. The updater script itself is alot being
# set to use python 3.10
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

# Define the Python script file to update
PYTHON_SCRIPT="/usr/local/adlumin/updater.py"

# Verify the variables are set
echo "S3_AKEY = $S3_AKEY"
echo "S3_SKEY = $S3_SKEY"

# Escape variables for sed
ESCAPED_S3_AKEY=$(printf '%s\n' "$S3_AKEY" | sed -e 's/[\/&]/\\&/g')
ESCAPED_S3_SKEY=$(printf '%s\n' "$S3_SKEY" | sed -e 's/[\/&]/\\&/g')

# Use sed to replace the lines in the Python script
sed -i.bak -e "s/aws_access_key_id=os.environ.get('S3_AKEY')/aws_access_key_id='$ESCAPED_S3_AKEY'/" "$PYTHON_SCRIPT"
sed -i -e "s/aws_secret_access_key=os.environ.get('S3_SKEY')/aws_secret_access_key='$ESCAPED_S3_SKEY'/" "$PYTHON_SCRIPT"

#Updating script to use python 3.10 instead of 3.6 this script does not need any refactoring to work properly
sed -i '1s|python3.6|python3.10|' /usr/local/adlumin/adlumin_forwarder.py

# Advise of changes 
echo "Updated $PYTHON_SCRIPT with new AWS credentials."

echo "Running the Adlumin Script Updater"
/usr/local/adlumin/updater.py
echo "The Adlumin Script Updater has exited, please read above to ensure it was successfull"

echo "Changing the script to use python 3.10 instead of 3.6"
sed -i '1s|python3.6|python3.10|' /usr/local/adlumin/adlumin_forwarder.py

echo 'Correcting "import zstd" to "import zstandard as zstd" instead to avoid issues with running under python3.10'
sed -i 's|import zstd|import zstandard as zstd|' /usr/local/adlumin/adlumin_forwarder.py

echo 'Commenting out the update function of the script so it does not get overwritten'
sed -i '/updater = threading.Thread(target=update/,+1 s/^/#/' /usr/local/adlumin/adlumin_forwarder.py