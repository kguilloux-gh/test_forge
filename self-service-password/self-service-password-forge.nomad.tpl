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
                destination = "secrets/config.inc.local.php"
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
$mail_address_use_ldap = true;
$mail_protocol = 'smtp';
$mail_smtp_debug = 3;
$mail_debug_format = 'html';
$mail_smtp_host = 'e-ac-smtp01';
$mail_smtp_auth = false;
$mail_smtp_user = '';
$mail_smtp_pass = '';
$mail_smtp_port = 25;
$mail_smtp_timeout = 30;
$mail_smtp_keepalive = false;
#$mail_smtp_secure = false;
$mail_smtp_autotls = false;
$mail_smtp_options = array();
$mail_contenttype = 'text/plain';
$mail_wordwrap = 0;
$mail_charset = 'utf-8';
$mail_priority = 3;
$hash = "SSHA";
$pwd_min_length = 8;
$pwd_max_length = 16;
$pwd_min_lower = 1;
$pwd_min_upper = 1;
$pwd_min_digit = 1;
$pwd_forbidden_chars = "?/{}][|`^~";
$keyphrase = "anssecret";
$background_image = "";
?>
EOH
            }
			
            config {
                image   = "${image}:${tag}"
                ports   = ["self-service-password"]
                volumes = ["secrets/config.inc.local.php:/var/www/conf/config.inc.local.php"]
            }
            resources {
                cpu    = 300
                memory = 512
            }
            
            service {
                name = "$\u007BNOMAD_JOB_NAME\u007D"
                tags = [ "urlprefix-self-service-password.forge.henix.asipsante.fr/" ]
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
