# set environment variables if available
[[ -s "adm_envrc" ]] && . "./adm_envrc"

LOG_PATH=.
#LOG_PATH=/var/log
echo "vm_type: ${VM_TYPE}" >> "${LOG_PATH}/adm_postinstall.log"
echo "vm_description: ${VM_DESC}" >> "${LOG_PATH}/adm_postinstall.log"

context_file="adm_context.txt"
while read -r script; do
    # don't process comments
    [[ "${script}" =~ ^#.*$ ]] && continue
    if [[ -s "${script}" ]]; then
        echo "${script}"
        bash "${script}"
    fi
done < "${context_file}"
