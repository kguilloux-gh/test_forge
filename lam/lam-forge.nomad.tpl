job "lam-forge" {
    datacenters = ["${datacenter}"]
	type = "service"

    vault {
        policies = ["forge"]
        change_mode = "restart"
    }
    group "lam-server" {    
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
            port "lam" { to = 8080:80 }            
        }
        
        task "lam" {
            driver = "docker"
            template {
                data = <<EOH
LAM_SKIP_PRECONFIGURE=false
LDAP_SERVER="ldap://hostname:389"
LAM_LANG="fr_FR"
LDAP_DOMAIN="asipsante.fr"
LDAP_BASE_DN="dc=asipsante,dc=fr"
ADMIN_USER="cn=Manager,${LDAP_BASE_DN}"
LDAP_USERS_DN="ou=people,${LDAP_BASE_DN}"
LDAP_GROUPS_DN="ou=groups,${LDAP_BASE_DN}"
LDAP_USER="cn=Manager,${LDAP_BASE_DN}"
{{ with secret "forge/openldap" }}
LDAP_ADMIN_PASSWORD={{ .Data.data.admin_password }}
LAM_PASSWORD={{ .Data.data.password }}
{{ end }}
                EOH
                destination = "secrets/file.env"
                change_mode = "restart"
                env = true
            }

            config {
                image   = "${image}:${tag}"
                ports   = ["lam"]
                volume_driver = "pxd"
            }
            resources {
                cpu    = 300
                memory = 512
            }
            
            service {
                name = "$\u007BNOMAD_JOB_NAME\u007D"
                port = "lam"
                check {
                    name     = "alive"
                    type     = "tcp"
                    interval = "30s"
                    timeout  = "5s"
                    port     = "lam"
                }
            }
        } 
    }
}