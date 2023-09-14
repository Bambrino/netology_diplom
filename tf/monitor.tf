resource "null_resource" "monitoring" {
  provisioner "local-exec" {
    command = <<EOT
        sleep 10
        kubectl create namespace monitoring
        helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
        helm repo update
        helm install stable prometheus-community/kube-prometheus-stack --namespace=monitoring
    EOT
  }

  depends_on = [
    null_resource.conf_copy
  ]
}

# kubectl edit svc stable-grafana -n monitoring

# nodePort: 30080 (in ports section)
# type: NodePort

# UserName: admin
# Password: prom-operator