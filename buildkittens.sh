#!/bin/sh
#
# buildkittens.sh
# Takes all of the out-of-sync files in the svn repo at ~/everyone,
# identifies the file "owner" based on majority-count of "svn blame",
# and generates diffs (as well as full copies) of those files prepended with
# the owner's user name.
#
# The output is gzipped in order to be used with buildkittens-mailer for sending notification emails.
#
# This file is NOT production ready. Use at your own risk.
#
cd ~/everyone
# find all out-of-sync files
for file in `svn status | grep "^M" | awk '{print $2}'`; 
do
    echo $file; 
    USER_LIST=""
    # build up a list of counts with the names of authors listed in svn blame on that file
    for user in `svn blame $file | awk '{print $2}' | sort | uniq`;
    do
	USER_LIST=$(echo -e $USER_LIST $(svn blame $file | grep $user | wc -l) $user XX)
    done
    # find the author based on majority-count of lines edited
    AUTHOR=$(echo $USER_LIST | sed 's/XX/\n/g' | sort -n | tail -n 1 | awk '{print $2}')
    echo $AUTHOR
    # generate the patches and the local copies.
    svn diff $file > ~/buildkittens/"$AUTHOR"_$(echo $file | sed 's/\//_/g').patch
    cat $file > ~/buildkittens/"$AUTHOR"_$(echo $file | sed 's/\//_/g').local_full
done
cd ~/buildkittens
# gzip it up to be sent to the computer with buildkittens-mailer on it
tar -cvzf foo.tar.gz $(echo $(find . -name "*.patch") $(find . -name *.local_full))
