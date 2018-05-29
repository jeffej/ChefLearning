# ChefLearning
This is a public GIThub repo to allow everyone view access but only Jeff and Scott to colaberate on Learning Chef

Notes and instructions on how to learn Chef using AWS EC2 as the example node 
(AWS CLI required)

<br>
<br>
Create AWS resources
STEP 1
//Create a Security Group <br>
//Input: group name, description, VPC id <br>
//Output: json  - SG-1234abcd<br>
```
aws ec2 create-security-group --group-name chef-test --description "Chef Test" --vpc-id vpc-31XXXX4
```            
<br>
### STEP 2
//add inbound rule to security group <br>
//Input: SG id, protocol, port, and CIDR<br>
//Output: json <br>
```
aws ec2 authorize-security-group-ingress --group-name chef-test --protocol tcp --port 22 --cidr YOURwanIP/32
aws ec2 authorize-security-group-ingress --group-name chef-test --protocol tcp --port 80 --cidr YOURwanIP/32
aws ec2 authorize-security-group-ingress --group-name chef-test --protocol tcp --port 443 --cidr YOURwanIP/32
```
<br>
### STEP 3
//Describe a security group <br>
//Input: SG id<br>
//Output: json <br>
```
aws ec2 describe-security-groups --group-ids sg-0XXXXX5
```
<br>
### STEP 4
//Create EIP<br>
//Input: <br>
//Output: json - EIP id<br>
```
aws ec2 allocate-address --domain vpc
```
<br>
### STEP 5
//Create EC2 - (be sure to run aws config and set region to us-east-1)<br>
//Input: aim(chef test linux), instance count, type, aws keypair name, security groups, subnet<br>
//Output: json - of EC2 data<br>
```
aws ec2 run-instances --image-id ami-6d1c2007 --count 1 --instance-type t2.micro --key-name KEYPAIR --security-group-ids sg-0XXXXX5 --subnet-id subnet-XXXXXXX
```
<br>
### STEP 6
//Attach EIP<br>
//Input: instance id, and EIP id<br>
//Output: json - EIP association id<br>
```
aws ec2 associate-address --instance-id i-XXXXXXXXXXXXXX --allocation-id eipalloc-XXXXXXX
```
<br>
### STEP 7
// SSH Login <br>
```
ssh -i /Users/dir/keyfile.pem centos@ec2-XX-XX-XX-XX.compute-1.amazonaws.com
```
<br>
<br>
## Start using Chef
### STEP 1
//Chef Dev Install<br>
```
curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P chefdk -c stable -v 0.16.28
```
<br>
### STEP 2
//Create Chef Working Directory for your code in the home directory<br>
```
mkdir ~/chef-repo
cd ~/chef-repo
```
<br>
### STEP 3
//Chef Reource - Create Hello Word File - use a text edit vi/emacs/nano etc
```
vi hello.rb
```
PASTE INTO FILE:
```rb
file '/tmp/motd' do
  content 'hello world'
end
```

<br>
### STEP 4
//run chef locally 
```
sudo chef-client --local-mode hello.rb 
more /etc/motd
```

<br>
### STEP 5
//Chef Reource - Delete Hello Word File - use a text edit vi/emacs/nano etc
```
vi goodbye.rb
```
PASTE INTO FILE:
```rb
file '/tmp/motd' do
  action :delete
end
```

<br>
### STEP 6
//run chef locally
```
sudo chef-client --local-mode goodbye.rb 
more /etc/motd
```

<br>
### STEP 7
//Chef Package - Install HTTP - Start service and chkcnf ON - Create HTML file - use a text edit vi/emacs/nano etc
```
vi webserver.rb
```
PASTE INTO FILE:
```rb
package 'httpd'

service 'httpd' do
  action [:enable, :start]
end

file '/var/www/html/index.html' do
  content '<html>
  <body>
    <h1>hello world</h1>
  </body>
</html>'
end
```

<br>
### STEP 8
//run chef locally (make sure you run as root)
```
sudo chef-client --local-mode webserver.rb 
```

<br>
### STEP 9
//open the browser and point the EIP 
http://EIP

<br>
### STEP 10
//Create a directory for your chef cookbooks 
```
cd ~/chef-repo
mkdir cookbooks
```

<br>
### STEP 11
//run chef command to get a cookbook named learn_chef_httpd
```
chef generate cookbook cookbooks/learn_chef_httpd
```

<br>
### STEP 12
//explore the Chef cookbook directory structure (if you dont have tree installed - sudo yum install tree -y)
```
tree cookbooks
```

<br>
### STEP 13
//Create a index.html in your cookbook structure (index.html.erb is created under /learn_chef_httpd/templates)
```
chef generate template cookbooks/learn_chef_httpd index.html
```

<br>
### STEP 14
//text edit to update index.html.erb in cookbook directory /learn_chef_httpd/templates
PASTE INTO FILE:
```html
<html>
  <body>
    <h1>hello world - cookbook</h1>
  </body>
</html>
```


<br>
### STEP 15
//text edit to update default.rb in cookbook directory /learn_chef_httpd/recipes
PASTE INTO FILE:
```rb
package 'httpd'

service 'httpd' do
  action [:enable, :start]
end

template '/var/www/html/index.html' do
  source 'index.html.erb'
end
```

<br>
### STEP 16
//run the chef cookbook
```
sudo chef-client --local-mode --runlist 'recipe[learn_chef_httpd]'
```

<br>
### STEP 17
//open the browser and point the EIP 
http://EIP


<br>
## Terminate AWS resources
### STEP 1
//discontent EIP from instance
```
aws ec2 disassociate-address --association-id eipassoc-4XcXXX6
```

<br>
### STEP 2
//delete EIP
```
aws ec2 release-address --allocation-id eipalloc-X91XXXXXb6
```
<br>
### STEP 3
//terminate your test instances
```
aws ec2 terminate-instances --instance-ids i-0eXXXX4ecc3b1 
```

<br>
### STEP 4
//delete securit group
```
aws ec2 delete-security-group --group-name chef-test
```
