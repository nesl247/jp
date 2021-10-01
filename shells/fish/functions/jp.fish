function jp --description "Open a project"
    set -l project
    set -l jpBin (which jp)

    set IFS ""
    set -l output ($jpBin $argv)

    set -l projectDir (string match -rg "^Project: (.*)\$" "$output")
    if test -n "$projectDir"
        cd "$projectDir"
    else
        echo -e "$output"
    end

    return
end
