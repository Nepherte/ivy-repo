**IvyRepo** contains the tool chain to populate the
[Nepherte Ivy Repository](https://www.nepherte.be/ivy). This includes the
packaging instructions for all hosted artifacts. Browse this repository for a
current list of build files. Keep on reading for more info on the tool chain.

    Usage: IvyRepo.sh [-h] <command> <artifact>
    Script to manage the Nepherte Ivy Repository

        -h,--help    Print out a help message with examples
        <command>    Possible values are resolve, install and publish
        <artifact>   The artifact id as organisation:module:revision


Introduction
------------
This repository is made possible by Ivy's
[Packager Resolver](http://ant.apache.org/ivy/history/latest-milestone/resolver/packager.html).
This resolver supports downloading, extracting and packaging artifacts from
upstream repositories. It allows for a clear separation between artifact
meta-data and actually hosting them.

For every artifact in the production repository, there is an Ivy module 
definition (`ivy.xml`) that contains the artifact meta-data, plus instructions 
on where to download and how to package them (`packager.xml`).

The tool chain can read the artifact meta-data and build instructions. The
repackaged artifacts are published in an artifact repository, on which projects
can rely for resolving their dependencies.


Installation
------------
Follow these steps to install the tool chain:

1. Install [Ant](https://ant.apache.org/) into `$ANT_HOME`
2. Download [Ivy](https://ant.apache.org/ivy/) to `$USER_HOME\.ant\lib`
3. Use [Git](https://git-scm.com/) to clone this repository to your device
4. Configure the [Production Resolver](#production-resolver) accordingly

#### Prerequisites
The tool chain relies on Ant to run the available commands. Make sure to set the
environment variable `$ANT_HOME`. Ant in turn depends on the presence of a Java
Runtime Environment, available under `$JAVA_HOME` or on the system `$PATH`.

The tool chain automatically downloads Ivy and its dependencies. The jars will 
be available in `$USER_HOME\.ant\lib`. The envirionment variable `$IVY_HOME` 
eventually determines the location in which to cache resolved artifacts.


Getting Started
---------------
The executable `IvyRepo.sh` can be used to manage an online Ivy repository:
from building artifacts to publishing them. It makes upgrading artifacts to
newer versions very easy. Out-of-the-box only artifacts in this git repository
are supported, but new artifacts can be added in the blink of an eye.

#### Resolving Artifacts
To download and build an ivy artifact, use the following command:

    ./IvyRepo.sh resolve <organisation>:<module>:<revision>

#### Installing Artifacts
To install an artifact into the staging repo, use the following command:

    ./IvyRepo.sh install <organisation>:<module>:<revision>

#### Publishing Artifacts
To publish an artifact into the production repo, use the following command:

    ./IvyRepo.sh publish <organisation>:<module>:<revision>


Configuration
-------------
Changing the behavior of the tool chain boils down to configuring the packager
resolver (`packager`), the staging resolver (`filesystem`), or the production 
resolver (`sftp`). Each resolver has a dedicated configuration file.

It is also possible to replace each resolver - say your production repository is
not accessible via sftp - by directly editing the Ivy settings file
(`ivysettings.xml`).

#### Packager Resolver
The packager resolver (`packager`) reconstructs artifacts based on upstream
sources by reading the Ivy meta-data (`ivy.xml`) and packaging instructions
(`packager.xml`) in the source repository, which defaults to `src/repo`.

The location of the packager repository is specified by the directory
`pkg.repo.dir` in `packager.properties`. The exact location of the Ivy
meta-data and packaging instructions are specified by `pkg.repo.pattern`.

#### Staging Resolver
The staging resolver (`filesystem`) acts as a staging area before publishing
artifacts into production. It is highly recommended to try this repository first
before committing anything to your production repository. The target directory
defaults to `target/repo`.

The location of the staging repository is specified by the directory
`stage.repo.dir` in `staging.properties`. The exact location and names of the
artifacts are determined by `stage.repo.pattern` and `stage.artifact.pattern`.

#### Production Resolver
The production resolver (`sftp`) defines the repository that hosts the published 
artifacts. The configuration file `production.properties` contains the
credentials to connect to the online repository. Make sure to update them.