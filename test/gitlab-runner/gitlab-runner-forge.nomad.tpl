job "gitlab-runner-forge" {
    datacenters = ["${datacenter}"]
    type = "service"

    vault {
        policies = ["forge"]
        change_mode = "restart"
    }
    group "gitlab-runner-server" {    
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
            port "gitlab-runner" { to = 8093 }
        }

        task "gitlab-register" {
            driver = "docker"

            config {
                image   = "${image}:${tag}"
                ports   = ["gitlab-runner"]
                command = "register"
                args [
                    "--non-interactive",
                    "--executor",
                    "docker",
                    "--docker-image",
                    "maven",
                    "--url",
                    "${external_url_protocole_gitlab}://${external_url_gitlab}",
                    "--registration-token",
                    "${token_gitlab-runner}",
                    "--description",
                    "runner docker java",
                    "--run-untagged=true",
                    "--locked=false",
                    "--access-level=not_protected"
                ]

                mount {
                    type = "volume"
                    target = "/etc/gitlab-runner"
                    source = "gitlab-runner-config"
                    readonly = false
                    volume_options {
                        no_copy = false
                        driver_config {
                            name = "pxd"
                            options {
                                io_priority = "high"
                                size = 1
                                repl = 2
                            }
                        }
                    }
                }
            }

            resources {
                cpu    = 1000
                memory = 1024
            }

            lifecycle {
                hook = "prestart"
                sidecar = "false"
            }
        } 
 
        task "gitlab-runner" {
            driver = "docker"

            config {
                image   = "${image}:${tag}"
                ports   = ["gitlab-runner"]
                mount {
                    type = "volume"
                    target = "/etc/gitlab-runner"
                    source = "gitlab-runner-config"
                    readonly = false
                    volume_options {
                        no_copy = false
                        driver_config {
                            name = "pxd"
                            options {
                                io_priority = "high"
                                size = 1
                                repl = 2
                            }
                        }
                    }
                }

                mount {
                    type = "bind"
                    target = "/var/run/docker.sock"
                    source = "/var/run/docker.sock"
                    readonly = false
                    bind_options {
                        propagation = "rshared"
                    }
                }
            }

            resources {
                cpu    = 1000
                memory = 1024
            }
            
            service {
                name = "$\u007BNOMAD_JOB_NAME\u007D"
                port = "gitlab-runner"
                check {
                    name     = "alive"
                    type     = "tcp"
                    interval = "60s"
                    timeout  = "10s"
                    failures_before_critical = 5
                    port     = "gitlab-runner"
                }
            }
        } 
    }
}