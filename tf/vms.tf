resource "yandex_compute_instance" "master01" {
  name                      = "${terraform.workspace}-master01"
  zone                      = "${var.net_zones[0]}"
  hostname                  = "master01.${terraform.workspace}-kube.local"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id    = "${var.ubuntu_2004}"
      name        = "${terraform.workspace}-root-master01"
      type        = "network-ssd"
      size        = "20"
    }
  }

  network_interface {
    subnet_id  = "${yandex_vpc_subnet.mysubnet01.id}"
    nat        = true
    # ip_address = "192.168.101.10"
    ipv6       = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  scheduling_policy {
    preemptible = true
  }
}


resource "yandex_compute_instance" "node01" {
  name                      = "${terraform.workspace}-node01"
  zone                      = "${var.net_zones[0]}"
  hostname                  = "node01.${terraform.workspace}-kube.local"
  allow_stopping_for_update = true

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id    = "${var.ubuntu_2004}"
      name        = "${terraform.workspace}-root-node01"
      type        = "network-ssd"
      size        = "20"
    }
  }

  network_interface {
    subnet_id  = "${yandex_vpc_subnet.mysubnet01.id}"
    nat        = true
    # ip_address = "192.168.101.10"
    ipv6       = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_compute_instance" "node02" {
  name                      = "${terraform.workspace}-node02"
  zone                      = "${var.net_zones[1]}"
  hostname                  = "node02.${terraform.workspace}-kube.local"
  allow_stopping_for_update = true

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id    = "${var.ubuntu_2004}"
      name        = "${terraform.workspace}-root-node02"
      type        = "network-ssd"
      size        = "20"
    }
  }

  network_interface {
    subnet_id  = "${yandex_vpc_subnet.mysubnet02.id}"
    nat        = true
    # ip_address = "192.168.101.10"
    ipv6       = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  scheduling_policy {
    preemptible = true
  }
}


resource "yandex_compute_instance" "node03" {
  name                      = "${terraform.workspace}-node03"
  zone                      = "${var.net_zones[2]}"
  hostname                  = "node03.${terraform.workspace}-kube.local"
  allow_stopping_for_update = true

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id    = "${var.ubuntu_2004}"
      name        = "${terraform.workspace}-root-node03"
      type        = "network-ssd"
      size        = "20"
    }
  }

  network_interface {
    subnet_id  = "${yandex_vpc_subnet.mysubnet03.id}"
    nat        = true
    # ip_address = "192.168.101.10"
    ipv6       = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  scheduling_policy {
    preemptible = true
  }
}