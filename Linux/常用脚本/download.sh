
function download(){
    local url=$1
    local name=$2
    if command -v wget > /dev/null 2>&1; then
        wget $url -O $name
    elif command -v curl > /dev/null 2>&1; then
        curl -L -o $name $url
    else
        echo "error: wget/curl not found. cannot download"
        exit 1
    fi
}

# download https://codeload.github.com/TTcheng/React-HelloWorld/zip/master React-HelloWorld.zip
echo "Input a url:"
read targetUrl
echo "Input a save name:"
read targetName
download $targetUrl $targetName