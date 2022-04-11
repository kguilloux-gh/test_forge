job "gitlab-runner-forge" {
    datacenters = ["${datacenter}"]
	type = "service"

    vault {
        policies = ["forge"]
        change_mode = "restart"
    }
    group "gitlab-runner-server" {    
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
            port "gitlab-runner" { to = 8093 }
        }
        
        task "gitlab-runner" {
            driver = "docker"

            template {
                change_mode = "restart"
                destination = "local/gitlab-runner-config.toml"
                data = <<EOH
concurrent = 2
check_interval = 0

[session_server]
  session_timeout = 1800
  
[[runners]]
  name = "ruby-2.7-docker"
  url = "https://CI/"
  token = "TOKEN"
  limit = 0
  executor = "docker"
  builds_dir = ""
  shell = ""
  environment = ["ENV=value", "LC_ALL=en_US.UTF-8"]
  clone_url = "http://gitlab.example.local"
EOH
            }

            config {
                image   = "${image}:${tag}"
                ports   = ["gitlab-runner"]
				volumes = ["/var/run/docker.sock:/var/run/docker.sock",
                           "local/gitlab-runner-config.toml:/etc/gitlab-runner/config.toml"]
            }
            resources {
                cpu    = 1000
                memory = 1024
            }
            
            service {
                name = "$\u007BNOMAD_JOB_NAME\u007D"
				port = "gitlab-runner"
                check {
                    name     = "alive"
                    type     = "tcp"
                    interval = "60s"
                    timeout  = "10s"
					failures_before_critical = 5
                    port     = "gitlab-runner"
                }
            }
        } 
    }
}