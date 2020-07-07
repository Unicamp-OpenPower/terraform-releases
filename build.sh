#github_version=$(cat github_version.txt)
#ftp_version=$(cat ftp_version.txt)
ftp_version=0.12.25
github_version=0.12.26
#del_version=$(cat delete_version.txt)

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
    #if [[ "$github_version" > "$ftp_version" ]]
    #then
    #      lftp -c "open -u $USER,$PASS ftp://oplab9.parqtec.unicamp.br; put -O /ppc64el/terraform/latest terraform-$github_version" 
    #      lftp -c "open -u $USER,$PASS ftp://oplab9.parqtec.unicamp.br; rm /ppc64el/terraform/latest/terraform-$ftp_version" 
    #fi
    lftp -c "open -u $USER,$PASS ftp://oplab9.parqtec.unicamp.br; put -O /ppc64el/terraform terraform-$github_version" 
    #lftp -c "open -u $USER,$PASS ftp://oplab9.parqtec.unicamp.br; rm /ppc64el/terraform/terraform-$del_version" 
fi
