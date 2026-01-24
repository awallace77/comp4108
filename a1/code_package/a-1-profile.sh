#!/bin/bash

function get_full_name_for_uid() {
  ### This function returns the full name (found within the GECOS field) of the associated UID.
  ### Example: Bruce Wayne

  local USER_ID=${1}
  local user_info=$(cat /etc/passwd | grep $USER_ID)
  local name=$(echo $user_info | cut -d ':' -f 5 | cut -d ',' -f 1)

  echo "$name" 
  return 0
}

function get_user_name_for_uid() {
  ### This function returns the user name of the associated UID.
  ### Example: bwayne

  local USER_ID=${1}
  local user_info=$(cat /etc/passwd | grep $USER_ID)
  local username=$(echo $user_info | cut -d ':' -f 1)

  echo $username 
  return 0
}

function get_primary_gid_for_uid() {
  ### This function returns the GID of the primary group for the associated UID.
  ### Example: 1000

  local USER_ID=${1}
  local user_info=$(cat /etc/passwd | grep $USER_ID)
  local gid=$(echo $user_info | cut -d ':' -f 4)

  echo $gid 
  return 0
}

function get_group_name_for_gid() {
  ### This function returns the name of the primary group for the associated GID.
  ### Example: bwayne

  local GROUP_ID=${1}
  local group_info=$(cat /etc/group | grep $GROUP_ID)
  local groupname=$(echo "$group_info" | cut -d ':' -f 1)

  echo $groupname 
  return 0
}

function get_all_group_names_for_uid() {
  ### This function returns all group names that the associated UID is a member of, space-separated.
  ### Example: bwayne batteam
  ### Hint: If you invoke a function using $() notation, newlines will turn into spaces automatically.
  local USER_ID=${1}
  local user_info=$(cat /etc/passwd | grep $USER_ID)
  local username=$(echo "$user_info"| cut -d ':' -f 1)
  local group_infos=$(cat /etc/group | grep "$username")
 
  # Collect all group names
  local all_group_names=""
	for group_info in ${group_infos}; do
	  all_group_names+="$(echo $group_info | cut -d ':' -f 1) "
	done
  
  echo "${all_group_names}"
  return 0
}

# -------------------------------------------------
#  DO NOT EDIT BELOW!
# -------------------------------------------------

function print_profile_for_uid() {
	local USER_ID=${1}
	local FULL_NAME=$(get_full_name_for_uid ${USER_ID})
	local USER_NAME=$(get_user_name_for_uid ${USER_ID})
	local PRIMARY_GID=$(get_primary_gid_for_uid ${USER_ID})
	local PRIMARY_GROUP_NAME=$(get_group_name_for_gid ${PRIMARY_GID})
	local ALL_GROUP_NAMES=$(get_all_group_names_for_uid ${USER_ID})

	local OTHER_GROUP_NAMES=""
	for GROUP_NAME in ${ALL_GROUP_NAMES}; do
		if [ "${GROUP_NAME}" != "${PRIMARY_GROUP_NAME}" ]; then
			OTHER_GROUP_NAMES+="${GROUP_NAME}, "
		fi
	done

	if [ ${#OTHER_GROUP_NAMES} -ge 2 ]; then
		OTHER_GROUP_NAMES=${OTHER_GROUP_NAMES:0:-2}
	fi

	local PROFILE_OUTPUT="
------------------- [ ${USER_ID} ] ---------------------
 User: ${FULL_NAME:-[unnamed]} (${USER_NAME})
 Primary Group: ${PRIMARY_GROUP_NAME} (${PRIMARY_GID})
 Other Groups: ${OTHER_GROUP_NAMES:-[none]}
----------------------------------------------$(printf -- '-%.0s' $(seq 1 ${#USER_ID}))
"
	echo "${PROFILE_OUTPUT}"
}

USER_ID=${1}
if ! [[ "${USER_ID}" =~ ^[0-9]+$ ]] || ! id -nu "${USER_ID}" > /dev/null; then
	>&2 echo "Please provide a valid UID as the first argument."
	exit 1
fi

print_profile_for_uid ${USER_ID}
