job "forge-squashtm-premium" {
    datacenters = ["${datacenter}"]
    type = "service"

    vault {
        policies = ["forge"]
        change_mode = "restart"
    }
    group "squashtm-server" {
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
            port "http" { to = 8080 }
        }

        task "squashtm" {
            driver = "docker"

            user ="squashtm"

            template {
                data = <<EOH
SQTM_DB_TYPE=postgresql
SQTM_DB_HOST={{ range service "forge-squashtm-postgresql" }}{{.Address}}{{ end }}
SQTM_DB_PORT={{ range service "forge-squashtm-postgresql" }}{{.Port}}{{ end }}
{{ with secret "forge/squashtm" }}
SQTM_DB_NAME={{ .Data.data.sqtm_db_name }}
SQTM_DB_USERNAME={{ .Data.data.sqtm_db_username }}
SQTM_DB_PASSWORD={{ .Data.data.sqtm_db_password }}
{{ end }}
                EOH
                destination = "secrets/file.env"
                change_mode = "restart"
                env = true
            }

            template {
                data = <<EOH
{{ with secret "forge/squashtm" }}{{ .Data.data.sqtm_licence }}{{ end }}
EOH
                destination = "secret/squash-tm.lic"
                change_mode = "restart"
            }

            template {
                change_mode = "restart"
                destination = "local/log4j2.xml"
                data = <<EOT
{{ with secret "forge/squashtm" }}{{.Data.data.log4j2}}{{end}}   
                EOT
            }

            config {
                image   = "${image}:${tag}"
                ports   = ["http"]
            
                mount {
                    type = "bind"
                    target = "/opt/squash-tm/plugins/license/squash-tm.lic"
                    source = "secret/squash-tm.lic"
                    readonly = false
                    bind_options {
                        propagation = "rshared"
                    }
                }
                mount {
                    type = "bind"
                    target = "/opt/squash-tm/conf/log4j2.xml"
                    source = "local/log4j2.xml"
                    readonly = true
                    bind_options {
                        propagation = "rshared"
                    }
                }
            }

            resources {
                cpu    = 600
                memory = 4096
            }
            
            service {
                name = "$\u007BNOMAD_JOB_NAME\u007D"
                tags = ["urlprefix-squash.forge.henix.asipsante.fr/"]
                port = "http"
                check {
                    name     = "alive"
                    type     = "http"
                    path     = "/squash"
                    interval = "60s"
                    timeout  = "5s"
                    port     = "http"
                }
            }

        } 
    }
}