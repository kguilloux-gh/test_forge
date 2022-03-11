project = "forge/ldap"

labels = { "domaine" = "forge" }

runner {
    enabled = true
    data_source "git" {
        url  = "https://github.com/kguilloux-gh/test_forge.git"
        ref  = "main"
		path = "openldap-server"
		ignore_changes_outside_path = true
    }
}

app "forge/ldap" {

    build {
        use "docker-pull" {
            image = var.image
            tag   = var.tag
	        disable_entrypoint = true
        }
    }
  
    deploy{
        use "nomad-jobspec" {
            jobspec = templatefile("${path.app}/ldap-forge.nomad.tpl", {
            image   = var.image
            tag     = var.tag
            datacenter = var.datacenter
            })
        }
    }
}

variable "datacenter" {
    type    = string
    default = "henix_docker_platform_test"
}

variable "image" {
    type    = string
    default = "bitnami/openldap"
}

variable "tag" {
    type    = string
    default = "2.4.49"
}
