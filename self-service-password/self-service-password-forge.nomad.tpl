job "self-service-password-forge" {
    datacenters = ["${datacenter}"]
	type = "service"

    vault {
        policies = ["forge"]
        change_mode = "restart"
    }
    group "self-service-password-server" {    
        count ="1"
        
        restart {
            attempts = 3
            delay = "60s"
            interval = "1h"
            mode = "fail"
        }

        network {
            port "self-service-password" { to = 81 }            
        }
        
        task "self-service-password" {
            driver = "docker"

            template {
                source = "config.inc.php.tp"
                destination = "var/www/conf/config.inc.php"
                change_mode = "restart"
            }
			
            config {
                image   = "${image}:${tag}"
                ports   = ["self-service-password"]
            }
            resources {
                cpu    = 300
                memory = 512
            }
            
            service {
                name = "$\u007BNOMAD_JOB_NAME\u007D"
				tags = [ "urlprefix-/self-service-password" ]
                port = "self-service-password"
                check {
                    name     = "alive"
                    type     = "http"
					path     = "/self-service-password"
                    interval = "30s"
                    timeout  = "5s"
                    port     = "self-service-password"
                }
            }
        } 
    }
}