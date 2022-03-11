job "ldap24-forge" {
    datacenters = ["${datacenter}"]
	type = "service"

    vault {
        policies = ["forge"]
        change_mode = "restart"
    }
    group "ldap24-server" {    
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
            port "ldap" { to = 1389 }            
        }
        
        task "openldap24" {
            driver = "docker"


            config {
                image   = "${image}:${tag}"
                ports   = ["ldap"]
                volumes = ["name=forge-openldap2.4-conf,io_priority=high,size=2,repl=2:/etc/ldap/slapd.d",
				           "name=forge-openldap2.4-data,io_priority=high,size=2,repl=2:/var/lib/ldap"]
                volume_driver = "pxd"
            }
            resources {
                cpu    = 300
                memory = 512
            }
            
            service {
                name = "$\u007BNOMAD_JOB_NAME\u007D"
                tags = ["urlprefix-:389 proto=tcp"]
				port = "ldap"
                check {
                    name     = "alive"
                    type     = "tcp"
                    interval = "30s"
                    timeout  = "5s"
                    port     = "ldap"
                }
            }
        } 
    }
}