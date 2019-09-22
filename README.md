Step:1 (Generatr SSH Key-pair)

The SSH key-pair files defined here will be used in the Terraform to connect to the EC2 instances with this credential. Intentionally, all components use the same certificate for ease of use, but you can have different ones if required.

$ ssh-keygen -t rsa -b 2048 -f ~/.ssh/MyKeyPair.pem -q -P ''
$ chmod 400 ~/.ssh/MyKeyPair.pem
$ ssh-keygen -y -f ~/.ssh/MyKeyPair.pem > ~/.ssh/MyKeyPair.pub
