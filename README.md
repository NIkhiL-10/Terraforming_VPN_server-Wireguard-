Prerequisites:

        1.AWS CLI 
        2.Terraform 
        3.Ansible 

Step:1 (Generate SSH Key-pair)

The SSH key-pair files defined here will be used in the Terraform to connect to the EC2 instances with this credential. Intentionally, all components use the same certificate for ease of use, but you can have different ones if required.

    $ ssh-keygen -t rsa -b 2048 -f ~/.ssh/MyKeyPair.pem -q -P ''

    $ chmod 400 ~/.ssh/MyKeyPair.pem  

    $ ssh-keygen -y -f ~/.ssh/MyKeyPair.pem > ~/.ssh/MyKeyPair.pub

Step:2 (Start Wireguard server)

Add client details:

Open "Terraforming_VPN_server-Wireguard/ansible/vars/main.yml" and paste below dictionary.

    wg_user_list:
      user_1: { username: "user_1", private_ip: "10.0.0.11", default_route: yes, wg_dns_enabled: yes, remove: no }
      
 You can edit or add the above elements in the list.
 And if you want to remove an user change [ remove:no --> remove:yes].

Then run:

    $ terraform apply 
    
in folder "Terraforming_VPN_server-Wireguard". 

After terraform apply is succesful we can see a file a client config file

      "Terraforming_VPN_server-Wireguard/ansible/${aws_instance.wireguard.public_ip}/etc/wireguard/${username}/wgo.conf"
      
is generated for each client.

step:3 (Start Wireguard client)

Install wiregurad(https://www.wireguard.com/install/) on client machine.

And replace file

    "/etc/wireguard/wg0.conf " 

with 

    "Terraforming_VPN_server-Wireguard/ansible/${aws_instance.wireguard.public_ip}/etc/wireguard/${username}/wgo.conf"

And then run:

    sudo wg-quick up wg0  
    
Now wireguard client is connected to wireguard server.

Adding and removing clients:

If you want add or remove clients to server then add or remove elements in 

    wg_user_list:
      user_1: { username: "user_1", private_ip: "10.0.0.11", default_route: yes, wg_dns_enabled: yes, remove: no } .
 
 And then in folder "Terraforming_VPN_server-Wireguard" run :
 
    echo "[wireguard]" | tee -a wireguard.ini;                                   
    echo ${aws_instance.wireguard.public_ip} ansible_user="ubuntu" ansible_ssh_private_key_file="~/.ssh/wireguard.pem"| tee -a wireguard.ini;
    export ANSIBLE_HOST_KEY_CHECKING=False;
    ansible-playbook -u "ubuntu" --private-key "~/.ssh/wireguard.pem" -i wireguard.ini -e @ansible/defaults/main.yml -e @ansible/vars/main.yml ansible/main.yml
    
 This updates the server config accordingly and if new client is added it fetches corresponding config files into 
 
      "Terraforming_VPN_server-Wireguard/ansible/${aws_instance.wireguard.public_ip}/etc/wireguard/${username}/wgo.conf"
  
