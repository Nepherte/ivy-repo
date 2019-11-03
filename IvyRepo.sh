#!/bin/sh

# Location of the Ant buildfile (relative to this script).
BUILD_FILE=src/etc/ant/build.xml

# Location of the Ant binary. Leave empty for auto-detection.
ANT_BIN=

# Prints a usage statement.
#
# Globals:
#   None
#
# Params:
#   None
printUsage() {
  echo "Usage: IvyRepo.sh [-h] <command> [<artifact>]"
  echo "Script to manage an Ivy Repository."
  echo
  echo "    -h,--help    Print this help message"
  echo "    <command>    Possible values are resolve, install and publish"
  echo "    <artifact>   The artifact id as organisation:module:revision"
  echo
  echo "Available commands are:"
  echo
  echo "    resolve     <artifact>  Download and build an artifact"
  echo "    resolve-all             Download and build all artifacts"
  echo "    install     <artifact>  Install an artifact into staging"
  echo "    install-all             Installs all artifacts into staging"
  echo "    publish     <artifact>  Publish an artifact into production"
  echo "    publish-all             Publish all artifacts into production"
  echo
  echo "Some usage examples are:"
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
  echo "The script looks for Ant in either ANT_HOME or PATH. If needed,"
  echo "additional options can be passed to Ant by exporting ANT_OPTS."
}

# Prints an error statement.
#
# Globals:
#   None
#
# Params:
#   1 - the error message
printError() {
  echo "ERROR: $1"
  echo "Run ./IvyRepo.sh --help for more information"
}

# Attempts to find the Ant binary. Either in ANT_HOME or PATH.
#
# Globals:
#   PATH - list of directories in which to look for Ant
#   ANT_HOME - path to the installation of Ant
#
# Params:
#   None
#
# Returns:
#   the location of the Ant binary
findAntBinary() {
  if [ -f "$ANT_HOME/bin/ant" ]; then
    echo "$ANT_HOME/bin/ant"
  elif [ -f "$(which ant)" ]; then
    echo "$(which ant)"
  fi
}

# Executes an Ant target that operates on a single artifact.
#
# Globals:
#   ANT_BIN - path to the Ant executable
#   BUILD_FILE - path to the Ant buildfile
#
# Params:
#   1 - name of the Ant target to execute
#   2 - artifact as <organisation>:<module>:<revision>
runAntTargetOnArtifact() {
  if [ "$#" != "2" ]; then
    printError "command '$1' expects one artifact"
    exit 1
  fi

  # The params of this function.
  target="$1";
  artifact="$2";

  # Split up the artifact into a separate organisation, module and revision.
  IFS=: read organisation module revision other <<< "$artifact"; unset IFS;

  # Error if the artifact is not in the expected format
  if [ "$organisation" == "" ] || [ "$module" == "" ] ||
     [ "$revision" == "" ] || [ "$other" != "" ]; then

      printError "unexpected artifact '$artifact'"
      exit 1
  fi

  # Call the Ant target with the required properties.
  properties="$ANT_OPTS -Dorganisation=$organisation -Dmodule=$module -Drevision=$revision"
  runAntTarget "$target" "$properties"
}

# Executes an Ant target that operates on all artifact.
#
# Globals:
#   ANT_BIN - path to the Ant executable
#   BUILD_FILE - path to the Ant buildfile
#
# Params:
#   1 - name of the Ant target to execute
runAntTargetOnAllArtifacts() {
  if [ "$#" != "1" ]; then
    printError "command '$1' expects no artifacts"
    exit 1
  fi

  target="$1"; properties=;
  runAntTarget "$target" "$properties"
}

# Executes an Ant target.
#
# Globals:
#   ANT_BIN - path to the Ant executable
#   BUILD_FILE - path to the Ant buildfile
#
# Params:
#   1 - the name of the Ant target to execute
#   2 - the properties to pass to the Ant target
runAntTarget() {
  # Figure out where the build file is located.
  fileDir=$(dirname "$0")/$(dirname "$BUILD_FILE")
  fileName=$(basename "$BUILD_FILE")

  # Call the Ant target from within the BUILD_FILE dir.
  cd "$fileDir"; "$ANT_BIN" $2 -f $fileName $1
}

# Make sure Ant exists.
ANT_BIN="$(findAntBinary)"

if [ ! -f "$ANT_BIN" ]; then
  printError "unable to locate Apache Ant install"
  exit 1
fi

# Parse options.
while [ "$1" != "" ]; do
  case $1 in
    -h | --help)
      printUsage
      exit 0
      ;;
    -+ | --+)
      printError "unrecognised option '$1'"
      exit 1
      ;;
    --)
      shift;
      break;
      ;;
    *)
      break
      ;;
  esac
  shift
done

# Parse commands.
if [ "$#" == "0" ]; then
  printError "expected a single command to execute"
  exit 1
fi

while [ "$1" != "" ]; do
  case $1 in
    help)
      printUsage
      exit 0
      ;;
    resolve | install | publish)
      runAntTargetOnArtifact "$@"
      exit 0
      ;;
    resolve-all | install-all | publish-all)
      runAntTargetOnAllArtifacts "$@"
      exit 0
      ;;
    *)
      printError "unrecognised command '$1'"
      exit 1
      ;;
  esac
  shift
done
