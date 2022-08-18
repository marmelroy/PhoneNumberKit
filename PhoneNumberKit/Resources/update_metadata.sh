#!/bin/bash

get_version () {
    # Regex to find the version number, assumes semantic versioning
    grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' |
    # Take the first match in the regex
    head -1 || echo '0.0.0'
}

latest_release_number () {
    # Github cli to get the latest release
    gh release list --repo $1 --limit 1 | get_version
}

current_metadata_version () {
    cat .metadata-version | get_version
}

create_scratch () {
    # Create temporary directory
    scratch=$(mktemp -d -t TemporaryDirectory)
    if [[ $debug ]]; then open $scratch; fi
    # Run cleanup on exit
    trap "if [[ \$debug ]]; then read -p \"\"; fi; rm -rf \"$scratch\"" EXIT
}

commit_changes() {
    branch="$1"
    git checkout -b $branch
    git add .
    git commit -m "Updated metadata to version $branch"
    git push -u origin $branch
    gh pr create --fill
}

# Exit when any command fails
set -e
set -o pipefail

# Repos
libphonenumber_repo="https://github.com/google/libphonenumber"
phonenumberkit_repo="https://github.com/marmelroy/PhoneNumberKit"

# Release versions
latest=$(latest_release_number $libphonenumber_repo)
current=$(current_metadata_version)

# Args
debug=$(echo $@ || "" | grep debug)
skip_release=$(echo $@ || "" | grep skip-release)

if [[ $latest != $current ]]; then
    echo "$current is out of date. Updating to $latest..."
    
    create_scratch
    (
        cd $scratch
        home=$OLDPWD
        echo "Downloading latest release..."
        gh release download --archive zip --repo $libphonenumber_repo
        echo "Unzipping..."
        lib_name="libphonenumber"
        unzip -q *.zip
        for _dir in *"${lib_name}"*; do
            [ -d "${_dir}" ] && dir="${_dir}" && break
        done
        echo "Copying original metadata..."
        cp -r "$scratch/$dir/resources/PhoneNumberMetadata.xml" "$home/Original/"
        cd $home
    )

    echo "Generating JSON file..."
    python3 -m xmljson -o PhoneNumberMetadataTemp.json -d yahoo "$(pwd)/Original/PhoneNumberMetadata.xml"
    cat PhoneNumberMetadataTemp.json | sed 's/\\n//g' | sed 's/ \{3,\}//g' | sed 's/   //g' | tr -d "\n" > PhoneNumberMetadata.json
    rm PhoneNumberMetadataTemp.json

    echo "Updating version file..."
    echo $latest > .metadata-version

    echo "Testing new metadata..."
    cd ../..
    swift test --parallel
    rm -rf .build

    # Skips deploy
    if [[ $skip_release ]]; then echo "Done"; exit 0; fi

    # Commit, push and create PR
    echo "Merging changes to Github..."
    commit_changes "metadata/$latest"

else
    echo "$current is up to date."
fi

echo "Done"