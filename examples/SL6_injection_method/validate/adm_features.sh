# set environment variables if available
[[ -s "adm_envrc" ]] && . "./adm_envrc"

# Given a new Virtualbox Guest
context_file="adm_context.txt"

# Each script is separate feature
while read -r script; do
    # don't process comments
    [[ "${script}" =~ ^#.*$ ]] && continue
    if [[ -s "${script}" ]]; then
        #cat "${script}" | grep -E "^# (Feature|Scenario|And|Given|When|Then)"
        bash "${script}"
    fi
done < "${context_file}"
