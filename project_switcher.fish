function __switch_to_branch -a branch directory parentDir _flag_reset _flag_stash
  # Get directory name and output to user
  set DIR_NAME (string split -r -m1 / $directory | string trim)[2]
  echo "💃 ($DIR_NAME) is a git repository, switching..."
  
  # Move to directory
  cd $directory

  # Make sure local repository is updated
  git pull &>/tmp/pull_buffer
  wait $last_pid
  git fetch &>/tmp/fetch_buffer
  wait $last_pid

  # Get remote branch
  set REMOTE_BRANCH (git ls-remote --heads origin $branch)

  # Check if remote branch exists or not
  if test -z "$REMOTE_BRANCH"
    echo \t"👎 Repoistory does not have this remote branch ($branch)"
  else
    # Check if the stash flag is not empty
    if not test -z "$_flag_stash"
      echo \t"✍  Stashing local changes..."
      git stash &>/tmp/stash_buffer
      wait $last_pid
    end

    # Check if the reset flag is not empty
    if not test -z "$_flag_reset"
      echo \t"🗑  Hard resetting project files and changes..."
      git reset --hard &>/tmp/reset_buffer
      wait $last_pid
    end

    # Switch to the passed branch
    git checkout $branch &>/tmp/checkout_buffer
    echo \t"👍 Repoistory switched to ($branch)"
    wait $last_pid
  end

  # Move to parent directory
  cd $parentDir
end

function read_confirm
  while true
    read -l -P '⛔ You are about to hard reset each repository in this directory, are you sure? [y/N] ' confirm

    switch $confirm
      case Y y
        return 0
      case '' N n
        return 1
    end
  end
end

function project_switcher -a branch projectPath --description "Switch a whole project repositories that fall under 1 directory to a certain branch"
  set CURRENT_DIR (pwd) # Check if no arguments were passed
  if test (count $argv) -lt 1
    echo "👊 You must specify at least the git branch, exiting 👊"
    return 1
  end
  
  # Calculate execution start time
  set START_TS (date +%s)

  # Prepare the options
  set --global options 'h/help' 'r/reset' 's/stash' 'f/force'

  # Parse incoming options by fish's argparse
  argparse $options -- $argv

  # In case help flag is called
  if set --query _flag_help
    printf "Usage: project_switcher [ARGUMENTS] [OPTIONS]\n\n"
    printf "Arguments:\n"
    printf "  branch          Branch name that repositories should switch to (e.g. develop)\n"
    printf "  projectPath     The parent directory that contains all the repositories (default pwd)\n"
    printf "Options:\n"
    printf "  -h/--help       Prints help and exits\n"
    printf "  -r/--reset      Hard reset any changes before switching to the new branch (not tested)\n"
    printf "  -s/--stash      Stash any local changes before switching to the new branch\n"
    printf "  -f/--force      Bypass ANY warning message\n"
    return 0
  end

  # Check if project path was passed
  if test -z "$projectPath"
    echo "🤞 Project path was not specified, executing on current directory 🤞"\n
    set PROJECT_PATH "./"
  else
    set PROJECT_PATH $projectPath
  end

  if not test -z "$_flag_reset"; and test -z "$_flag_force"
    if read_confirm
      echo "🚶Okay, BTW you can use '-f' to bypass this warning in the future..."
    else
      set _flag_reset ''
    end
  end

  # Start looping over path directories
  for directory in $PROJECT_PATH/*
    set GIT_DIRECTORY "$directory/.git"
    # Check if this directory contains a `.git` directory which is not empty
    if begin test -d $directory; and test -e $GIT_DIRECTORY; and test -s $GIT_DIRECTORY; end
      __switch_to_branch $branch $directory $CURRENT_DIR "$_flag_reset" "$_flag_stash"
      echo \n
    end
  end

  # Calculate the execution end time
  set END_TS (date +%s)
  set RUNTIME (math $END_TS - $START_TS)
  set RUNTIME (math $RUNTIME)
  echo "----------------------------------------"
  echo "⌛ Total runtime: $RUNTIME seconds ⌛"
end
