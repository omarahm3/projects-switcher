# Projects Switcher #

This is a simple fish shell function, which aims to help developers that are working on a typical multi-repositories environment. Sometimes you're just building a feature let's say `feat/user-notifications` and you're doing it on multiple repositories, and you have your branch set on each repository, but now for some reason you have to checkout to another branch say `develop` to fix a bug or something, and you are not actually using [git-worktree](https://git-scm.com/docs/git-worktree) or you just can't use it.
Then this script will simply allow you to checkout each repository you have under the root path, to the branch you want.

## Setup: ##

You'll just have to copy `./project_switcher.fish` to your fish functions, typically under `~/.config/fish/functions`

```bash
cp ./project_switcher.fish ~/.config/fish/functions/project_switcher.fish
```

## Arguments ##

- First argument will be the branch you want to checkout to
- Second argument will be the root path of the project that holds all repositories under
  - This is optional and the default value will be the current working directory

## Options: ##

- `-h` or `--help`
  - Optional
  - Will display the help menu
- `-r` or `--reset`
  - Optional
  - This will hard reset (run `git reset --hard`) the repository
- `-s` or `--stash`
  - Optional
  - This will run (`git stash`) on the repository
- `-f` or `--force`
  - Optional
  - This will force ignore any warning that needs user confirmation

## Usage ##

```bash
project_switcher develop ~/work/my-awesome-project -s -r -f
```
