Docker Name : ans/rhodecode-ce

Description:
This image has been built from sstruss/rhodecode-ce:4.22.0
Apache has been added and configured to use svn.

Exposed Volumes to be used:
- /rhodecode-develop/rhodecode-enterprise-ce/configs -- for configuring your RhodeCode instance to your specific needs
- /var/lib/postgresql -- for having your Database in a safe place
- /root/my_dev_repos

Exposed Ports to be used:
- 5000 -- for accessing your RhodeCode instance

Default Credentials:
- Username: admin
- Password: secret

