function ensure_enough_space_in_target()
{
  source=$(realpath $1)
  target=$(realpath $2)

  if [[ ! -d $source || ! -d $target ]];
  then
    echo "Source $source or target $target is not a directory. Out."
    return 1
  fi

  source_size=$(du -s $source | cut -f 1)
  space_in_target=$(df $target  --output=avail | tail -1)

  echo "Source size=$source_size,  target space=$space_in_target"
  if [[ $space_in_target -gt $source_size ]];
  then
    return 0
  fi

  echo "Target does not have enough space."
  return 1
}

