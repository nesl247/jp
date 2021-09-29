function __op_usage
    echo "usage: op <project> [ <args> ]"
    echo
    echo "Open Project (op) is a project quick-access tool. It allows"
    echo "you to cd to a project, edit it in either \$EDITOR, or in \$IDE,"
    echo "as well as in your prefered git client."
    echo
    echo " -g, --git-client                     Open git client"
    echo " -e, --edit                           Edit in \$EDITOR"
    echo " -i, --ide                            Edit in \$IDE"
    echo " -u, --update                         Update project list"
    echo " -h, --help                           This help message"
    echo
    echo "Configured project directories:"
    echo

    for projectDir in $OP_PROJECT_DIRS
        echo $projectDir
    end
end

function op --description "Open a project"
    set -l edit false
    set -l gitClient false
    set -l project
    set -l opBin (which op)

    for option in $argv
        switch "$option"
            case -g --git-client
                set gitClient true
            case -e --edit
                set edit true
            case update
                $opBin update

                return
            case -h --help
                $opBin --help

                return
            case list
                $opBin list

                return
            case \*
                if test -n $option
                    set project $option

                    continue
                end

                echo "Error: Unknown option\n"

                return 1
        end
    end

    if test -z $project
        $opBin --help

        return
    end

    set -l projectDir ($opBin $project)
    cd "$projectDir"

    if eval $gitClient
        if string match -r '^.*\.app$' "$GIT_CLIENT"
            open -g "$projectDir" -a "$GIT_CLIENT"
        else
            eval "$GIT_CLIENT \"$projectDir\""
        end
    end

    if eval $edit
        eval "$EDITOR \"$projectDir\""
    end

    return
end
