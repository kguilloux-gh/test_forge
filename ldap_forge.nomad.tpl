job "ldap_forge" {
    datacenters = ["${datacenter}"]
	  type = "service"
    
    group "ldap_manager_server" {    
        count ="1"
        
        restart {
            attempts = 3
	    delay = "60s"
	    interval = "1h"
	    mode = "fail"
        }
        update {
            max_parallel = 1
            health_check = "checks"
            min_healthy_time = "10s"
            healthy_deadline = "15m"
            progress_deadline = "20m"
        }
        network {
            mode "bridge"
            port "http" { to = 8080:80 }
        }
        
        task "ldap_account_manager" {
            driver = "docker"
            env {
                LAM_SKIP_PRECONFIGURE=true
                # Attention : Si le paramètre LAM_SKIP_PRECONFIGURE est passé à FALSE, il écrase tous les paramètres ci-dessous :
                LAM_PASSWORD=password
                LDAP_ADMIN_PASSWORD=adminpw
                LAM_LANG=fr_FR
                LDAP_SERVER=ldap://localhost:389
                LDAP_DOMAIN=asipsante.fr
                LDAP_BASE_DN=dc=asipsante,dc=fr
                ADMIN_USER=cn=Manager,${LDAP_BASE_DN}
                LDAP_USERS_DN=ou=people,${LDAP_BASE_DN}
                LDAP_GROUPS_DN=ou=groups,${LDAP_BASE_DN}
                LDAP_USER=cn=Manager,${LDAP_BASE_DN}                
            }
            config {
                image = "ldapaccountmanager/lam:latest"
            }
        }

    group "ldap_server" {    
        count ="1"
        
        restart {
            attempts = 3
	    delay = "60s"
	    interval = "1h"
	    mode = "fail"
        }
        update {
            max_parallel = 1
            health_check = "checks"
            min_healthy_time = "10s"
            healthy_deadline = "15m"
            progress_deadline = "20m"
        }
        network {
            mode "bridge"            
        }
        task "openldap" {
            driver = "docker"
            env {
                LDAP_ADMIN_USERNAME=admin
                LDAP_ADMIN_PASSWORD=adminpassword
                LDAP_USERS=customuser
                LDAP_PASSWORDS=custompassword
            }
            config {
                image = "bitnami/openldap:latest"
            }
        }
        
        resources {
            cpu = 100
            memory = 64
        }
    }
}
