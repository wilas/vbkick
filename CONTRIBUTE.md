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
 - don't use [shorthand character classes](http://www.regular-expressions.info/shorthand.html) in regular expressions
 - use brackets expressions `[0-9]` instead of POSIX character classes `[:digit:]` - POSIX not always mean portable (feel free to check that on Solaris - `echo "State:  running " | grep "State:[[:space:]][[:space:]]*running"`).
 - use Basic Regular Expressions [BRE](http://pubs.opengroup.org/onlinepubs/009695399/basedefs/xbd_chap09.html#tag_09_03_06) instead of ERE - `GNU sed` has a different option than `BSD sed` to turn on Extended Regular Expressions.

## Perl Coding Style Guide

TODO

