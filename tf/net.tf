# Network
resource "yandex_vpc_network" "mynet" {
  name = "${terraform.workspace}-mynet"
}

resource "yandex_vpc_subnet" "mysubnet01" {
  name = "${terraform.workspace}-subnet01"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.mynet.id}"
  v4_cidr_blocks = ["192.168.101.0/24"]
}

resource "yandex_vpc_subnet" "mysubnet02" {
  name = "${terraform.workspace}-subnet02"
  zone           = "ru-central1-b"
  network_id     = "${yandex_vpc_network.mynet.id}"
  v4_cidr_blocks = ["192.168.102.0/24"]
}

resource "yandex_vpc_subnet" "mysubnet03" {
  name = "${terraform.workspace}-subnet03"
  zone           = "ru-central1-c"
  network_id     = "${yandex_vpc_network.mynet.id}"
  v4_cidr_blocks = ["192.168.103.0/24"]
}
