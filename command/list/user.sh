#!/usr/bin/env bash
set -e

help() {
  cat <<EOF
Work seamlessly with GitHub Projects from the command line.

USAGE
  gh projects list user [flags]

FLAGS
  --help, -h  Show help for command
  --beta      Show beta projects

EXAMPLES
  $ gh projects list user
  $ gh projects list user --beta

LEARN MORE
  Use 'gh projects list user --help' for more information about a command.
  Read the documentation at https://github.com/jnmiller-va/gh-projects
EOF
}

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
            }
          }
        }
      }
    "
    TEMPLATE="
      {{- if .data.viewer -}}
        {{- range \$node := .data.viewer.projectsNext.nodes -}}
          {{- printf \"%s\n\" \$node.title -}}
        {{- end -}}
      {{- end -}}
    "
    exec gh api graphql -f query="${QUERY}" --paginate --template="${TEMPLATE}"
else
    QUERY="
      query(\$endCursor: String) {
        viewer {
          projects(first: 100, after: \$endCursor) {
            nodes {
              name
            }
          }
        }
      }
    "
    TEMPLATE="
      {{- if .data.viewer -}}
        {{- range \$node := .data.viewer.projects.nodes -}}
          {{- printf \"%s\n\" \$node.name -}}
        {{- end -}}
      {{- end -}}
    "
    exec gh api graphql -f query="${QUERY}" --paginate --template="${TEMPLATE}"
fi
