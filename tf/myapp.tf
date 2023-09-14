resource "null_resource" "myapp" {
  provisioner "local-exec" {
    command = <<EOT
        sleep 10
        kubectl create namespace stage
        helm install myapp-stage ../myapp/myapp-chart/ -n stage
    EOT
  }

  depends_on = [
    null_resource.monitoring
  ]
}