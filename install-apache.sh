#!/bin/bash
              
# Install Apache
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Create .pem key file
touch /home/ec2-user/asad.pem

# Set the owner and group for the .pem file


cat <<EOF > /home/ec2-user/asad.pem
-----BEGIN RSA PRIVATE KEY-----
YOUR PRIVATE KEY

-----END RSA PRIVATE KEY-----
EOF

# Set permissions for the .pem file
chmod 400 /home/ec2-user/asad.pem

# Set the owner and group for the .pem file
chown ec2-user:ec2-user /home/ec2-user/asad.pem


# Your original script
echo "<html><body><h1> WEB TIER SUCCESS </h1></body></html>" > /var/www/html/index.html
