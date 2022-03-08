job "self-service-password-forge" {
    datacenters = ["${datacenter}"]
	type = "service"

    vault {
        policies = ["forge"]
        change_mode = "restart"
    }
    group "self-service-password-server" {  
        count ="1"
        
        restart {
            attempts = 3
            delay = "60s"
            interval = "1h"
            mode = "fail"
        }

        network {
            port "self-service-password" { to = 80 }            
        }

        task "self-service-password" {
            driver = "docker"

            template {
                destination = "local/config.inc.local.php"
                data = <<EOH
<?php
# ANS configuration 

{{ range service "ldap-forge" }}
$ldap_url = "ldap://{{ .Address }}:{{.Port}}";
{{ end }}
{{ with secret "forge/openldap" }}
$ldap_binddn = "cn=Manager,{{ .Data.data.ldap_root }}";
$ldap_bindpw = '{{ .Data.data.admin_password }}';
$ldap_base = "{{ .Data.data.ldap_root }}";
{{ end }}

# Hash mechanism for password:
# SSHA, SSHA256, SSHA384, SSHA512
# SHA, SHA256, SHA384, SHA512
# SMD5
# MD5
# CRYPT
# clear (the default)
# auto (will check the hash of current password)
# This option is not used with ad_mode = true
$hash = "SSHA";

# Local password policy
# This is applied before directory password policy
# Minimal length
$pwd_min_length = 8;
# Maximal length
$pwd_max_length = 16;
# Minimal lower characters
$pwd_min_lower = 1;
# Minimal upper characters
$pwd_min_upper = 1;
# Minimal digit characters
$pwd_min_digit = 1;
# Forbidden characters
#$pwd_forbidden_chars = "?/{}][|`^~";

# Encryption, decryption keyphrase, required if $use_tokens = true and $crypt_tokens = true, or $use_sms, or $crypt_answer
# Please change it to anything long, random and complicated, you do not have to remember it
# Changing it will also invalidate all previous tokens and SMS codes
$keyphrase = "anssecret";

# Background image
$background_image = "";
?>
EOH
            }
			
            config {
                image   = "${image}:${tag}"
                ports   = ["self-service-password"]
                volumes = ["local/config.inc.local.php:/var/www/conf/config.inc.local.php"]
            }
            resources {
                cpu    = 300
                memory = 512
            }
            
            service {
                name = "$\u007BNOMAD_JOB_NAME\u007D"
				tags = [ "urlprefix-self-service-password.henix.asipsante.fr" ]
                port = "self-service-password"
                check {
                    name     = "alive"
                    type     = "http"
					path     = "/"
                    interval = "30s"
                    timeout  = "5s"
                    port     = "self-service-password"
                }
            }
        } 
    }
}