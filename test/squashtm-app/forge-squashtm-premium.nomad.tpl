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
            port "squashtm" { to = 8090 }
        }
        
        task "squashtm" {
            driver = "docker"
            template {
                data = <<EOH
SQTM_DB_TYPE=postgresql
{{ range service "forge-squashtm-postgresql" }}
SQTM_DB_HOST={{ .Address }}
SQTM_DB_PORT={{.Port}}
{{ end }}
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

            config {
                image   = "${image}:${tag}"
                ports   = ["squashtm"]
                volumes = ["name=forge-squashtm-logs,io_priority=high,size=2,repl=2:/opt/squash-tm/logs"]
                volume_driver = "pxd"
            }
            resources {
                cpu    = 300
                memory = 512
            }
            
            service {
                name = "$\u007BNOMAD_JOB_NAME\u007D"
                tags = ["urlprefix-:8090 proto=tcp"]
                port = "squashtm"
                check {
                    name     = "alive"
                    type     = "tcp"
                    interval = "30s"
                    timeout  = "5s"
                    port     = "squashtm"
                }
            }
        } 
    }
}