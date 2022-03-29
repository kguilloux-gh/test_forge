job "gitlab-forge" {
    datacenters = ["${datacenter}"]
	type = "service"

    vault {
        policies = ["forge"]
        change_mode = "restart"
    }
    group "gitlab-server" {    
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
            port "gitlab" { to = 80 }
            port "gitlab-https" { to = 443 }
            port "gitlab-ssh" { to = 22 }
        }
        
        task "gitlab" {
            driver = "docker"

            config {
                image   = "${image}:${tag}"
                ports   = ["gitlab"]
				volumes = ["name=forge-gitlab-data,io_priority=high,size=5,repl=2:/var/opt/gitlab",
				           "name=forge-gitlab-logs,io_priority=high,size=2,repl=2:/var/log/gitlab",
				           "name=forge-gitlab-config,io_priority=high,size=2,repl=2:/etc/gitlab"]
                volume_driver = "pxd"
            }
            resources {
                cpu    = 1000
                memory = 16000
            }
            
            service {
                name = "$\u007BNOMAD_JOB_NAME\u007D"
                tags = ["urlprefix-/gitlab"]
				port = "gitlab"
                check {
                    name     = "alive"
                    type     = "http"
					path     = "/gitlab"
                    interval = "30s"
                    timeout  = "5s"
                    port     = "gitlab"
                }
            }
        } 
    }
}