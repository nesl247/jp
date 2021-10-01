# JP
Jump to Project (jp) is a project quick-access tool

# Installation

## OMF (Oh-MyFish)
```bash
omf install https://github.com/nesl247/op
```

## Fundle
```
fundle plugin 'nesl247/jp' # You should put this in your ~/.config/fish/config.fish
fundle update
```

# Setup

In `~/.config/fish/config.fish` you should add:

```
set -x JP_PROJECT_DIRS <your> <dirs> <here> # e.g. set -x JP_PROJECT_DIRS $HOME/code
```

# Usage
Autocompletion:
```
jp <tab>
```

`cd` to project:
```
jp <project>
```

Open project in `$EDITOR`:
```
jp -e <project>
```

Open project in `$IDE`:
```
jp -i <project>
```

Open project in `$GIT_CLIENT`:
```
jp -g <project>
```

You can also combine flags like:
```
jp -g -e <project>
```
