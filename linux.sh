#!/bin/bash

# Functions to extract URLs
get_pipeline_url() {
    local provider=$1
    local repo_url=$2
    local branch=$3
    case $provider in
        "github")
            echo "https://github.com/${repo_url}/actions/workflows?query=branch%3A${branch}"
            ;;
        "gitlab")
            echo "https://gitlab.com/${repo_url}/-/pipelines?ref=${branch}"
            ;;
        "bitbucket")
            echo "https://bitbucket.org/${repo_url}/addon/pipelines/home#!/results/${branch}"
            ;;
        *)
            echo "Unknown provider: $provider"
            ;;
    esac
}

get_merge_request_url() {
    local provider=$1
    local repo_url=$2
    local branch=$3
    case $provider in
        "github")
            echo "https://github.com/${repo_url}/pulls?utf8=%E2%9C%93&q=is%3Apr+is%3Aopen+head%3A${branch}"
            ;;
        "gitlab")
            echo "https://gitlab.com/${repo_url}/-/merge_requests?scope=all&utf8=%E2%9C%93&state=opened&search=${branch}"
            ;;
        "bitbucket")
            echo "https://bitbucket.org/${repo_url}/pull-requests?&src=recent&search=${branch}"
            ;;
        *)
            echo "Unknown provider: $provider"
            ;;
    esac
}

get_repo_url() {
    local provider=$1
    local repo_url=$2
    case $provider in
        "github")
            echo "https://github.com/${repo_url}"
            ;;
        "gitlab")
            echo "https://gitlab.com/${repo_url}"
            ;;
        "bitbucket")
            echo "https://bitbucket.org/${repo_url}"
            ;;
        *)
            echo "Unknown provider: $provider"
            ;;
    esac
}

# Get the remote URL of the Git repository
remote_url=$(git config --get remote.origin.url)

# Get the current branch
current_branch=$(git symbolic-ref --short HEAD)

# Parse options
while getopts "pmr" opt; do
    case $opt in
        p)
            # Pipeline URL
            if [[ $remote_url == *"https://github.com"* ]]; then
                echo "Pipeline URL: $(get_pipeline_url github ${remote_url/https:\/\/github.com\//} $current_branch)"
            elif [[ $remote_url == *"https://gitlab.com"* ]]; then
                echo "Pipeline URL: $(get_pipeline_url gitlab ${remote_url/https:\/\/gitlab.com\//} $current_branch)"
            elif [[ $remote_url == *"https://bitbucket.org"* ]]; then
                echo "Pipeline URL: $(get_pipeline_url bitbucket ${remote_url/https:\/\/bitbucket.org\//} $current_branch)"
            else
                echo "Unsupported URL format: $remote_url"
            fi
            ;;
        m)
            # Merge Request URL
            if [[ $remote_url == *"https://github.com"* ]]; then
                echo "Merge Request URL: $(get_merge_request_url github ${remote_url/https:\/\/github.com\//} $current_branch)"
            elif [[ $remote_url == *"https://gitlab.com"* ]]; then
                echo "Merge Request URL: $(get_merge_request_url gitlab ${remote_url/https:\/\/gitlab.com\//} $current_branch)"
            elif [[ $remote_url == *"https://bitbucket.org"* ]]; then
                echo "Merge Request URL: $(get_merge_request_url bitbucket ${remote_url/https:\/\/bitbucket.org\//} $current_branch)"
            else
                echo "Unsupported URL format: $remote_url"
            fi
            ;;
        r)
            # Repository URL
            if [[ $remote_url == *"https://github.com"* ]]; then
                echo "Repository URL: $(get_repo_url github ${remote_url/https:\/\/github.com\//})"
            elif [[ $remote_url == *"https://gitlab.com"* ]]; then
                echo "Repository URL: $(get_repo_url gitlab ${remote_url/https:\/\/gitlab.com\//})"
            elif [[ $remote_url == *"https://bitbucket.org"* ]]; then
                echo "Repository URL: $(get_repo_url bitbucket ${remote_url/https:\/\/bitbucket.org\//})"
            else
                echo "Unsupported URL format: $remote_url"
            fi
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            ;;
    esac
done
