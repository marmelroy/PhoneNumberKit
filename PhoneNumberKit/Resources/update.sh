#!/bin/sh
python -m xmljson -o PhoneNumberMetadataTemp.json -d yahoo "$(pwd)/Original/PhoneNumberMetadata.xml"
cat PhoneNumberMetadataTemp.json | sed 's/\\n//g' | sed 's/ \{3,\}//g' | sed 's/   //g' | tr -d "\n" > PhoneNumberMetadata.json
rm PhoneNumberMetadataTemp.json

