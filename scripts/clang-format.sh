#!/bin/sh
#
# https://gist.github.com/eriknyquist/d8d3c14406a76bd7d9516a3aaaa3423e
#
# This pre-commit hook checks if any versions of clang-format
# are installed, and if so, uses the installed version to format
# the staged changes.

maj_min=4
# The format is clang-format-7 after clang-format-6.0
maj_max=6

base=clang-format
format=""

# Redirect output to stderr.
exec 1>&2

 # check if clang-format is installed
type "$base" >/dev/null 2>&1 && format="$base"

# if not, check all possible versions
# (i.e. clang-format-<$maj_min-$maj_max>)
if [ -z "$format" ]
then
    for j in `seq $maj_min $maj_max`
    do
        for i in `seq 0 9`
        do
            type "$base-$j.$i" >/dev/null 2>&1 && format="$base-$j.$i" && break
            [ -z "$format" ] || break
        done
    done
fi

# no versions of clang-format are installed
if [ -z "$format" ]
then
    echo "$base is not installed. Pre-commit hook will not be executed."
    exit 0
fi

echo "$format found."
if git rev-parse --verify HEAD >/dev/null 2>&1
then
	against=HEAD
else
	# Initial commit: diff against an empty tree object
	against=4b825dc642cb6eb9a060e54bf8d69288fbee4904
fi

# do the formatting and adding the file again
echo "Formatting code."
for file in `git diff-index --cached --name-only $against`
do
    extension="${file##*.}"
    if [ "$extension" = "cpp" ] || [ "$extension" = "h" ]
    then
        "$format" -style=file -i "$file"
        git add "$file"
    fi
done

