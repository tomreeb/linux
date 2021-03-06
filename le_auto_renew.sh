#!/bin/bash
#
# usage: ./le_auto_renew.sh www.example.com
#
# alternatively, set up cron job: 
#         $ crontab -e
#         $ 30 18 * * 1 "/usr/local/bin/le_auto_renew.sh tomreeb.com" >> /var/log/letsencrypt.log
#
# I dunno... do I want to have it send me emails? ...maybe

service='haproxy'
domain=$1
combined_file="/etc/haproxy/certs/${domain}.pem"

le_path='/opt/letsencrypt'
exp_limit=30;

cert_file="/etc/letsencrypt/live/$domain/fullchain.pem"
key_file="/etc/letsencrypt/live/$domain/privkey.pem"
log_file="/var/log/letsencrypt.log"

# Check it the cert file exists
if [ ! -f $cert_file ]; then
	echo "[ERROR] certificate file not found for domain $domain." >> $log_file
fi

# Math
exp=$(date -d "`openssl x509 -in $cert_file -text -noout|grep "Not After"|cut -c 25-`" +%s)
datenow=$(date -d "now" +%s)
days_exp=$(echo \( $exp - $datenow \) / 86400 |bc)

echo "Checking expiration date for $domain..."

# The goods
if [ "$days_exp" -gt "$exp_limit" ] ; then
	echo "The certificate for $domain is up to date, no need for renewal ($days_exp days left)." 
	exit 0;
else
	# Do the thing
    echo "The certificate for $domain is about to expire soon. Starting Let's Encrypt for HAProxy renewal script..."
	$le_path/certbot-auto certonly -n --agree-tos --renew-by-default --standalone --pre-hook "systemctl stop $service.service" --post-hook "systemctl start $service.service" -d $domain
    # Combine cert and key
	echo "Creating $combined_file with latest certs..."
	sudo bash -c "cat /etc/letsencrypt/live/$domain/fullchain.pem /etc/letsencrypt/live/$domain/privkey.pem > $combined_file"
	echo "Renewal process finished for domain $domain"
	exit 0;
fi