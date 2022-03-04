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
                destination = "local/config.inc.php"
                data = <<EOH
<?php
$ldap_url = "ldap://{{ .Address }}:{{.Port}}";
$ldap_binddn = "cn=Manager,dc=asipsante,dc=fr";
$ldap_bindpw = "password";
$ldap_base = "dc=asipsante,dc=fr";
$ldap_login_attribute = "uid";
$ldap_fullname_attribute = "cn";
$ldap_filter = "(&(objectClass=person)($ldap_login_attribute={login}))";
$ad_mode = false;
$ad_options['force_unlock'] = false;
$ad_options['force_pwd_change'] = false;
$samba_mode = false;
$shadow_options['update_shadowLastChange'] = false;
$hash = "SSHA";
$pwd_min_length = 8;
$pwd_max_length = 16;
$pwd_min_lower = 1;
$pwd_min_upper = 1;
$pwd_min_digit = 1;
$pwd_min_special = 0;
$pwd_special_chars = "^a-zA-Z0-9";
$pwd_forbidden_chars = "?/{}][|`^~";
$pwd_no_reuse = true;
$pwd_complexity = 0;
$pwd_show_policy = "never";
$pwd_show_policy_pos = "above";
$who_change_password = "user";
$use_questions = true;
$answer_objectClass = "extensibleObject";
$answer_attribute = "info";
$use_tokens = true;
$crypt_tokens = true;
$token_lifetime = "3600";
$mail_attribute = "mail";
$mail_from = "admin@example.com";
$notify_on_change = false;
$use_sms = true;
$sms_attribute = "mobile";
$smsmailto = "{sms_attribute}@service.provider.com";
$smsmail_subject = "Provider code";
$sms_message = "{smsresetmessage} {smstoken}";
$sms_token_length = 6;
$show_help = true;
$lang ="en";
$logo = "style/ltb-logo.png";
$debug = false;
$keyphrase = "secret";
$login_forbidden_chars = "*()&|";
$use_recaptcha = false;
$recaptcha_publickey = "";
$recaptcha_privatekey = "";
$recaptcha_theme = "white";
$recaptcha_ssl = false;
$default_action = "change";
?>
EOH
            }
			
            config {
                image   = "${image}:${tag}"
                ports   = ["self-service-password"]
            }
            resources {
                cpu    = 300
                memory = 512
            }
            
            service {
                name = "$\u007BNOMAD_JOB_NAME\u007D"
				tags = [ "urlprefix-/self-service-password strip=/self-service-password" ]
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