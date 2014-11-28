#!/bin/bash -e

# global configuration
gpg_params="--batch --no-use-agent"
gpg_encryption_params="--symmetric --cipher-algo AES256 --digest-algo SHA512 --s2k-mode 3 --s2k-digest-algo SHA512"
conf=$(cat $1)

# log info function
function log_info {
  message=$1
  timestamp=$(date +'%Y-%m-%d %T')
  echo "[info] ${timestamp} - ${message}"
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

# iterate over configuration file lines (conf pass)
while read -r line; do
  read -a parts <<< "${line}"
  if [ "${parts[0]}" = "conf" ]; then
    case "${parts[1]}" in
      "target") target="${parts[2]}" ;;
      "passphrase") passphrase="${parts[2]}" ;;
      *)
        log_error "unknown configuration key ${parts[1]}"
        exit 1
        ;;
    esac
  fi
done <<< "${conf}"

# check configuration
if [ -z "${target}" ]; then log_error "You must configure the target"; exit 1; fi
if [ ! -e "${target}" ]; then log_error "The target '${target}' does not exist"; exit 1; fi
log_info "target ${target}"

# iterate over configuration file lines (execution pass)
while read -r line; do
  if [ ! -z "${line}" ] && [[ ! "${line}" =~ ^\s*#.*$ ]]; then
    read -a parts <<< "${line}"
    case "${parts[0]}" in
      "folder") backup_folder "${parts[@]}" ;;
      "mysql") backup_mysql "${parts[@]}" ;;
      "conf") ;;
      *)
        log_error "unknown backup task ${parts[0]}"
        exit 1
        ;;
    esac
  fi
done <<< "${conf}"

# cleanup
cleanup

exit 0
