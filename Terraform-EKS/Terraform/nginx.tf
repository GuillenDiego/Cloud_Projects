data "terraform_remote_state" "eks" {
  backend = "local"

  config = {
    path = "../Terraform/terraform.tfstate"
  }
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      data.aws_eks_cluster.cluster.name
    ]
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "eks-amati-app"
    labels = {
      App = "AmatiApp"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "AmatiApp"
      }
    }
    template {
      metadata {
        labels = {
          App = "AmatiApp"
        }
      }
      spec {
        container {
          image = "nginx:1.7.8"
          name  = "ati"

          port {
            container_port = 80
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}