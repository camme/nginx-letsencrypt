CONTENT=$(cat test-size.conf | grep server_name)
echo $CONTENT
re='.*server_name(.*);'
[[ $CONTENT =~ $re ]]
HOSTS=${BASH_REMATCH[1]}
echo $HOSTS
