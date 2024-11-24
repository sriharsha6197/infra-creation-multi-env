#!/bin/bash
sudo dnf install ansible -y | tee -a /tmp/userdata.log
dnf install python3.12-pip.noarch -y | tee -a /tmp/userdata.log
pip3.12 install botocore boto3 | tee -a /tmp/userdata.log
ansible-pull -i localhost, -U https://github.com/sriharsha6197/expense-ansible.git -e ansible_user=Centos -e ansible_password=DevOps321 -e role_name=${role_name} -e env=${env} expense.yaml | tee -a /tmp/userdata.log