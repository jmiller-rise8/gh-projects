#!/usr/bin/env bash
set -e

help() {
  cat <<EOF
Work seamlessly with GitHub Projects from the command line.

USAGE
  gh projects view <command> [flags]

COMMANDS
  org:        View project owned by organization
  user:       View project owned by user

FLAGS
  --help, -h  Show help for command

EXAMPLES
  $ gh projects view org
  $ gh projects view user --beta

LEARN MORE
  Use 'gh projects view <command> --help' for more information about a command.
  Read the documentation at https://github.com/jnmiller-va/gh-projects
EOF
}

BASEDIR=$(dirname "$0")

if [ $1 == org ] || [ $1 == user ]; then
  command=$1
  shift
  exec $BASEDIR/view/$command.sh "$@"
fi

while [ $# -gt 0 ]; do
  case "$1" in
  -h|--help)
    help
    exit 0
    ;;
  *)
    help >&2
    exit 1
    ;;
  esac
  shift
done
