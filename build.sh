get_latest_release() {
  curl --silent "https://api.github.com/repos/hashicorp/terraform/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                                             # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                                     # Pluck JSON value
}

latest_version=`get_latest_release`
del_version=$(cat delete_version.txt)
ftp_version=$(cat ftp_version.txt)

if [ $latest_version != $ftp_version ]
then
    cd ..
    rm -rf terraform
    wget https://github.com/hashicorp/terraform/archive/v$latest_version.zip
    unzip v$latest_version.zip
    mv terraform-$latest_version terraform
    cd terraform
    XC_OS=linux XC_ARCH=ppc64le make bin
    cd bin
    mv terraform terraform-$latest_version
    then
          lftp -c "open -u $USER,$PASS ftp://oplab9.parqtec.unicamp.br; put -O /ppc64el/terraform/latest terraform-$latest_version" 
          lftp -c "open -u $USER,$PASS ftp://oplab9.parqtec.unicamp.br; rm /ppc64el/terraform/terraform-$ftp_version" 
    fi
    lftp -c "open -u $USER,$PASS ftp://oplab9.parqtec.unicamp.br; put -O /ppc64el/terraform terraform-$latest_version" 
    lftp -c "open -u $USER,$PASS ftp://oplab9.parqtec.unicamp.br; rm /ppc64el/terraform/terraform-$del_version" 
fi
