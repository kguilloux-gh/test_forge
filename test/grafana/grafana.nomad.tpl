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
            config {
                image   = "${image}:${tag}"
                ports   = ["grafana"]
            }

            resources {
                cpu    = 1000
                memory = 2000
            }
            
            service {
                name = "$\u007BNOMAD_JOB_NAME\u007D"
                tags = ["urlprefix-grafana/"]
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