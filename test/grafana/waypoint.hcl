project = "supervision/grafana"

labels = { "domaine" = "supervision" }

runner {
    enabled = true
    data_source "git" {
        url  = "https://github.com/kguilloux-gh/test_forge.git"
        ref  = "main"
		path = "test/grafana"
		ignore_changes_outside_path = true
    }
}

app "supervision/grafana" {

    build {
        use "docker-pull" {
            image = "grafana/grafana"
            tag   = "latest"
	        disable_entrypoint = true
        }
    }
  
    deploy{
        use "nomad-jobspec" {
            jobspec = templatefile("${path.app}/grafana.nomad.tpl", {
            image   = "grafana/grafana"
            tag     = "latest"
            datacenter = var.datacenter
            })
        }
    }
}

variable "datacenter" {
    type    = string
    default = "henix_docker_platform_test"
}