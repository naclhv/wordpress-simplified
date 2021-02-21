#!/bin/bash

full_path=$(dirname $(realpath ${BASH_SOURCE[0]}))
project_dir=$(basename $full_path)
cd $full_path
echo "$(date +"%Y-%m-%d %T"): $full_path/${BASH_SOURCE[0]}"

COMPOSE="/usr/local/bin/docker-compose --no-ansi"
$COMPOSE pause

for nv in `docker volume ls -q`
do
  if [[ $nv = ${project_dir}_db-data ]] || [[ $nv = ${project_dir}_wp-data ]]; then
    f=${nv//${project_dir}_/}
    echo -n "Backing up $f ..."
    docker run --rm \
      -v $nv:/data -v ${full_path}/internal/content-backups:/backup alpine \
      tar -cjf /backup/$f.tar.bz2 -C /data ./
    echo "done"
  fi
done

$COMPOSE unpause

tar_file_name=${project_dir}-backup-"`date +%F`".tar.bz2
rm ${project_dir}-backup-*.tar.bz2
cd ..
tar -cjf $tar_file_name $project_dir
mv $tar_file_name $project_dir 
echo "${project_dir} zipped as ${tar_file_name} in ${full_path}"
echo "to copy to another machine, run the following command from that machine:"
echo "    scp ${USER:-root}@$(hostname -I | cut -d' ' -f1):${full_path}/${tar_file_name} ."
echo "and to extract:"
echo "    tar -xjf ${tar_file_name}"
#echo "more ip addresses: $(hostname -I)"
