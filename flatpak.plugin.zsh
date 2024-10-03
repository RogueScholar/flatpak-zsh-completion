alias fti="flatpak install"


_zsh_flatpak_get_available_apps(){
  # Get available apps/runtimes from all remotes
  apps=()
  remote_apps=($(_zsh_flatpak_command_output remote-ls $1))
  IFS=" "
  for app in ${remote_apps[@]}
  do
      apps+=("$app:$remote")
  done
  echo ${apps[@]}
}

_zsh_flatpak_command_output(){
  list=$(flatpak $@)
  output=()
  for app in $list
  do
    app=($(echo "${app}" | sort -u ))
    IFS=" "
    i=0
    for info in ${app[@]}
    do
      if [ $((i % 2)) = 0 ]; then
        output+=($info)
      fi
      i=$((i+1))
    done
  done
  echo ${output[@]}
}

_zsh_flatpak_get_installed() {
  apps=($(_zsh_flatpak_command_output list))
  _values ${apps[@]}
}

_zsh_flatpak_get_installed_apps() {
  apps=($(_zsh_flatpak_command_output list))
  installed=()
  j=0
  IFS=" "
  for app in ${apps[@]}
  do
    IFS='/'
    i=0
    if [ $((j % 2)) = 0 ]; then
      for info in $app:
      do
        if [ $i = 0 ]; then
          installed+=($info)
        fi
        i=$((i+1))
      done
      i=0
    fi
    j=$((j+1))
  done
  installed=($(echo "${installed[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
  _values ${installed[@]}
}

_zsh_flatpak_get_remotes() {
  remotes=($(_zsh_flatpak_command_output remotes))
  _values ${remotes[@]}
}


_zsh_flatpak_install_completion() {
  _install_arguments=(
    "--reinstall:Uninstall first if already installed" \
    "--user:Work on user installations" \
    "--system:Work on system-wide installations (default)" \
    "--installation:Work on a specific system-wide installation" \
    "--arch=ARCH:Arch to install for" \
    "--no-pull:Don't pull, only install from local cache" \
    "--no-deploy:Don't deploy, only download to local cache" \
    "--no-related:Don't install related refs" \
    "--no-deps:Don't verify/install runtime dependencies" \
    "--or-update:Normally install just ignores things that are already installed (printing a warning), but if --or-update is specified it silently turns it into an update operation instead" \
    "--include-sdk:For each app being installed, also installs the SDK that was used to build it" \
    "--include-debug:For each ref being installed, as well as all dependencies, also installs its debug info" \
    "--runtime:Look for runtime with the specified name" \
    "--sideload-repo=PATH:Adds an extra local ostree repo as a source for installation" \
    "--app:Look for app with the specified name" \
    "--bundle:Assume LOCATION is a .flatpak single-file bundle" \
    "--from:Assume LOCATION is a .flatpakref application description" \
    "--gpg-file=FILE:Check bundle signatures with GPG key from FILE (- for stdin)" \
    "--subpath=PATH:Only install this subpath" \
    "--assumeyes:Automatically answer yes for all questions" \
    "--noninteractive:Produce minimal output and avoid most questions" \
    "--verbose:Print debug information during command processing" \
    "--ostree-verbose:Print OSTree debug information during command processing"
  )
  _arguments $_install_arguments
}

_flatpak() {
  local -a _1st_arguments
  typeset -A opt_args
  _1st_arguments=(
    "install:Install an application or runtime" \
    "update:Update an installed application or runtime" \
    "uninstall:Uninstall an installed application or runtime" \
    "mask:Mask out updates and automatic installation" \
    "pin:Pin runtimes to prevent automatic removal" \
    "list:List installed apps and/or runtimes" \
    "info:Show info for installed app or runtime" \
    "history:Show history" \
    "config:Manage flatpak configuration" \
    "repair:Repair flatpak installation" \
    "create-usb:Copy apps and/or runtimes onto removable media" \
    "search:Search for applications and runtimes" \
    "run:Run an application" \
    "kill:Stop a running application" \
    "override:Override permissions for an application" \
    "make-current:Specify default version to run" \
    "enter:Enter the namespace of a running application" \
    "document-export:Grant an application access to a specific file" \
    "document-unexport:Revoke access to a specific file" \
    "document-info:Show information about a specific file" \
    "documents:List exported files" \
    "permission-remove:Remove item from permission store" \
    "permissions:List permissions" \
    "permission-show:Show app permissions" \
    "permission-reset:Reset app permissions" \
    "permission-set:Set app permissions" \
    "remotes:List all configured remotes" \
    "remote-add:Add a new remote repository (by URL)" \
    "remote-modify:Modify properties of a configured remote" \
    "remote-delete:Delete a configured remote" \
    "remote-ls:List contents of a configured remote" \
    "remote-info:Show information about a ref in a configured remote repository" \
    "build-init:Initialize a directory for building" \
    "build:Run a build command inside the build dir" \
    "build-finish:Finish a build dir for export" \
    "build-export:Export a build dir to a repository" \
    "build-bundle:Create a bundle file from a build directory" \
    "build-import-bundle:Import a bundle file" \
    "build-sign:Sign an application or runtime" \
    "build-update-repo:Update the summary file in a repository" \
    "build-commit-from:Create new commit based on existing ref" \
    "repo:Print information about a repo" \
    "spawn:Run a command in another sandbox" \
    "--help:Show help options" \
    "--version:Print version information and exit" \
    "--default-arch:Print default arch and exit" \
    "--supported-arches:Print supported arches and exit" \
    "--gl-drivers:Print active gl drivers and exit" \
    "--verbose:Print debug information during command processing" \
    "--ostree-verbose:Print OSTree debug information during command processing" \
    "--installations:Print paths of system installations and exit" \
    "--print-updated-env:Print the set of environment variables needed to use flatpaks, amending the current set of environment variables" \
    "--print-system-only:When the flatpak --print-updated-env command is run, only print the environment for system flatpak installations, not including the user’s home installation"
  )
  _arguments \
    "*:: :->subcmds" && return 0

  if (( CURRENT == 1 )); then
      _describe -t commands "flatpak subcommand" _1st_arguments
      return
  fi
  case "$words[1]" in
    update|uninstall|info|run)
      _zsh_flatpak_get_installed
    ;;
    override|make-current|enter)
      _zsh_flatpak_get_installed_apps
    ;;
    install)
        _zsh_flatpak_install_completion
    ;;
    remote-delete|remote-modify|remote-ls)
      _zsh_flatpak_get_remotes
    ;;
  esac
}

compdef _flatpak flatpak
