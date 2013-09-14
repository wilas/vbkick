# set environment variables if available
[[ -s "adm_envrc" ]] && . "./adm_envrc"

# Given a new Virtualbox Guest
if [ $# -ge 1 ]; then
    context_file="${1}"
else
    context_file="adm_context.txt"
fi

# Each script is separate feature
while read -r script; do
    # don't process comments
    [[ "${script}" =~ ^#.*$ ]] && continue
    if [[ -s "${script}" ]]; then
        bash "${script}"
    fi
done < "${context_file}"
