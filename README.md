# homebrew-devtools
Development script bazaar

These scripts are not designed to be portable/reused.

## sbx

Simple script to start up a new development with Trac & SVN, switching an
existing SVN working copy to a new sandbox.

    sbx [options] <old_sbx> <new_sbx>
    Create a new sandbox and replace an old sandbox with the new one
      -h         Show this help message
      -b origin  Use a specific origin branch to create the sandbox, rather
                 than the origin branch of the old sandbox
                 Using '-'' as <old_sbx> with this option allows to create
                 a fresh WC without replacing an existing one.

1. When invoked without any parameters, the list of existing sandboxes and their 
   status is reported
1. When invoked with old and new sandbox argument:
    1. Create a new sandbox on a remote SVN server, tied to an existing Trac ticket
    1. Switch the current working copy to the new remote sandbox
    1. List any uncommited changes
    1. On OS X, fill the pasteboard with the command to invoke to change dir to
       the new working copy.

## sdk

Simple script that sets up the toolchain environment variables for the SDK 
standing in the current directory.

This script should always be sourced.

    . sdk [-h] [-f] [sdk_version]
      Set up SDK toolchain
        -h  Show this help message
        -f  Force predefined versions over build default
