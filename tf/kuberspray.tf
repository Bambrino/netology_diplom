resource "null_resource" "wait" {
  provisioner "local-exec" {
    command = "sleep 30"
  }

  depends_on = [
    local_file.hosts
  ]
}

resource "null_resource" "conf_local" {
  provisioner "local-exec" {
    command = "sed -i '/# kubeconfig_localhost: false/c\\kubeconfig_localhost: true' inventory/mykubecl/group_vars/k8s_cluster/k8s-cluster.yml"
    working_dir = "../kuberspray"
  }

  depends_on = [
    null_resource.wait
  ]
}

resource "null_resource" "cluster" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory/mykubecl/hosts.yaml  --private-key=${var.ssh_private_key} --become --become-user=root cluster.yml"
    working_dir = "../kuberspray"
  }

  depends_on = [
    null_resource.conf_local
  ]
}

resource "null_resource" "conf_copy" {
  provisioner "local-exec" {
    command = <<EOT
      cp ../kuberspray/inventory/mykubecl/artifacts/admin.conf $HOME/.kube/config
      sed -i 's/${yandex_compute_instance.master01.network_interface.0.ip_address}/${yandex_compute_instance.master01.network_interface.0.nat_ip_address}/g' $HOME/.kube/config
    EOT
  }

  depends_on = [
    null_resource.cluster
  ]
}