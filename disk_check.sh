
set -e 
# cmd to check the disk utilistation
thershold=20
var=$(df -h | grep '/dev/root'| awk '{print $5 }'| tr -d '%')
# cmp the disk utlistation 
if [[ $var -ge $thershold ]];
then
 echo "Disk is having high utilistation on the server"
 # mailbody="Max usage have exceeded" 
 # echo "$mailbody" | mail -s "Disk Alert" "jai.deepika1994@gmail.com"
elif [[ $var -lt $thershold ]];
then
  echo "Disk is running without issues"
fi
