# AI provider module bootstrap.

if (( ${+__GIT_WT_AI_LOADED} )); then
  return 0
fi

typeset -g __GIT_WT_AI_LOADED=1

# Get the ai module directory
local ai_dir=${0:A:h}

# Load provider implementations (skip bootstrap.zsh and providers.zsh)
setopt localoptions extendedglob
local provider_impl
for provider_impl in $ai_dir/*.zsh; do
  case ${provider_impl:t} in
    (bootstrap.zsh|providers.zsh)
      continue
      ;;
    (*)
      source "$provider_impl"
      ;;
  esac
done

# Load provider registry
source "$ai_dir/providers.zsh"
