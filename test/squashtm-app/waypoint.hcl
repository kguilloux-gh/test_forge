project = "forge/squashtm-app"

labels = { "domaine" = "forge" }

runner {
    enabled = true
    data_source "git" {
        url  = "https://github.com/kguilloux-gh/test_forge.git"
        ref  = "main"
        path = "test/squashtm-app"
        ignore_changes_outside_path = true
    }
}

app "forge/squashtm-app" {

    build {
        use "docker-pull" {
            image = var.image
            tag   = var.tag
            disable_entrypoint = true
        }
    }
  
    deploy{
        use "nomad-jobspec" {
            jobspec = templatefile("${path.app}/forge-squashtm-premium.nomad.tpl", {
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
    default = "squashtest/squash-tm"
}

variable "tag" {
    type    = string
    default = "4.0.2"
}

variable "plugin_jaxb-api" {
    type    = string
    default = "jaxb-api-2.2.2.jar"
}

variable "plugin_jaxb-impl" {
    type    = string
    default = "jaxb-impl-2.2.3.jar"
}

variable "plugin_bugtracker-jiracloud" {
    type    = string
    default = "plugin.bugtracker.jiracloud-4.0.0.RELEASE.jar"
}