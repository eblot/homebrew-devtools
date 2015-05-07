require 'formula'

class NoFileStrategy <AbstractDownloadStrategy
    # Intended No-op
end

class SbxScript <Formula

  url 'none', :using => NoFileStrategy
  version '1.0.1'
  sha1 ''

  def stage(target=nil, &block)
    bin.mkpath
    path = bin+"sbx"
    path.write <<-EOS.undent
      #!/bin/sh
      
      SANDBOXES="sandboxes"
      NAME=`basename $0`
      
      # Show usage information
      usage()
      {
          cat <<EOT
      $NAME [options] <old_sbx> <new_sbx>
        Create a new sandbox and replace an old sandbox with the new one
          -h         Show this help message
          -b origin  Use a specific origin branch to create the sandbox, rather
                     than the origin branch of the old sandbox
                     Using '-'' as <old_sbx> with this option allows to create
                     a fresh WC without replacing an existing one.
       
          When invoked without any parameters, the list of existing sandboxes and
          their status is reported
      EOT
      }
      
      # Show help message
      if [ x_"$1" = x_"-h" ]; then
          usage
          exit 1
      fi
      
      ORIGIN_ROOT=""
      
      # From the current directory, move up till the "repository" root of the
      # working copy is located
      SBPATH="${PWD}"
      while [ -n "${SBPATH}" -a "${SBPATH}" != "/" ]; do
          if [ ! -d ${SANDBOXES} ]; then
              SBPATH=`dirname ${SBPATH}`
              cd ${SBPATH}
              continue
          else
              ORIGIN_ROOT="${PWD}"
              echo "SVN top-level dir: ${PWD}"
              break
          fi
      done
      
      # sanity check
      if [ -z "$ORIGIN_ROOT" ]; then
          echo "SVN working copy not identified, or no existing ${SANDBOXES} directory" >&2
          echo "$NAME should be run from a WC." >&2
          exit 1
      fi
      
      # The absolute path of all sandboxes has been detected, so we are now able to
      # list the status of all the existing working copies
      SANDBOX_PATH="${ORIGIN_ROOT}/${SANDBOXES}"
      
      # If no argument is provided, the user requests info about all existing 
      # sandboxes
      if [ $# -eq 0 -o "$1" = "?" ]; then
          # sanity check
          SBX_COUNT=`ls -1d ${SANDBOX_PATH}/* 2> /dev/null | wc -l`
          if [ "${SBX_COUNT}" -eq 0 ]; then
              echo "No exisiting sandbox" >&2
              exit 1
          fi
          for s in `ls -1d ${SANDBOX_PATH}/*`; do
              short=`echo "${s}" | sed 's%^.*/%%g'`
              url=`svn info "${s}" | grep '^URL:'| sed 's/^URL: //g'`
              rev=`svn info "${s}" | grep '^Revision:'| sed 's/^Revision: //g'`
              log=`svn log -l1 --incremental "${url}" 2>/dev/null | tail -n +4`
              from=`svn log --stop-on-copy -v --incremental "${url}@${rev}" \
                    2>/dev/null | \
                    grep " A /${SANDBOXES}/${short} " | sed "s%^.*/${short}%%g"`
              sbx=`echo "$s" | sed 's^.*/^^g'`
              if [ -n "${log}" ]; then
                  echo "  $sbx${from}: $log"
              else
                  echo "  $sbx${from}: (not on server anymore)"
              fi
          done
          exit 0
      fi
      
      ORIGIN=""
      SVN_SW_ARG=""
      # if an origin branch is specified, retrieve it and remove it from the 
      # remaing script arguments
      if [ "$1" = "-b" ]; then
          shift;
          ORIGIN="$1";
          START=`echo "${ORIGIN}" | cut -c1`
          shift
          if [ "${START}" = "^" ]; then
              ORIGIN=`echo "${ORIGIN}" | cut -c2-`
          elif [ "${START}" != "/" ]; then
              ORIGIN="/${ORIGIN}"
          fi
          SVN_SW_ARG="--ignore-ancestry"
      fi
      
      # sanity check
      if [ $# -ne 2 ]; then
          usage
          exit 1;
      fi
      
      # The sandbox that should be replaced
      OLD_SBX="$1"
      # The new sandbox to create.
      NEW_SBX="$2"
      
      INVALID=`echo "${NEW_SBX}" | sed -E s'%t[0-9]+[a-z]?%%'`
      if [ -n "${INVALID}" ]; then
          echo "Invalid sandbox name: ${NEW_SBX}" >&2
          exit 1
      fi
      
      if [ "${OLD_SBX}" != "-" ]; then
          # Discard no-op
          if [ "${OLD_SBX}" = "${NEW_SBX}" ]; then
              echo "Old and new sanbboxes are identical" >&2
              exit 1
          fi
          
          OLD_SB="${SANDBOX_PATH}/${OLD_SBX}"
          if [ ! -d "${OLD_SB}" ]; then
              echo "No such sandbox: ${OLD_SB}" >&2
              exit 1
          fi
          
          
          # If no origin branch has been specified, then retrieve it from the old
          # sandbox
          if [ -z "$ORIGIN" ]; then
              s="${OLD_SB}"
              short=`echo "${s}" | sed 's%^.*/%%g'`
              url=`svn info "${s}" | grep '^URL:'| sed 's/^URL: //g'`
              rev=`svn info "${s}" | grep '^Revision:'| sed 's/^Revision: //g'`
              log=`svn log -l1 --incremental "${url}" 2>/dev/null | tail -1`
              from=`svn log --stop-on-copy -v --incremental "${url}@${rev}" \
                    2>/dev/null | \
                    grep " A /${SANDBOXES}/${short} " | sed "s%^.*/${short}%%g"`
              ORIGIN=`echo "${from}" | sed 's%^.*from %%g' | sed 's%:.*$%%g'`
              if [ -z "${ORIGIN}" ]; then
                  echo "Incoherent path, unable to retrieve ${short} origin" >&2
                  exit 1
              fi
          else
              REPOS=`svn info "${OLD_SB}" | grep '^Repository Root:'| \
                     sed 's/^.*: //g'`
              svn info "${REPOS}${ORIGIN}" 2>/dev/null >/dev/null
              if [ $? -ne 0 ]; then
                  echo "Origin branch $ORIGIN does not exist in the repository" >&2
                  exit 1
              fi
          fi
          
          echo "Origin branch:     $ORIGIN"
          
          # Finally ready to go!
          ORIGIN_PATH="${ORIGIN_ROOT}/${ORIGIN}"
          OLD_TICKET=`echo ${OLD_SBX} | tr -d [:alpha:]`
          NEW_TICKET=`echo ${NEW_SBX} | tr -d [:alpha:]`
          
          # cd to trunk as it always exists
          (/bin/echo -n "Create new sandbox ${NEW_SBX}"; \
           cd ${ORIGIN_ROOT}/trunk && \
           svn cp ^/${ORIGIN} ^/${SANDBOXES}/${NEW_SBX} \
              -m "Creates a new sandbox for #${NEW_TICKET}") && \
          (echo "Checking status of working copy" && \
           cd ${SANDBOX_PATH} && \
           mv "${OLD_SBX}" "${NEW_SBX}" && \
           cd "${NEW_SBX}") && \
          (echo "Swiching sandbox" && \
           cd "${SANDBOX_PATH}/${NEW_SBX}" && \
           svn sw ${SVN_SW_ARG} ^/${SANDBOXES}/${NEW_SBX} && \
           svn info . && \
           svn st) || exit 1
      
      else  
          
          # create a new local working copy
          echo "Origin branch:     $ORIGIN"
          
          # Finally ready to go!
          ORIGIN_PATH="${ORIGIN_ROOT}/${ORIGIN}"
          NEW_TICKET=`echo ${NEW_SBX} | tr -d [:alpha:]`
          
          (/bin/echo -n "Create new sandbox ${NEW_SBX}"; \
           cd ${ORIGIN_ROOT}/trunk && \
           svn cp ^/${ORIGIN} ^/${SANDBOXES}/${NEW_SBX} \
              -m "Creates a new sandbox for #${NEW_TICKET}") && \
          (echo "Checking out a new working copy" && \
           cd ${ORIGIN_PATH} && \
           svn co ^/${SANDBOXES}/${NEW_SBX} ${SANDBOX_PATH}/${NEW_SBX} && \
           cd "${SANDBOX_PATH}/${NEW_SBX}" && \
           svn info . && \
           svn st) || exit 1
      
      fi
      
      if [ -d "${SANDBOX_PATH}/${NEW_SBX}/build" ]; then
          echo "Cleaning up build directory..."
          rm -rf "${SANDBOX_PATH}/${NEW_SBX}/build"
      fi
      
      echo "New sandbox ${SANDBOX_PATH}/${NEW_SBX}"
      if [ "`uname -s`" = "Darwin" ]; then
          echo "  Press ⌘V to change dir" 
          echo "cd ${SANDBOX_PATH}/${NEW_SBX}" | pbcopy
      fi
    EOS
  end
end
