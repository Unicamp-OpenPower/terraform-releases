import requests
# find and save the current Github release
html = str(
    requests.get('https://github.com/hashicorp/terraform/releases/latest')
    .content)
index = html.find('Release ')
github_version = html[index + 9:index + 17].replace('<', '').replace(' ', '').replace('\\', '').replace('x', '')
file = open('github_version.txt', 'w')
file.writelines(github_version)
file.close()

# find and save the current version on FTP server
html = str(
    requests.get(
        'https://oplab9.parqtec.unicamp.br/pub/ppc64el/terraform/'
    ).content)
index = html.rfind('terraform-')
ftp_version = html[index + 10:index + 17].replace('<', '').replace(' ', '').replace('\\', '').replace('x', '')
file = open('ftp_version.txt', 'w')
file.writelines(ftp_version)
file.close()

# find and save the oldest version on FTP server
index = html.find('terraform-')
delete = html[index + 10:index + 17].replace('<', '').replace(' ', '').replace('\\', '').replace('x', '')
file = open('delete_version.txt', 'w')
file.writelines(delete)
file.close()
