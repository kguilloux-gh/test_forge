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
#==============================================================================
# LTB Self Service Password
#
# Copyright (C) 2009 Clement OUDOT
# Copyright (C) 2009 LTB-project.org
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# GPL License: http://www.gnu.org/licenses/gpl.txt
#
#==============================================================================

#==============================================================================
# All the default values are kept here, you should not modify it but use
# config.inc.local.php file instead to override the settings from here.
#==============================================================================

#==============================================================================
# Configuration
#==============================================================================

# Debug mode
# true: log and display any errors or warnings (use this in configuration/testing)
# false: log only errors and do not display them (use this in production)
$debug = false;

# LDAP
{{ range service "ldap-forge" }}
$ldap_url = "ldap://{{ .Address }}:{{.Port}}";
{{ end }}
$ldap_starttls = false;
{{ with secret "forge/openldap" }}
$ldap_binddn = "cn=Manager,{{ .Data.data.ldap_root }}";
$ldap_bindpw = '{{ .Data.data.admin_password }}';
// for GSSAPI authentication, comment out ldap_bind* and uncomment ldap_krb5ccname lines
//$ldap_krb5ccname = "/path/to/krb5cc";
$ldap_base = "{{ .Data.data.ldap_root }}";
{{ end }}
$ldap_login_attribute = "uid";
$ldap_fullname_attribute = "cn";
$ldap_filter = "(&(objectClass=person)($ldap_login_attribute={login}))";
$ldap_use_exop_passwd = false;
$ldap_use_ppolicy_control = false;

# Active Directory mode
# true: use unicodePwd as password field
# false: LDAPv3 standard behavior
$ad_mode = false;
# Force account unlock when password is changed
$ad_options['force_unlock'] = false;
# Force user change password at next login
$ad_options['force_pwd_change'] = false;
# Allow user with expired password to change password
$ad_options['change_expired_password'] = false;

# Samba mode
# true: update sambaNTpassword and sambaPwdLastSet attributes too
# false: just update the password
$samba_mode = false;
# Set password min/max age in Samba attributes
#$samba_options['min_age'] = 5;
#$samba_options['max_age'] = 45;
#$samba_options['expire_days'] = 90;

# Shadow options - require shadowAccount objectClass
# Update shadowLastChange
$shadow_options['update_shadowLastChange'] = false;
$shadow_options['update_shadowExpire'] = false;

# Default to -1, never expire
$shadow_options['shadow_expire_days'] = -1;

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

# Prefix to use for salt with CRYPT
$hash_options['crypt_salt_prefix'] = "$6$";
$hash_options['crypt_salt_length'] = "6";

# USE rate-limiting by IP and/or by user
$use_ratelimit = false;
# dir for json db's (system default tmpdir)
#$ratelimit_dbdir = '/tmp';
# block attempts for same login ?
$max_attempts_per_user = 2;
# block attempts for same IP ?
$max_attempts_per_ip = 2;
# how many time to refuse subsequent requests ?
$max_attempts_block_seconds = "60";
# Header to use for client IP (HTTP_X_FORWARDED_FOR ?)
$client_ip_header = 'REMOTE_ADDR';

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
# Minimal special characters
$pwd_min_special = 0;
# Definition of special characters
$pwd_special_chars = "^a-zA-Z0-9";
# Forbidden characters
#$pwd_forbidden_chars = "?/{}][|`^~";
# Don't reuse the same password as currently
$pwd_no_reuse = true;
# Check that password is different than login
$pwd_diff_login = true;
# Check new passwords differs from old one - minimum characters count
$pwd_diff_last_min_chars = 0;
# Forbidden words which must not appear in the password
$pwd_forbidden_words = array();
# Forbidden ldap fields
#$obscure_failure_messages = array("mailnomatch");

# HTTP Header name that may hold a login to preset in forms
#$header_name_preset_login="Auth-User";

# The name of an HTTP Header that may hold a reference to an extra config file to include.
#$header_name_extra_config="SSP-Extra-Config";

# Cache directory
#$smarty_compile_dir = "/var/cache/self-service-password/templates_c";
#$smarty_cache_dir = "/var/cache/self-service-password/cache";

# Autres paramètres ANS
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


# Allow to override current settings with local configuration
if (file_exists (__DIR__ . '/config.inc.local.php')) {
    require __DIR__ . '/config.inc.local.php';
}

# Smarty
if (!defined("SMARTY")) {
    define("SMARTY", "/usr/share/php/smarty3/Smarty.class.php");
}

# Set preset login from HTTP header $header_name_preset_login
$presetLogin = "";
if (isset($header_name_preset_login)) {
    $presetLoginKey = "HTTP_".strtoupper(str_replace('-','_',$header_name_preset_login));
    if (array_key_exists($presetLoginKey, $_SERVER)) {
        $presetLogin = preg_replace("/[^a-zA-Z0-9-_@\.]+/", "", filter_var($_SERVER[$presetLoginKey], FILTER_SANITIZE_STRING, FILTER_FLAG_STRIP_HIGH));
    }
}

# Allow to override current settings with an extra configuration file, whose reference is passed in HTTP_HEADER $header_name_extra_config
if (isset($header_name_extra_config)) {
    $extraConfigKey = "HTTP_".strtoupper(str_replace('-','_',$header_name_extra_config));
    if (array_key_exists($extraConfigKey, $_SERVER)) {
        $extraConfig = preg_replace("/[^a-zA-Z0-9-_]+/", "", filter_var($_SERVER[$extraConfigKey], FILTER_SANITIZE_STRING, FILTER_FLAG_STRIP_HIGH));
        if (strlen($extraConfig) > 0 && file_exists (__DIR__ . "/config.inc.".$extraConfig.".php")) {
            require  __DIR__ . "/config.inc.".$extraConfig.".php";
        }
    }
}
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
				tags = [ "urlprefix-self-service-password.henix.asipsante.fr strip=/self-service-password" ]
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