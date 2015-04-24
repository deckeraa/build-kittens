#!/bin/sh
cd ~/everyone
for file in `svn status | grep "^M" | awk '{print $2}'`; 
do
    echo $file; 
    USER_LIST=""
    for user in `svn blame $file | awk '{print $2}' | sort | uniq`;
    do
#	USER_LIST=$USER_LIST"`svn blame $file | grep $user | wc -l` $user `echo $'\n'`"
	USER_LIST=$(echo -e $USER_LIST $(svn blame $file | grep $user | wc -l) $user XX)
    done
    AUTHOR=$(echo $USER_LIST | sed 's/XX/\n/g' | sort -n | tail -n 1 | awk '{print $2}')
    echo $AUTHOR
    svn diff $file > ~/buildkittens/"$AUTHOR"_$(echo $file | sed 's/\//_/g').patch
    cat $file > ~/buildkittens/"$AUTHOR"_$(echo $file | sed 's/\//_/g').local_full
done
cd ~/buildkittens
# tar -cvzf $(date | sed 's/ /_/g').tar.gz $(echo $(find . -name "*.patch") $(find . -name *.local_full))
tar -cvzf foo.tar.gz $(echo $(find . -name "*.patch") $(find . -name *.local_full))