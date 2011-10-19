#!/bin/bash
 
echo "
                         #     #             
                         #    ##             
 #    #   #     #   ######     #     ######  
 #    #   #     #  #     #     #         #   
 #    #   #     #  #     #     #       ##    
  #####   #    ##  #     #     #      #      
      #    #### #   ######     #     ######  
  ####                                       

"
IPLOKAL=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`;
choice=4
 echo ""
 echo "ini IP server $IPLOKAL"
 echo ""
 echo "1. Domain + Apache"
 echo "2. Subdomain + Apache"
 echo "3. the creator"
 echo ""
 echo -n "Pilih opsi [1,2 or 3]? "
 echo ""
while [ $choice -eq 4 ]; do
 
read choice
if [ $choice -eq 1 ] ; then
 
echo "please input your IP ? "
read IP
echo "please input your domain ? ex : google.com"
read DOMAIN
echo "your domain is $DOMAIN"
echo 'zone "'$DOMAIN'" {
    type master;
    file "/etc/bind/'$DOMAIN'.db";
    };' >>/etc/bind/named.conf.local
echo ""
echo "your named is done"
echo ''$DOMAIN'.      IN      SOA     ns1.'$DOMAIN'. admin.'$DOMAIN'. (
                2006081401
                28800
                3600
                604800
                38400
)

'$DOMAIN'.      IN      NS              ns1.'$DOMAIN'.

www              IN      A       '$IP'
ns1              IN      A       '$IP'' > /etc/bind/$DOMAIN.db

echo ""
/etc/init.d/bind9 restart;
echo ""
echo "dns server sukses berat"

mkdir /var/www/$DOMAIN;
echo '<?php echo "halooo ini '$DOMAIN'" ?>' >/var/www/$DOMAIN/index.php

echo '
<VirtualHost '$IP':80>
ServerAdmin admin@'$DOMAIN'
ServerName '$DOMAIN'
ServerAlias www.'$DOMAIN'
DocumentRoot /var/www/'$DOMAIN'
ErrorLog /var/log/apache2/error-website.log
CustomLog /var/log/apache2/access-website.log combined
<Directory /var/www/'$DOMAIN'>
Options -Indexes FollowSymLinks MultiViews
AllowOverride None
Order allow,deny
allow from all
</Directory>
</VirtualHost>
' >/etc/apache2/sites-available/$DOMAIN

a2ensite $DOMAIN;
sed -e "s/*/$IPLOKAL/g" -i /etc/apache2/ports.conf
/etc/init.d/apache2 reload

echo ""
echo "your domain at $DOMAIN is ready"

else                   

        if [ $choice -eq 2 ] ; then

echo "please input your IP ? "
read IP
echo "please input your Domain ? ex: google.com"
read DOMAIN

if grep -q "$DOMAIN" "/etc/bind/named.conf.local" ; then
    echo "please input your subdomain, just sub the domain not necesassry ex: admin "
        read SUBDOMAIN

echo "your subdmain is $SUBDOMAIN.$DOMAIN"
echo ""
echo "your named is done"
echo "$SUBDOMAIN              IN      A       $IP" >> /etc/bind/$DOMAIN.db
/etc/init.d/bind9 restart;
echo ""
echo "dns server sukses berat"

mkdir /var/www/$DOMAIN/$SUBDOMAIN;
echo '<?php echo "halooo ini '$SUBDOMAIN.$DOMAIN'" ?>' >/var/www/$DOMAIN/$SUBDOMAIN/index.php

echo '
<VirtualHost '$IP':80>
ServerAdmin admin@'$DOMAIN'
ServerName '$SUBDOMAIN.$DOMAIN'
ServerAlias www.'$SUBDOMAIN.$DOMAIN'
DocumentRoot /var/www/'$DOMAIN'/'$SUBDOMAIN'
ErrorLog /var/log/apache2/error-website.log
CustomLog /var/log/apache2/access-website.log combined
<Directory /var/www/'$DOMAIN'/'$SUBDOMAIN'>
Options -Indexes FollowSymLinks MultiViews
AllowOverride None
Order allow,deny
allow from all
</Directory>
</VirtualHost>
' >/etc/apache2/sites-available/$SUBDOMAIN.$DOMAIN

a2ensite $SUBDOMAIN.$DOMAIN;
sed -e "s/*/$IPLOKAL/g" -i /etc/apache2/ports.conf
/etc/init.d/apache2 reload

echo ""
echo "your subdomain at $SUBDOMAIN.$DOMAIN is ready"
else
    echo "Not found"
fi
        else
         
                if [ $choice -eq 3 ] ; then
                        echo "yud1z"
                else
                        echo "Cuma 3 Opsi, oon lu!"
                        echo "1. Domain + Apache"
                        echo "2. Subdomain + Apache"
                        echo "3. the creator"
                        echo -n "Pilih opsi [1,2 or 3]? "
                        choice=4
                fi   
        fi
fi
done 
