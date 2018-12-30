#!/bin/bash

function printHelp() {
  echo "Usage: IvyRepo.sh [-h] <command> <artifact>"
  echo "Script to manage the Nepherte Ivy Repository."
  echo
  echo "    -h,--help    Print this help message"
  echo "    <command>    Possible values are resolve, install and publish"
  echo "    <artifact>   The artifact id as organisation:module:revision"
  echo
  echo
  echo "Below are a couple of valid usage statements:"
  echo
  echo "    Example 1"
  echo "    > IvyRepo.sh resolve org.slf4j:slf4j-api:1.7.21"
  echo
  echo "    Example 2"
  echo "    > IvyRepo.sh install org.slf4j:slf4j-api:1.7.21"
  echo
  echo "    Example 3"
  echo "    > IvyRepo.sh publish org.slf4j:slf4j-api:1.7.21"
  echo
  echo
  echo "The sytem variable ANT_HOME must point to the installation directory of"
  echo "Apache Ant. In addition, a Java Runtime Environment must be installed too."
  exit
}

# Make sure Ant exists.
if [ ! -f "$ANT_HOME/bin/ant" ]; then
  printHelp
fi

# Parse optional arguments.
if [ "$1" == "-h" ]; then
  printHelp
fi
if [ "$1" == "--help" ]; then
  printHelp
fi

# Script arguments.
antTarget="$1"
artifact="$2"

# Validate mandatory arguments.
if [ "$#" != "2" ]; then
  printHelp
fi

if [ "$antTarget" != "resolve" ] &&
   [ "$antTarget" != "install" ] &&
   [ "$antTarget" != "publish" ]; then

  printHelp
fi

# Parse the artifact argument.
IFS=':'; artifactArray=($artifact); unset IFS;

if [ "${#artifactArray[@]}" != "3" ]; then
  printHelp
fi

organisation="${artifactArray[0]}"
module="${artifactArray[1]}"
revision="${artifactArray[2]}"

# Call ant script
antProperties="-Dorganisation=$organisation -Dmodule=$module -Drevision=$revision"
cd $(dirname "$0")/src/etc/ant; "$ANT_HOME/bin/ant" $antProperties -f build.xml $antTarget
