# set environment variables if available
[[ -s "adm_envrc" ]] && . "./adm_envrc"

context_file="adm_context.txt"
while read -r script; do
    # don't process comments
    [[ "${script}" =~ ^#.*$ ]] && continue
    if [[ -s "${script}" ]]; then
        echo "${script}"
        bash "${script}"
    fi
done < "${context_file}"
