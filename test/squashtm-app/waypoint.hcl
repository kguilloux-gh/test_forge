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
            pluginjaxbapi = var.pluginjaxbapi
            pluginjaxbimpl = var.pluginjaxbimpl
            pluginbugtrackerjiracloud = var.pluginbugtrackerjiracloud
            servernamesquash = var.servernamesquash
            url_proxy_sortant_http_host = var.url_proxy_sortant_http_host
            url_proxy_sortant_https_host = var.url_proxy_sortant_https_host
            url_proxy_sortant_no_proxy = var.url_proxy_sortant_no_proxy
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

variable "pluginjaxbapi" {
    type    = string
    default = "jaxb-api-2.2.2.jar"
}

variable "pluginjaxbimpl" {
    type    = string
    default = "jaxb-impl-2.2.3.jar"
}

variable "pluginbugtrackerjiracloud" {
    type    = string
    default = "plugin.bugtracker.jiracloud-4.0.0.RELEASE.jar"
}

variable "servernamesquash" {
     type    = string
     default = "squash.forge.henix.asipsante.fr"
}

variable "url_proxy_sortant_http_host" {
    type    = string
    default = "c-ac-proxy01.asip.hst.fluxus.net"
}

variable "url_proxy_sortant_https_host" {
    type    = string
    default = "c-ac-proxy01.asip.hst.fluxus.net"
}

variable "url_proxy_sortant_http_port" {
    type    = string
    default = "3128"
}

variable "url_proxy_sortant_https_port" {
    type    = string
    default = "3128"
}

variable "url_proxy_sortant_no_proxy" {
    type    = string
    default = "\".asip.hst.fluxus.net|.esante.gouv.fr\""
}