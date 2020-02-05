#github_version=$(cat github_version.txt)
#ftp_version=$(cat ftp_version.txt)
github_version=0.12.18
ftp_version=3.3.15
del_version=$(cat delete_version.txt)

if [ "$github_version" != "$ftp_version" ] 
then
    cd ..
    rm -rf terraform
    wget https://github.com/hashicorp/terraform/archive/v$github_version.zip
    unzip v$github_version.zip
    mv terraform-$github_version terraform
    cd terraform
    
    # This script is used by the Travis build to install a cookie for
    # go.googlesource.com so rate limits are higher when using `go get` to fetch
    # packages that live there.
    # See: https://github.com/golang/go/issues/12933
    bash scripts/gogetcookie.sh
    make tools
    make test
    go mod verify
    
    git config --global url.https://github.com/.insteadOf ssh://git@github.com/

    XC_OS=linux XC_ARCH=ppc64le make bin
    cd bin
    sudo chmod 777 terraform
    ./terraform -help
    #- make e2etest
    # website-test is temporarily disabled while we get the website build back in shape after the v0.12 reorganization
    #- make website-test
    mv terraform terraform-$github_version
    #if [[ "$github_version" > "$ftp_version" ]]
    #then
          #lftp -c "open -u $USER,$PASS ftp://oplab9.parqtec.unicamp.br; put -O /ppc64el/terraform/latest terraform-$github_version" 
          #lftp -c "open -u $USER,$PASS ftp://oplab9.parqtec.unicamp.br; rm /ppc64el/terraform/latest/terraform-$ftp_version" 
    #fi
    lftp -c "open -u $USER,$PASS ftp://oplab9.parqtec.unicamp.br; put -O /ppc64el/terraform terraform-$github_version" 
    #lftp -c "open -u $USER,$PASS ftp://oplab9.parqtec.unicamp.br; rm /ppc64el/terraform/terraform-$del_version" 
fi
