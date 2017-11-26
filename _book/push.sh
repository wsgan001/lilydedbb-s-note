#!/bin/bash

echo "Enter the comment: "
read comment

echo "git commit -a -m"${comment}
git commit -a -m"${comment}"

echo "git push origin master"
git push origin master

echo "finished! "