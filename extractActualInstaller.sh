#! /bin/bash

set -e # Stop whenever a command fails
set -o pipefail # Even stop when some command that's piped fails

which binwalk >/dev/null 2>&1 || { echo >&2 "ERROR: Can not find binwalk executable; please install it and have it on your \$PATH"; exit 1; }

EXTRACTDIR="./extracted"

function help {
  echo "Syntax: $0 [-d directory] <ActualInstallerFile.exe>"
  echo "Where 'directory' is the directory to place the extracted files in (default: '${EXTRACTDIR}')"
  echo "And 'ActualInstallerFile.exe is the Actual Installer file to extract"
}

while getopts ":hd:" option; do
   case $option in
      h)
         help
         exit 0
         ;;
      d)
         EXTRACTDIR=$OPTARG
         ;;
      \?)
         echo "ERROR: Invalid option"
         echo ""
         help
         exit 1
         ;;
   esac
done

shift $(($OPTIND - 1))
EXTRACTFILE="$1"

[[ -n "${EXTRACTFILE}" ]] || { echo >&2 "ERROR: You need to supply the file to extract"; echo ""; help; exit 2; }
[[ -f "${EXTRACTFILE}" ]] || { echo >&2 "ERROR: Can not read file ${EXTRACTFILE}"; exit 3; }

TMPDIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'tmpActualInstaller')
function cleanup {
  rm -rf "${TMPDIR}"
}
trap cleanup EXIT

mkdir -p "${EXTRACTDIR}"

binwalk --rm -e -C "${TMPDIR}" "${EXTRACTFILE}"
mv "${TMPDIR}/_$(basename $EXTRACTFILE).extracted/"* "${TMPDIR}/"
rmdir "${TMPDIR}/_$(basename $EXTRACTFILE).extracted/"

LINECOUNT=$(wc --lines "${TMPDIR}/aisetup.ini" | awk '{ print $1 }')
for LINE in $(grep -A ${LINECOUNT} '\[Files\]' "${TMPDIR}/aisetup.ini" | grep '^[0-9]\+=')
do
  COUNT=$(echo "${LINE}" | awk -F '[=?]' '{ print $1 }')
  FILE=$(echo "${LINE}" | awk -F '[=?]' '{ print $2 }' | sed 's/<InstallDir>\\//' | sed 's/\\/\//g')

  echo "Extracting ${COUNT} as ${EXTRACTDIR}/${FILE}"
  mkdir -p "${EXTRACTDIR}/$(dirname $FILE)"
  mv "${TMPDIR}/${COUNT}" "${EXTRACTDIR}/${FILE}"
done
