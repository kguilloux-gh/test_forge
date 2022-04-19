project = "forge/gitlab"

labels = { "domaine" = "forge" }

runner {
    enabled = true
    data_source "git" {
        url  = "https://github.com/kguilloux-gh/test_forge.git"
        ref  = "main"
        path = "test/gitlab-server"
        ignore_changes_outside_path = true
    }
}

app "forge/gitlab" {

    build {
        use "docker-pull" {
            image = var.image
            tag   = var.tag
            disable_entrypoint = true
        }
    }
  
    deploy{
        use "nomad-jobspec" {
            jobspec = templatefile("${path.app}/gitlab-forge.nomad.tpl", {
            image   = var.image
            tag     = var.tag
            datacenter = var.datacenter
            external_url_gitlab = var.external_url_gitlab
            external_url_protocole_gitlab = var.external_url_protocole_gitlab
            })
        }
    }
}

variable "datacenter" {
    type    = string
    default = "test"
}

variable "image" {
    type    = string
    default = "gitlab/gitlab-ce"
}

variable "tag" {
    type    = string
    default = "latest"
}

variable "external_url_gitlab" {
    type    = string
    default = "test"
}

variable "external_url_protocole_gitlab" {
    type    = string
    default = "https"
}