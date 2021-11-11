#!/usr/bin/env bash
set -e

help() {
  cat <<EOF
Work seamlessly with GitHub Projects from the command line.

USAGE
  gh projects list <command> [flags]

COMMANDS
  org:        List projects owned by organization
  user:       List projects owned by user

FLAGS
  --help, -h  Show help for command

EXAMPLES
  $ gh projects list org
  $ gh projects list user --beta

LEARN MORE
  Use 'gh projects list <command> --help' for more information about a command.
  Read the documentation at https://github.com/jnmiller-va/gh-projects
EOF
}

BASEDIR=$(dirname "$0")
echo "$BASEDIR"

if [ $1 == org ] || [ $1 == user ]; then
  command=$1
  shift
  exec $BASEDIR/list/$command.sh "$@"
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
