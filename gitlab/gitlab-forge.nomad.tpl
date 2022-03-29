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
			
            template {
                data = <<EOH
EXTERNAL_URL="http://gitlab.henix.asipsante.fr"
                EOH
                destination = "secrets/file.env"
                change_mode = "restart"
                env = true
            }

            template {
			    destination = "secrets/gitlab.ans.rb"
                data = <<EOH
                EOH
            }

            config {
                image   = "${image}:${tag}"
                ports   = ["gitlab", "gitlab-https", "gitlab-ssh"]
				volumes = ["name=forge-gitlab-data,io_priority=high,size=5,repl=2:/var/opt/gitlab",
				           "name=forge-gitlab-logs,io_priority=high,size=2,repl=2:/var/log/gitlab",
				           "name=forge-gitlab-config,io_priority=high,size=2,repl=2:/etc/gitlab",
                           "secrets/gitlab.ans.rb:/etc/gitlab/gitlab.rb"]
                volume_driver = "pxd"
            }
            resources {
                cpu    = 10000
                memory = 16000
            }
            
            service {
                name = "$\u007BNOMAD_JOB_NAME\u007D"
                tags = ["urlprefix-gitlab.henix.asipsante.fr"]
				port = "gitlab"
                check {
                    name     = "alive"
                    type     = "tcp"
                    interval = "60s"
                    timeout  = "10s"
					failures_before_critical = 5
                    port     = "gitlab"
                }
            }
        } 
    }
}