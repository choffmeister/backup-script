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

# backup a folder
function backup_folder {
  output=$1
  folder=$2
  mkdir -p "$(dirname ${output})"

  if [ -z $passphrase ]; then
    log_info "backup folder ${folder}"
    log_info "create ${output}.tar.gz"
    tar -cz -C "${folder}" . > "${output}.tar.gz"
  else
    log_info "backup folder ${folder} (encrypted)"
    log_info "create ${output}.tar.gz.gpg"
    tar -cz -C "${folder}" . | gpg ${gpg_params} ${gpg_encryption_params} --passphrase "${passphrase}" > "${output}.tar.gz.gpg"
  fi
}

# backup a mysql database
function backup_mysql {
  output=$1
  dbname=$2
  dbuser=$3
  dbpass=$4
  mkdir -p "$(dirname ${output})"

  if [ -z $passphrase ]; then
    log_info "backup mysql database ${dbname}"
    log_info "create ${output}.sql.gz"
    mysqldump "-u${dbuser}" "-p${dbpass}" "${dbname}" | gzip -9 > "${output}.sql.gz"
  else
    log_info "backup mysql database ${dbname} (encrypted)"
    log_info "create ${output}.sql.gz.gpg"
    mysqldump "-u${dbuser}" "-p${dbpass}" "${dbname}" | gzip -9 | gpg ${gpg_params} ${gpg_encryption_params} --passphrase "${passphrase}" > "${output}.sql.gz.gpg"
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
    mode="${parts[0]}"
    name="${parts[1]}"
    name_undashed=$(echo "${name}" | sed 's/[^a-zA-Z0-9]/\-/g')
    output_path="${target}/${name}/${name_undashed}-$(date +'%Y-%m-%d_%H-%M-%S')"

    case "${parts[0]}" in
      "folder") backup_folder "${output_path}" "${parts[2]}" ;;
      "mysql") backup_mysql "${output_path}" "${parts[2]}" "${parts[3]}" "${parts[4]}" ;;
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
