job "pcd2017" {
  region = "europe"
  datacenters = ["gce-west1", "france"]

  type = "service"

  update {
    stagger      = "30s"
    max_parallel = 1
  }

  group "webs" {
    count = 4

    restart {
      attempts = 3
      delay    = "30s"
    }

    task "frontend" {
      driver = "docker"

      config {
        image = "httpd"
      }

      service {
        port = "http"
      }

      resources {
        cpu    = 200
        memory = 64

        network {
          mbits = 100

          port "http" {
            static = 80
          }
        }
      }
    }
  }

  group "database" {
    count = 1

    restart {
      attempts = 3
      delay    = "30s"
    }

    constraint {
      attribute = "${node.class}"
      value     = "data"
    }

    constraint {
      attribute = "${node.datacenter}"
      value     = "france"
    }

    task "mongo" {
      driver = "docker"

      config {
        image = "mongo"
      }

      service {
        port = "mongo"
      }

      resources {
        cpu    = 500
        memory = 256

        network {
          mbits = 100

          port "mongo" {
            static = 27017
          }
        }
      }
    }
  }
}