function git-last-change --argument commit
  git rev-list --pretty=format:'> %ar' $commit -1 | string replace -f '> ' ''
end
