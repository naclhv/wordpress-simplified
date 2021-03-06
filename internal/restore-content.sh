#!/bin/bash

full_path=$(realpath ${BASH_SOURCE[0]} | xargs dirname | xargs dirname)
project_dir=$(basename $full_path)
cd $full_path

for f in `cd ${full_path}/internal/content-backups/ && ls *.tar.bz2`
do
  nv="${project_dir}_${f%.tar.bz2}"
  echo -n "Restoring $nv ..."
  docker run -it --rm \
    -v $nv:/data -v ${full_path}/internal/content-backups:/backup alpine \
    sh -c "rm -rf /data/* /data/..?* /data/.[!.]* ; tar -C /data/ -xjf /backup/$f"
  echo "done"
done

