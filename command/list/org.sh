#!/usr/bin/env bash
set -e

help() {
  cat <<EOF
Work seamlessly with GitHub Projects from the command line.

USAGE
  gh projects list org [flags]

FLAGS
  --help, -h  Show help for command
  --beta      Show beta projects

EXAMPLES
  $ gh projects list org
  $ gh projects list org --beta

LEARN MORE
  Use 'gh projects list org --help' for more information about a command.
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
        organization(login: \"${OWNER}\") {
          projectsNext(first: 100, after: \$endCursor) {
            nodes {
              title
            }
          }
        }
      }
    "
    TEMPLATE="
      {{- if .data.organization -}}
        {{- range \$node := .data.organization.projectsNext.nodes -}}
          {{- printf \"%s\n\" \$node.title -}}
        {{- end -}}
      {{- end -}}
    "
    exec gh api graphql -f query="${QUERY}" --paginate --template="${TEMPLATE}"
else
    QUERY="
      query(\$endCursor: String) {
        organization(login: \"${OWNER}\") {
          projects(first: 100, after: \$endCursor) {
            nodes {
              name
            }
          }
        }
      }
    "
    TEMPLATE="
      {{- if .data.organization -}}
        {{- range \$node := .data.organization.projects.nodes -}}
          {{- printf \"%s\n\" \$node.name -}}
        {{- end -}}
      {{- end -}}
    "
    exec gh api graphql -f query="${QUERY}" --paginate --template="${TEMPLATE}"
fi

