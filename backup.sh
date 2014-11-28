#!/bin/bash -e

# initialize variables
verbose=0
passphrase=""
target=""

# global configuration
gpg_params="--batch --no-use-agent"
gpg_encryption_params="--symmetric --cipher-algo AES256 --digest-algo SHA512 --s2k-mode 3 --s2k-digest-algo SHA512"

# log info function
function log_info {
  message=$1
  timestamp=$(date +'%Y-%m-%d %T')
  if [ $verbose = 1 ]; then echo "[info] ${timestamp} - ${message}"; fi
}

# log err function
function log_error {
  message=$1
  timestamp=$(date +'%Y-%m-%d %T')
  echo "[error] ${timestamp} - ${message}" >&2
}

# print usage
function usage {
  echo "usage: $0 [-v] -t /path/to/backup/target [-p encryption-passphrase] /path/to/tasks/file" >&2
}

# backup a folder
function backup_folder {
  name=$2
  folder=$3
  output="${target}/${name}/${name}-$(date +'%Y-%m-%d_%H-%M-%S').tar.gz"
  mkdir -p "$(dirname ${output})"

  if [ -z $passphrase ]; then
    log_info "backup folder ${folder}"
    log_info "create ${output}"
    tar -cz -C "${folder}" . > "${output}"
  else
    log_info "backup folder ${folder} (encrypted)"
    log_info "create ${output}.gpg"
    tar -cz -C "${folder}" . | gpg ${gpg_params} ${gpg_encryption_params} --passphrase "${passphrase}" > "${output}.gpg"
  fi
}

# backup a mysql database
function backup_mysql {
  name=$2
  dbname=$3
  dbuser=$4
  dbpass=$5
  output="${target}/${name}/${name}-$(date +'%Y-%m-%d_%H-%M-%S').sql.gz"
  mkdir -p "$(dirname ${output})"

  if [ -z $passphrase ]; then
    log_info "backup mysql database ${dbname}"
    log_info "create ${output}"
    mysqldump "-u${dbuser}" "-p${dbpass}" "${dbname}" | gzip -9 > "${output}"
  else
    log_info "backup mysql database ${dbname} (encrypted)"
    log_info "create ${output}.gpg"
    mysqldump "-u${dbuser}" "-p${dbpass}" "${dbname}" | gzip -9 | gpg ${gpg_params} ${gpg_encryption_params} --passphrase "${passphrase}" > "${output}.gpg"
  fi
}

# cleanup old backups
function cleanup {
  treshold="30"
  files=$(find "${target}" -type f -mtime "+${treshold}")

  log_info "cleanup backups older than ${treshold} days"
  for file in $files; do
    log_info "remove ${file}"
    rm "${file}"
  done
}

# parse arguments
OPTIND=1
OPTERR=0
while getopts "h?vp:t:" opt; do
  case "$opt" in
    v) verbose=1 ;;
    t) target=$OPTARG ;;
    p) passphrase=$OPTARG ;;
    \?) usage; exit 1 ;;
  esac
done
shift $((OPTIND-1))
[ "$1" = "--" ] && shift
tasks="$1"

if [ -z $target ]; then usage; exit 1; fi
if [ -z $tasks ]; then usage; exit 1; fi
if [ ! -e $tasks ]; then log_error "tasks file ${tasks} does not exist"; exit 1; fi

# prepare
log_info "target ${target}"
if [ ! -z $passphrase ]; then log_info 'passphrase ***'; fi
mkdir -p "${target}"

# iterate over backup tasks
cat "${tasks}" | while read line; do
  read -a task <<< "${line}"

  case "${task[0]}" in
    "folder")
      backup_folder "${task[@]}"
      ;;
    "mysql")
      backup_mysql "${task[@]}"
      ;;
    "#" | "")
      ;;
    *)
      log_error "unknown backup task ${task[0]}"
      exit 1
      ;;
  esac
done

# cleanup
cleanup

exit 0
