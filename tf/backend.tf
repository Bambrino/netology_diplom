resource "yandex_iam_service_account" "sa-tf" {
    name      = "sa-tf"
}

resource "yandex_resourcemanager_folder_iam_member" "tf-editor" {
    folder_id = var.YC_FOLDER_ID
    role      = "storage.editor"
    member    = "serviceAccount:${yandex_iam_service_account.sa-tf.id}"
    depends_on = [yandex_iam_service_account.sa-tf]
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
    service_account_id = "${yandex_iam_service_account.sa-tf.id}"
    description        = "object access key"
}

resource "yandex_storage_bucket" "tf-state" {
    access_key = "${yandex_iam_service_account_static_access_key.sa-static-key.access_key}"
    secret_key = "${yandex_iam_service_account_static_access_key.sa-static-key.secret_key}"
    bucket = "bambrino-tf-state"
    acl    = "private"
    force_destroy = true
}

resource "local_file" "bcConfFile" {
  content  = <<EOT
endpoint = "storage.yandexcloud.net"
bucket = "${yandex_storage_bucket.tf-state.bucket}"
region = "ru-central1"
key = "terraform/terraform.tfstate"
access_key = "${yandex_iam_service_account_static_access_key.sa-static-key.access_key}"
secret_key = "${yandex_iam_service_account_static_access_key.sa-static-key.secret_key}"
skip_region_validation = true
skip_credentials_validation = true
EOT
  filename = "./backend.key"
}

resource "yandex_storage_object" "tfstate" {
    access_key = "${yandex_iam_service_account_static_access_key.sa-static-key.access_key}"
    secret_key = "${yandex_iam_service_account_static_access_key.sa-static-key.secret_key}"
    bucket = "${yandex_storage_bucket.tf-state.bucket}"
    key = "terraform.tfstate"
    source = "./terraform.tfstate.d/stage/terraform.tfstate"
    acl    = "private"
    depends_on = [yandex_storage_bucket.tf-state]
}

