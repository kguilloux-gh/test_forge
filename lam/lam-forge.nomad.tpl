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
            port "lam" { to = 8080 }            
        }
        
        task "lam" {
            driver = "docker"
            template {
                data = <<EOH
LAM_SKIP_PRECONFIGURE=false
{{ range service "ldap-forge" }}
LDAP_SERVER="ldap://{{ .Address }}:{{.Port}}
{{ end }}
LAM_LANG="fr_FR"
{{ with secret "forge/lam" }}
LDAP_DOMAIN={{ .Data.data.domain }}
LDAP_BASE_DN={{ .Data.data.base_dn }}
{{ end }}
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
                    type     = "http"
                    interval = "30s"
                    timeout  = "5s"
                    port     = "lam"
                }
            }
        } 
    }
}