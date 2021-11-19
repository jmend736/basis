function getor --argument val def
  if test -z $val
    echo $def
    return 1
  end
  echo $val
end
