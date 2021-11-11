#!/usr/bin/env bash
set -e

help() {
  cat <<EOF
Work seamlessly with GitHub Projects from the command line.

USAGE
  gh projects list user [<title>] [flags]

FLAGS
  --help, -h  Show help for command
  --beta      Show beta projects

EXAMPLES
  $ gh projects view user test-project
  $ gh projects list user test-project --beta

LEARN MORE
  Use 'gh projects list user --help' for more information about a command.
  Read the documentation at https://github.com/jnmiller-va/gh-projects
EOF
}

title=
if [ "${1:0:2}" == "--" ]; then
  help
  exit 0
else
  title=$1
  shift
fi

beta=false
while [ $# -gt 0 ]; do
  case "$1" in
  -h|--help)
    help
    exit 0
    ;;
  --beta)
    beta=true
    ;;
  *)
    help >&2
    exit 1
    ;;
  esac
  shift
done

OWNER=`gh repo view --json owner --jq .owner.login`
if [ $beta == true ]; then
    QUERY="
      query(\$endCursor: String) {
        viewer {
          projectsNext(first: 100, after: \$endCursor) {
            nodes {
              title
              url
            }
          }
        }
      }
    "
    exec gh api graphql -f query="${QUERY}" --paginate -q ".data.viewer.projectsNext.nodes[]? | select(.title==\"$title\")"
else
    QUERY="
      query(\$endCursor: String) {
        viewer {
          projects(first: 100, after: \$endCursor) {
            nodes {
              name
              url
            }
          }
        }
      }
    "
    exec gh api graphql -f query="${QUERY}" --paginate -q ".data.viewer.projects.nodes[]? | select(.name==\"$title\")"
fi
