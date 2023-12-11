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
MIIEowIBAAKCAQEAz15OjAhnMbzY+fNJgLpc49lH/jbkFGG7W5GMVcw+V7lssSWN
DuKbF9tP3qlP0mzzv4/n1O0GMn+AZ4bYVMTThFIWvU1vQ2wlT/EiP4PTqB5Wrh4B
TEa2ON3yPNVZbaYbTk6gOarR2CDtsb3SwM7/vAIml22A2FsBHU60VI9cDS8Tuism
r4N2L7OhPx2Wptr8pZKmo9eUjDIKbDvxgSjLY+j5pFOjzr4ezDmPoeLEwDb0EiLF
UsOA/kNu0Bnrsig0BxJIPnftXc7AR5QZ8mUyfk8V51j4aaSBxFZkR/usm1WT/tKz
7IeCe8Jv26dREAuTnGkmZWdFTLBbEe6CKdqAowIDAQABAoIBAQDE8ujfDswT7SyW
mH5jCJ1YufEqfK+6u+faXC5Q/p7nanDU/rkuPgLXcbA15dCuJlSKx/6DuGp+Y6Js
sSGdwSKzNdPrDzRxcLEvb/H7KRVJQydIT68j5rUC5alAJdG91llw0jRTEO4ku4GF
oqgb/33b7p8AizwoQKaaUznqZg4jZa+3MGQf4+gE1gIKwgGGdQ6//EmasjbuphmY
9q8rajQuFxp9Qu+oGynpq8Y+58s9Xa2j2SpoqMv9VHe0+jXyi1qwSTBgO3IEm3Gi
EazQJozodnGUmZbCCA1ClcijxwyCkrHOUgMaS4N2ZesIihRYqLqeuUBTsKY+vsVY
i2coSG3hAoGBAPrFP4IlWfL1/7OtZVd+ezkwQRR8uqGyPRxHiHdB5v9pgEKcybLl
11nvLkp6YCFqtGCfGG8G6+lA05GeBlCJhboclIJGIT2cLVUfwp1cArbnWrCxu8Sj
2pDHCUNTD4SRf7+BcQsgL2k1YTVJyMW0SNwHmAYlIpLlrrNsp2pf7fNXAoGBANOx
Wq0LPVY+h/2wPKE9LKkZT1whcCcuAKzvFbmCr4NDB0VhvGTH42vKzxdgJN9tGPqH
CKIhL95CIcgQ6037b/clOSbhHCjjQEv9ioUeQmG7bhgjfPGXGs2Gn/spVn85Xdk5
PZeShfEG55kKPVExCC2GBxLwIS/UiR19XRK9TrmVAoGAadeI95hmP6resuqTpHso
7TlVrpz6dLbzHhV/Hr69Db5suTDN3OkvnLDb++ls243a9hEQUgQ83CVVZteo2KNC
wwu/DsEk1IkvhQczsBEewC4j1AIgO13hKUwot7a+DPkQTzcGDGkYObKjBcfPqspu
GhhGbQmNbyzsMKTCgJ5eo18CgYA3zpCF/+mKm++D3HsPUq48YfS+5/3GBmWdMWY7
woz8gKYhD1P4CY4Vs6CGnAz8balhGkoXW8JfyHVZZcRyiW+J6uE3M68VxFsF7XAg
CcscMqoiaPCeS+R//BaewtYPshLgmit3kuQGl3hkqwNhLRjnz2Z8ApvtHQ2Mnaj0
sL1ZRQKBgDTkdZF4zi2WohNKDlxcxVxjJ4N76KGra6sXh4kXs80A9QvStu90OQNy
9uVw1JrkDhM65Z//5EfvVYf7Qe8dnXQO2ZD7SxGcyd28Bpehup3m1G5JY4n+AEKh
7eUXl1QhlrVM8osMNRK+8n3+lEkqnX4QQ+vfnY1dnsupxf/jWWCl
-----END RSA PRIVATE KEY-----
EOF

# Set permissions for the .pem file
chmod 400 /home/ec2-user/asad.pem

# Set the owner and group for the .pem file
chown ec2-user:ec2-user /home/ec2-user/asad.pem


# Your original script
echo "<html><body><h1> WEB TIER SUCCESS </h1></body></html>" > /var/www/html/index.html