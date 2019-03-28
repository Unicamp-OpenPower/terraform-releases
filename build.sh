get_latest_release() {
  curl --silent "https://api.github.com/repos/hashicorp/terraform/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                                             # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                                     # Pluck JSON value
}

github_version=$(cat github_version.txt)
del_version=$(cat delete_version.txt)
ftp_version=$(cat ftp_version.txt)

if [ $github_version != $ftp_version ]
then
    cd ..
    rm -rf terraform
    wget https://github.com/hashicorp/terraform/archive/v$github_version.zip
    unzip v$github_version.zip
    mv terraform-$github_version terraform
    cd terraform
    XC_OS=linux XC_ARCH=ppc64le make bin
    cd bin
    mv terraform terraform-$github_version
    then
          lftp -c "open -u $USER,$PASS ftp://oplab9.parqtec.unicamp.br; put -O /ppc64el/terraform/latest terraform-$github_version" 
          lftp -c "open -u $USER,$PASS ftp://oplab9.parqtec.unicamp.br; rm /ppc64el/terraform/terraform-$ftp_version" 
    fi
    lftp -c "open -u $USER,$PASS ftp://oplab9.parqtec.unicamp.br; put -O /ppc64el/terraform terraform-$github_version" 
    lftp -c "open -u $USER,$PASS ftp://oplab9.parqtec.unicamp.br; rm /ppc64el/terraform/terraform-$del_version" 
fi
