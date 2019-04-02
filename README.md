# OP
Open Project (op) is a project quick-access tool

# Installation

## OMF (Oh-MyFish)
```bash
omf install https://github.com/nesl247/op
```

## Fundle
```
fundle plugin 'nesl247/op' # You should put this in your ~/.config/fish/config.fish
fundle update
```

# Setup

In `~/.config/fish/config.fish` you should add:

```
set -x OP_PROJECT_DIRS <your> <dirs> <here> # e.g. set -x OP_PROJECT_DIRS $HOME/code
```

# Usage
Autocompletion:
```
op <tab>
```

`cd` to project:
```
op <project>
```

Open project in `$EDITOR`:
```
op -e <project>
```

Open project in `$IDE`:
```
op -i <project>
```

Open project in `$GIT_CLIENT`:
```
op -g <project>
```

You can also combine flags like:
```
op -g -e <project>
```
