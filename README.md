# Wordpress Simplified

This project is a docker-compose installation of a Wordpress site, focusing on portability and ease-of-use. It features:
- Automated SSL certification through Let's Encrypt
- Automated cron scheduling of SSL certification renewal and site backup
- Complete portability - the site backup is a single file which can be used to redeploy anywhere
- Nginx as the web server
- MariaDB as the database

## How to use

To deploy or re-deploy a site:
- Make sure you have Docker Compose installed on your server.
- Set up your DNS/domain registrar, to point your domain to your server.
- Git pull the project (for a new site), or extract the backup tar file (for a previous site you want to re-deploy).
- Create a .env file specific to your site. The .env-example file has been included as a template.
- Run `sudo bash launch-site`. This will get the SSL certificate, launch the Wordpress site, and schedule regular site backups and SSL renewal.

To back up or migrate the site:
- Run `sudo bash backup-site.sh`. This will generate a file, named {directory_name}-backup-{date}.tar.bz2. This file is also generated through the regularly scheduled backups.
- Copy the file to a different machine, for backup storage or re-deployment. Note that the scheduled backup only generates the file; it is your responsibility to move it off-server.
