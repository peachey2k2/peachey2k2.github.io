#!/bin/sh

cwd="$(dirname $0)"
cd $cwd

fileAppend() {
  echo "$1" >> "blog-list.ini"
}

toYearMonthDay() {
  x=""
  x+="$(echo $1 | head -c 10 | tail -c 4)"
  x+="$(echo $1 | head -c 5  | tail -c 2)"
  x+="$(echo $1 | head -c 2)"
  echo "$x"
}

echo "" > "blog-list.ini"
ls -1 "./blog" | while read file; do
  if (echo $file | grep "\.md\$" > "/dev/null"); then
    nameStripped="${file%.md}"
    nameHash=$(echo $nameStripped | md5sum | head -c 8)
    fileAppend "[$nameHash]"
    fileAppend "filename = $file"
    cat "blog/$file" | while read line; do
      if [[ "$line" == "---" ]]; then
        break
      fi
      fileAppend "$line"
    done     
    fileAppend ""
  fi
done




