project = "forge/gitlab-runner"

labels = { "domaine" = "forge" }

runner {
    enabled = true
    data_source "git" {
        url  = "https://github.com/kguilloux-gh/test_forge.git"
        ref  = "main"
        path = "test/gitlab-runner"
        ignore_changes_outside_path = true
    }
}

app "forge/gitlab-runner" {

    build {
        use "docker-pull" {
            image = var.image
            tag   = var.tag
            disable_entrypoint = true
        }
    }
  
    deploy{
        use "nomad-jobspec" {
            jobspec = templatefile("${path.app}/gitlab-runner-forge.nomad.tpl", {
            image   = var.image
            tag     = var.tag
            datacenter = var.datacenter
            external_url_gitlab_hostname = var.external_url_gitlab_hostname
            external_url_gitlab_protocole = var.external_url_gitlab_protocole
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
    default = "gitlab/gitlab-runner"
}

variable "tag" {
    type    = string
    default = "latest"
}

variable "external_url_gitlab_hostname" {
    type    = string
    default = "test"
}

variable "external_url_gitlab_protocole" {
    type    = string
    default = "https"
}