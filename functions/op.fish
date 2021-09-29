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

function __op_error -a message
    echo -e "error: $message\n"
    __op_usage
end

function __op_get_cache_file_name
    echo $HOME/.config/op/cache
end

function __op_get_alias_file_name
    echo $HOME/.config/op/aliases
end

function __op_update_projects -a project
    # Update order of auto completions based on usage
    set projects (cat (__op_get_cache_file_name))

    if set -l index (contains -i $project $projects)
        set -e projects[$index]
        set -p projects $project
    end

    mkdir -p (dirname (__op_get_cache_file_name))

    rm -f (__op_get_cache_file_name)
    for project in $projects
        echo $project >>(__op_get_cache_file_name)
    end
end

function __op_autocomplete_projects
    for project in (__op_get_projects)
        set -l projectName (string split ':' $project)[1]
        set -l projectDir (string split ':' $project)[2]

        printf "%s\n" $projectName
    end
end

function __op_get_project -a project
    set aliases (cat (__op_get_alias_file_name))

    set -l aliasMatch (string match -r "$project:[^\s]+" $aliases)

    if test -n "$aliasMatch"
        echo $aliasMatch

        return
    end

    set -l projects (__op_get_projects)
    set -l projectMatch (string match -r "$project:[^\s]+\$" $projects)
    set -l projectIndex

    if set -q projectMatch[1]
        set projectIndex (contains -i "$projectMatch[1]" $projects)
    end

    if test -z "$projectIndex"
        set -l matchedProject (string split \t -- (complete --do-complete="op $project"))

        if set -q matchedProject[1]
            set projectMatch (string match -r "$matchedProject[1]:[^\s]+" $projects)
            set projectIndex (contains -i "$projectMatch" $projects)
        end
    end

    if test -z "$projectIndex" || test -z "$projects"
        echo "Project not found"

        return 1
    end

    echo $projects[$projectIndex]
end

function __op_get_projects -a forceUpdate
    set -l cacheFile (__op_get_cache_file_name)
    set -l array projects

    if test -z $forceUpdate
        set forceUpdate false
    end

    if test -f $cacheFile
        set projects (cat $cacheFile)
    end

    if eval not $forceUpdate && set -q projects
        set aliases (__op_get_alias_file_name)
        for project in $aliases
            set -a projects $project
        end

        printf "%s\n" $projects

        return
    end

    if eval $forceUpdate
        for project in $projects
            set -l projectDir (string split ':' $project)[2]

            if not test -d $projectDir
                set projectIndex (contains -i "$project" $projects)

                set -e projects[$projectIndex]
            end
        end
    end

    # These are your project directories
    for directory in $OP_PROJECT_DIRS
        echo "Searching $directory"

        for filePath in $directory/*
            if not test -d $filePath
                continue
            end

            # Exclude subdirectories of project directories if they are listed as a project directory
            if contains -i "$filePath" $OP_PROJECT_DIRS
                continue
            end

            set -l entry (basename (dirname $filePath))"/"(basename $filePath):$filePath

            if not contains $entry $projects
                set -a projects $entry
            end
        end
    end

    mkdir -p (dirname (__op_get_cache_file_name))
    rm -f (__op_get_cache_file_name)
    for project in $projects
        echo $project >>$cacheFile
    end

    set -l aliases (cat (__op_get_alias_file_name))
    for project in $aliases
        set -a projects $project
    end

    printf "%s\n" $projects
end

function op --description "Open a project"
    set -l edit false
    set -l gitClient false
    set -l cacheFile (__op_get_cache_file_name)
    set -l project

    for option in $argv
        switch "$option"
            case -g --git-client
                set gitClient true
            case -e --edit
                set edit true
            case -u --update
                echo "Updating projects"
                __op_get_projects true 1>/dev/null

                return
            case -h --help
                __op_usage

                return
            case \*
                if test -n $option
                    set project $option

                    continue
                end

                __op_error "Unknown option/project not found.\n"

                return 1
        end
    end

    if test -z $project
        __op_usage
        return
    end

    set -l projectInfo (__op_get_project "$project")

    if test $status -eq 1
        __op_error $projectInfo

        return 1
    end

    set -l projectName (string split ':' $projectInfo)[1]
    set -l projectDir (string split ':' $projectInfo)[2]

    __op_update_projects $projectInfo

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
end
