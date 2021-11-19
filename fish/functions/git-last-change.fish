function git-last-change --argument fname
  git rev-list --pretty=format:'>%ar' HEAD -1 -- $fname | string replace -f '>' ''
end
