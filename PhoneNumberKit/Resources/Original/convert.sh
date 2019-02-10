#!/bin/sh
python -m xmljson -o PhoneNumberMetadataTemp.json -d yahoo PhoneNumberMetadata.xml
cat PhoneNumberMetadataTemp.json | tr -d " \t\n\r" > PhoneNumberMetadataStripped.json
sed 's/\\n//g;s/\\//g' PhoneNumberMetadataStripped.json > PhoneNumberMetadata.json
# rm PhoneNumberMetadataTemp.json
# rm PhoneNumberMetadataStripped.json