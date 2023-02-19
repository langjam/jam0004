#!/usr/bin/env sh

# This script is used to bootstrap the pling command.

build_pling() {
    PWD=$(pwd)
    # shellcheck disable=SC2164
    cd engine
    mvn clean install package
    # shellcheck disable=SC2164
    cd "$PWD"
    echo "Building pling...done"
}

echo "Bootstrapping pling..."

# Check if we have a pling command already.
if [ -x "$(command -v pling)" ]; then
    echo "pling command already exists. Skipping..."
    exit 0
fi

# Check if we have java installed.
if [ -z "$(command -v java)" ]; then
    echo "Java is not installed. Please install Java and try again."
    exit 1
fi

# Check if there is a built jar file in pwd/engine/target.
if [ ! -f "engine/target/engine-1.0-SNAPSHOT.jar" ]; then
    echo "Building pling..."
    build_pling
else
    echo "pling is already built. Skipping..."
fi

# Create an alias for the pling command.
# shellcheck disable=SC2139
alias pling="java -jar $(pwd)/engine/target/engine-1.0-SNAPSHOT.jar"

# redirect stderr to dev null
PLING_VERSION=$(pling --version 2>/dev/null)

# Get the first line of the output.
PLING_VERSION=$(echo "$PLING_VERSION" | head -n 1)

# Drop the last 10 characters of the string.
PLING_VERSION=${PLING_VERSION%??????????}

echo "Bootstrapping pling...done, you can now use the pling command. Pling Version: $PLING_VERSION)"