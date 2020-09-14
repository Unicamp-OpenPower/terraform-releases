FTP_HOST='oplab9.parqtec.unicamp.br'
LOCALPATH=$TRAVIS_BUILD_DIR/terraform/bin
REMOTEPATH='/ppc64el/terraform'
ROOTPATH="~/rpmbuild/RPMS/ppc64le"
REPO1="/repository/debian/ppc64el/terraform"
REPO2="/repository/rpm/ppc64le/terraform"
github_version=$(cat github_version.txt)
ftp_version=$(cat ftp_version.txt)
del_version=$(cat delete_version.txt)

if [ "$github_version" != "$ftp_version" ] 
then
    wget https://github.com/hashicorp/terraform/archive/v$github_version.zip
    unzip v$github_version.zip
    mv terraform-$github_version terraform
    cd terraform
    bash scripts/gogetcookie.sh
    go mod verify
    make fmtcheck generate
    XC_OS=linux XC_ARCH=ppc64le bash scripts/build.sh
    cd bin
    sudo chmod 777 terraform
    ./terraform --version
    mv terraform terraform-$github_version
    git clone https://$USERNAME:$TOKEN@github.com/Unicamp-OpenPower/repository-scrips.git
    cd repository-scrips/
    chmod +x empacotar-deb.sh
    chmod +x empacotar-rpm.sh
    sudo mv empacotar-deb.sh $LOCALPATH
    sudo mv empacotar-rpm.sh $LOCALPATH
    cd $LOCALPATH
    sudo ./empacotar-deb.sh terraform terraform-$github_version $github_version " "
    sudo ./empacotar-rpm.sh terraform terraform-$github_version $github_version " " "Use Infrastructure as Code to provision and manage any cloud, infrastructure, or service."
    if [[ "$github_version" > "$ftp_version" ]]
    then
        lftp -c "open -u $USER,$PASS ftp://oplab9.parqtec.unicamp.br; put -O /ppc64el/terraform/latest terraform-$github_version"
        lftp -c "open -u $USER,$PASS ftp://oplab9.parqtec.unicamp.br; rm /ppc64el/terraform/latest/terraform-$ftp_version"
        lftp -c "open -u $USER,$PASS ftp://oplab9.parqtec.unicamp.br; put -O $REPO1 $LOCALPATH/terraform-$github_version-ppc64le.deb"
        lftp -c "open -u $USER,$PASS ftp://oplab9.parqtec.unicamp.br; put -O $REPO2 $ROOTPATH/terraform-$github_version-1.ppc64le.rpm"
    fi
    lftp -c "open -u $USER,$PASS ftp://oplab9.parqtec.unicamp.br; put -O /ppc64el/terraform terraform-$github_version" 
    lftp -c "open -u $USER,$PASS ftp://oplab9.parqtec.unicamp.br; rm /ppc64el/terraform/terraform-$del_version" 
fi
