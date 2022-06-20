job "grafana" {

    datacenters = ["${datacenter}"]
    type = "service"

    vault {
        policies = ["supervision"]
        change_mode = "restart"
    }

    group "grafana" {

        count ="1"

        restart {
            attempts = 3
            delay = "60s"
            interval = "1h"
            mode = "fail"
        }

        network {
            port "grafana" { to = 3000 }
        }

        task "grafana" {
            driver = "docker"

            template {
                data = <<EOH
{{ with secret "supervision/grafana" }}
GF_SECURITY_ADMIN_PASSWORD={{ .Data.data.grafana_password }}
{{ end }}
                EOH
                destination = "secrets/grafana-ans.env"
                change_mode = "restart"
                env = true
            }

            config {
                image   = "${image}:${tag}"
                ports   = ["grafana"]
                volumes = ["name=grafana-data,io_priority=high,size=2,repl=2:/var/lib/grafana"]
                volume_driver = "pxd"
            }

            resources {
                cpu    = 1000
                memory = 2000
            }
            
            service {
                name = "$\u007BNOMAD_JOB_NAME\u007D"
                tags = ["urlprefix-grafana.henix.asipsante.fr/"]
                port = "grafana"
                check {
                    name     = "alive"
                    type     = "http"
                    path     = "/"
                    interval = "30s"
                    timeout  = "5s"
                    port     = "grafana"
                }
            }
        }
    }
}