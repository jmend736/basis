function getor --description 'Return first non-empty argument'
  string match -r '.+' $argv | head -1
end
