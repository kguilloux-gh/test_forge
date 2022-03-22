job "rhodecode" {
  datacenters = ["${datacenter}"]
  type = "service"

  group "rhodecode" {
    count = 1
    constraint {
       attribute = "$\u007Bnode.class\u007D"
       value     = "data"
    }
    restart {
      attempts = 3
      delay    = "30s"
      interval = "5m"
      mode     = "fail"
    }
    update {
      max_parallel      = 1
      health_check      = "checks"
      min_healthy_time  = "10s"
      healthy_deadline  = "15m"
      progress_deadline = "20m"
    }
    network {
      port "ui" {
        to = 5000
      }
    }
    service {
        port = "ui"
        tags = ["urlprefix-:5000 proto=tcp"]
        check {
          port     = "ui"
          type     = "http"
          path	   = "/_admin/login"
          interval = "60s"
          timeout  = "5s"
        }
    }
    task "rhodecode-ce" {
      driver = "docker"

      env {
        CURL_NIX_FLAGS = "-x http://${proxy_host}:${proxy_port}"
        https_proxy    = "http://${proxy_host}:${proxy_port}"
        HTTPS_PROXY    = "http://${proxy_host}:${proxy_port}"
        no_proxy       = "localhost,127.0.0.0/8,10.0.0.0/8,172.17.0.0/12"
      }

      config {
        image   = "${rhodecode_ce_name_image_docker}:${rhodecode_ce_version_image_docker}"
        ports   = ["ui"]
		volumes = [
                   "name=${name_volume_db},io_priority=high,size=${size_volume_db},repl=3:/var/lib/postgresql",
                   "name=${name_volume_repos},io_priority=high,size=${size_volume_repos},repl=3:/root/my_dev_repos",
                   "name=rhodecode-apache-mod-dav,io_priority=high,size=1,repl=3:/rhodecode-develop/rhodecode-enterprise-ce/configs/mod-dav",
                   "name=rhodecode-data,io_priority=high,size=1,repl=3:/rhodecode-develop/rhodecode-enterprise-ce/configs/data"
                 ]
		volume_driver = "pxd"
      }
      # resource config
      resources {
        cpu    = ${cpu}
        memory = ${memory}
      }
    }
  }
}
