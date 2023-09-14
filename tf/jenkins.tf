resource "null_resource" "jenkins" {
  provisioner "local-exec" {
    command = <<EOT
        sleep 10
        kubectl create namespace jenkins
        kubectl apply -f ../jenkins
    EOT
  }

  depends_on = [
    null_resource.myapp
  ]
}