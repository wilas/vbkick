# Contribute to vbkick

 - Submit a [GitHub issue](https://github.com/wilas/vbkick/issues)
 - Tweet [@wilask](https://twitter.com/wilask)
 - Create and Share a new template
 - Submit a pull request to the master branch

# How to submit a pull request

 - Fork vbkick
 - Create feature branch (`git checkout -b new-feature`)
 - Commit changes (`git commit -am 'New feature'`)
 - Push to the branch (`git push origin new-feature`)
 - Create a new pull request

# Code Guide

## Bash scripting Coding Style Guide

### vbkick variables names

 - [vm settings](doc/DEFINITION_CFG.md) -> lowercase_separated_by_underscores: `var_name`
 - global variables         -> lowercase_separated_by_underscores with **one** leading underscore: `_var_name`
 - global constants         -> CAPITALIZED_WITH_UNDERSCORES with **one** leading underscore: `_CONST_NAME`
 - env variables            -> CAPITALIZED_WITH_UNDERSCORES: `ENV_VAR_NAME`
 - local variables          -> lowercase_separated_by_underscores with **two** leading underscores: `__var_name`, remember to decared variable using `local __var_name`
 - global special variables -> UpperCamelCase with **one** leading underscore `_VarName`, at the moment it's only `_Vm` and there shouldn't be more. Global, but defined by the user using command line.


### vbkick functions names

 - global "action" functions    -> lowercase_separated_by_underscores with **one** leading underscore: `_function_name` + `#@action` tag before declaration
 - global "special" functions   -> lowercase_separated_by_underscores with **one** leading underscore: `_function_name` + `#@special` tag before declaration
 - global "private" functions   -> lowercase_separated_by_underscores with **two** leading underscore: `__function_name`

### names in definition files.

Simply: don't use names with leading underscore.

 - [vm settings](doc/DEFINITION_CFG.md) -> lowercase_separated_by_underscores: `var_name`
 - constants          -> CAPITALIZED_WITH_UNDERSCORES: `CONST_NAME`
 - env variables      -> CAPITALIZED_WITH_UNDERSCORES: `ENV_VAR_NAME`
 - local variables    -> lowercase_separated_by_underscores: `var_name`, remember to decared variable using `local var_name`
 - other variables    -> lowercase_separated_by_underscores: `var_name`
 - functions          -> lowercase_separated_by_underscores: `function_name`

### other rules

 - only "action" and "special" functions can use `exit` other can use `return` if necessary

## Python Coding Style Guide

 - Conform in all respects to PEP 8. (see http://legacy.python.org/dev/peps/pep-0008/)
 - We also recommend you read and try to apply:
    - http://www.jeffknupp.com/blog/2012/10/04/writing-idiomatic-python/
    - http://nbviewer.ipython.org/github/rasbt/python_reference/blob/master/not_so_obvious_python_stuff.ipynb
 - Try to keep the maximum indent level to three. "If more is needed, then probably I'm doing something wrong."

