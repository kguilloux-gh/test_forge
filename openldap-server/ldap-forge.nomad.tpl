job "ldap-forge" {
    datacenters = ["${datacenter}"]
	type = "service"

    vault {
        policies = ["forge"]
        change_mode = "restart"
    }
    group "ldap-server" {    
        count ="1"
        
        restart {
            attempts = 3
            delay = "60s"
            interval = "1h"
            mode = "fail"
        }
        
        constraint {
            attribute = "$\u007Bnode.class\u007D"
            value     = "data"
        }

        network {
            port "ldap" { to = 1389 }            
        }
        
        task "openldap" {
            driver = "docker"
            template {
                data = <<EOH
{{ with secret "forge/openldap" }}
LDAP_ADMIN_USERNAME={{ .Data.data.admin_username }}
LDAP_ADMIN_PASSWORD={{ .Data.data.admin_password }}
LDAP_ROOT={{ .Data.data.ldap_root }}
{{ end }}
                EOH
                destination = "secrets/file.env"
                change_mode = "restart"
                env = true
            }
            template {
                data = <<EOH
dn: olcDatabase{2}mdb,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to attrs=userPassword,shadowLastChange by self write by dn.base="cn=Manager,dc=asipsante,dc=fr" write by anonymous auth by * none
olcAccess: {1}to dn.base="" by * read
olcAccess: {2}to * by self write by dn="cn=Manager,dc=asipsante,dc=fr" write by * read
				EOH
                destination = "local/olcDatabase_config_oldAccess.ldif"
            }

            config {
                image   = "${image}:${tag}"
                ports   = ["ldap"]
                volumes = ["name=forge-openldap,io_priority=high,size=2,repl=2:/bitnami/openldap",
				           "local/olcDatabase_config_oldAccess.ldif:/ldifs/olcDatabase_config_oldAccess.ldif"]
                volume_driver = "pxd"
            }
            resources {
                cpu    = 300
                memory = 512
            }
            
            service {
                name = "$\u007BNOMAD_JOB_NAME\u007D"
                tags = ["urlprefix-:389 proto=tcp"]
				port = "ldap"
                check {
                    name     = "alive"
                    type     = "tcp"
                    interval = "30s"
                    timeout  = "5s"
                    port     = "ldap"
                }
            }
        } 
    }
}