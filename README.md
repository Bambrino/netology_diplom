## Дипломный практикум в Yandex.Cloud


###### Листинг файлов
```
├── jenkins                 ##[Файлы для деплоя Jenkins]
│   ├── jenkins-env.yaml        [Переменные окружения]
│   ├── jenkins_sa.yml          [SA для Jenkins]
│   └── jenkins.yml             [Jenkins]

├── jenkins _pre            ##[Файлы для создания образа Jenkins]
│   ├── Dockerfile              [Dockerfile]
│   ├── config                 
│   │   └── casc.yaml            [Файл конфигурации Jenkins]
│   └── my_jobs                  
│       └──  mytask
│           └── config.xml       [подготовленный multibranch]

├── myapp                   ##[Файлы связанные с публикуемым приложением]
│   ├── Dockerfile              [Dockerfile]
│   ├── Jenkinsfile             [Jenkinsfile для размещение в репозитории]
│   ├── myapp-chart             [Директория чарта приложения для helm]
│   │   ├── Chart.yaml            [Чарт]
│   │   ├── templates             [Шаблоны]
│   │   │   ├── app-svc.yml           [Сервис]
│   │   │   └── app.yml               [Приложение]
│   │   └── values.yaml         [Параметры]
│   └── page                  [Файлы используемые nginx в приложении]
│       ├── index.html
│       └── smile.png

├── kuberspray [Kuberspray]

└── tf                    ##[Terraform]
    ├── backend.tf              [Создание бекэнда]
    ├── jenkins.tf              [Деплой Jenkins через kubectl
    ├── k_inventory.tf          [Генерация inventory для kuberspray
    ├── kuberspray.tf           [Установка параметра для локальной копии конфига кластера]
                                [Запуск ansible для утсановки кластера]
                                [Копирование конфига в $HOME/.kube/config с нужным IP адресом]
    ├── monitor.tf              [Установка kube-prometheus-stack через helm в namespace monitoring]
    ├── myapp.tf                [Установка приложения через helm]
    ├── net.tf                  [Создание сети и подсетей]
    ├── provider.tf             [Описание провайдера]
    ├── vars.tf                 [Файл используемых переменных]
    └── vms.tf                  [Создание ВМ]
```
---
### - Цели:
    - Этапы выполнения:
    - Создание облачной инфраструктуры
    - Создание Kubernetes кластера
    - Создание тестового приложения
    - Подготовка cистемы мониторинга и деплой приложения
    - Установка и настройка CI/CD

---

Для решения поставленных задач было использовано:
- terraform
- helm
- Docker

#####Предварительно были подготовлены образы для приложения:

1) Ссылка на образ https://hub.docker.com/repository/docker/bambrino/myapp/general тэг latest

```Dockerfile
FROM nginx:latest

ENV TZ=Europe/Moscow

ADD page /usr/share/nginx/html

EXPOSE 80
```

2) Собран образ jenkins с нужными конфигом, плагинами и multibranch задачей
[Файлы](./Jenkins_pre/)

Ссылка на образ https://hub.docker.com/repository/docker/bambrino/jenkins/general


##### Подготволен код для terraform



###### Запускаем terraform plan


```shell
$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.bcConfFile will be created
  + resource "local_file" "bcConfFile" {

...........
...........

  # yandex_vpc_subnet.mysubnet03 will be created
  + resource "yandex_vpc_subnet" "mysubnet03" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "stage-subnet03"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.103.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-c"
    }

Plan: 22 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```

###### Ошибок нет, запускаем:

```shell
$ terraform apply --auto-approve
```
..........
```shell
null_resource.jenkins (local-exec): clusterrole.rbac.authorization.k8s.io/jenkins-admin created
null_resource.jenkins (local-exec): serviceaccount/jenkins-admin created
null_resource.jenkins (local-exec): clusterrolebinding.rbac.authorization.k8s.io/jenkins-admin created
null_resource.jenkins: Creation complete after 12s [id=5621991147810378388]

Apply complete! Resources: 22 added, 0 changed, 0 destroyed.
```

###### Terraform выполнил код. Смотри наш локальный конфиг  ~/.kube/config

```shell
$ cat ~/.kube/config
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJWWwyQ3NKekZQOXN3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TXpBNU1UUXdPREEzTkRoYUZ3MHpNekE1TVRFd09ERXlORGhhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUUREdUxYOVZJL1grbWpiUkUrdGJuRUVUZVduY0FnWnBWMklSN2NJdURUV1F4Ykw5Q2lKZDN6b3J6OEUKM0JzV2VtZUEvRmtDdnZtcnppaVhWdVFWb1A5QmpDWXR1cW9mRHBIKytYQU9XYnh0dXpXQ2Rsa04wbk1TVVZxMAptUkxISkFmTjFxQ0thUDgwVkhNTmlZaHBSZkZIMENTZjRPTWJwaGNXWFZ1OE4rTXpuQ0ZMa1N0MDZBN21pajBtCjIyY0poNVJpdHFsUFU5TGVNRWdEbU40Y2xrT3lBQi9rU2VBQjdBUEdyWk43Z1BLdlEwNUNkeVJxaTNRTld4YWkKZFVNdU4yaUVQUVVYVGpZUVBKbFdBd1p4azQvZGtnTnJUajI3dEl4eVdUc0xJL2tZcHhVSkNQajdYaXkwWG52VgpDcG1paTVKNzNidm9teWMzWGRrRmFkTGhRbk16QWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJRVmxSWUZyaENFekRqSXlDV2QxTTEvWFJFczdUQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ2YyaElOQ1lSbgorSlRLemQrRkltYnFSOHdoTU0rUDVQcHNyS1Vxc3ovWkNMR0x6bk9QNkkxSHR3TUZMYXhmaktqZUlYcDdVTXdxCko1dGlZS0JzbWFSUlBIb0JrLzVQVm5nUk83WGhWUHc2RVNWRUs3aTM3T3RJSnd5bktXZEFtWlozSUJNUmRkUUQKTW95VklVNnJWdmh0UDBHNXdFM3NBRndWUWtWTzJkeGdZYTQreG14ZlU5NU0xdUo4YzNLbmZISU94L0VUYXMrVQpmV3lOd2IrdWxaajUvQktKMDNiQ0RkV3ZlUVhFTi85cUhDSkZ0N2I3c3pyd1FvYzFobXZBaTBReFJQeldPcFFLCktVaDNIa3o2S2FHamFEc2RmRzFSZ0grd2w3QlpSUHMyUzdHRHlzcy9aWk1pMmdXUHB1ZmlIdnpnOUxKd1VjSXAKR2V2MW03UWN5VTJzCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://158.160.58.42:6443
  name: cluster.local
contexts:
- context:
    cluster: cluster.local
    user: kubernetes-admin-cluster.local
  name: kubernetes-admin-cluster.local@cluster.local
current-context: kubernetes-admin-cluster.local@cluster.local
kind: Config
preferences: {}
users:
- name: kubernetes-admin-cluster.local
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURJVENDQWdtZ0F3SUJBZ0lJR04vUjhSSklHRXN3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TXpBNU1UUXdPREEzTkRoYUZ3MHlOREE1TVRNd09ERXlOVEJhTURReApGekFWQmdOVkJBb1REbk41YzNSbGJUcHRZWE4wWlhKek1Sa3dGd1lEVlFRREV4QnJkV0psY201bGRHVnpMV0ZrCmJXbHVNSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQW50T01BVGdPd3Btb2IrMGcKdG80YnA2alp4QW1idStTbWEyQkV0SmRvRmlhbTI4RmRtTFVXa0xUTUIyQ1Jnb3hZNVIwZkZXU1hMT1c4UDFSUAppZFU5cHFNc2pyYVVMUFBRYXZnekxJS1NxdFhRNkZLQWdCLzZBUmdENGhDMmtOejhpeU5HYi9wUlk0UmJodGQrCmxtMTM0bGJpOUVzc1VhVk9OWmY4cVlEOWlEQzI0UWdTVXdKSksrUzljVDVZeldVRXJSREhRWFdzUnZVTm5seUMKTTNwTkZFVzgwQkxLbGVxbUVZS0J1U0dtVWNzUVNOTlNPR2hJV2dWYWU0bW5CVWQ2ODh4SGM3ZnQ1NkhpQnBvTQo2aG5tL2FMVmd2UXhsVHFnNGxtWWRtdzBObk9jdzUzSkRpcWFyS2Ewc1pBN01BcS9pNTFzOU1WZG9aU25STHRNCmlmcDhod0lEQVFBQm8xWXdWREFPQmdOVkhROEJBZjhFQkFNQ0JhQXdFd1lEVlIwbEJBd3dDZ1lJS3dZQkJRVUgKQXdJd0RBWURWUjBUQVFIL0JBSXdBREFmQmdOVkhTTUVHREFXZ0JRVmxSWUZyaENFekRqSXlDV2QxTTEvWFJFcwo3VEFOQmdrcWhraUc5dzBCQVFzRkFBT0NBUUVBTkM5ak1RZEt1Z09xOVVpNk9yMXdNejZzOS8yWEVRVXJReExyCkFwZ0NwV0Q5ODNUelBUOERSRmxTczRENC9qdnJBSVlQUGU2dW9hZ0NwcHRtcFRRQkpLMXRUR2oya2RIem1BQ2oKZTY3ejFBbXZiTDZiOUxMcEpTeWNSY3BwdDBuY3Zhazg0YXB3aXREQTZRWVd0emRlSnRSMDZUbWlWZU5YRXRoRQpqd0JBWDRYZWowZTErSVFEZmVtbUdnVzF6bzJDaU5qSjNEOEpsTnB5SVhyQ3ByaHZFb2VVNnJsNkpQbEZJcks0CmlQNXVpU3l6SzBLb1lXRHoxUXZZa0hkVUV0UWJFeWlNelRaeUg3U1lpUGNXdGpHcHlpT1hmK3VRZllSekNpTDgKVG1iblVLbGxncmdhRkoyZmoyNDBWV1BaRVQ5NzlLbHdqcnZXbzVJSGpwTVMxcU5vZXc9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJQkFBS0NBUUVBbnRPTUFUZ093cG1vYiswZ3RvNGJwNmpaeEFtYnUrU21hMkJFdEpkb0ZpYW0yOEZkCm1MVVdrTFRNQjJDUmdveFk1UjBmRldTWExPVzhQMVJQaWRVOXBxTXNqcmFVTFBQUWF2Z3pMSUtTcXRYUTZGS0EKZ0IvNkFSZ0Q0aEMya056OGl5TkdiL3BSWTRSYmh0ZCtsbTEzNGxiaTlFc3NVYVZPTlpmOHFZRDlpREMyNFFnUwpVd0pKSytTOWNUNVl6V1VFclJESFFYV3NSdlVObmx5Q00zcE5GRVc4MEJMS2xlcW1FWUtCdVNHbVVjc1FTTk5TCk9HaElXZ1ZhZTRtbkJVZDY4OHhIYzdmdDU2SGlCcG9NNmhubS9hTFZndlF4bFRxZzRsbVlkbXcwTm5PY3c1M0oKRGlxYXJLYTBzWkE3TUFxL2k1MXM5TVZkb1pTblJMdE1pZnA4aHdJREFRQUJBb0lCQUhzdW5aNXdhTm83TEswcQpYNzNXdDlJd0hqMXlLa3Z2Q2JlcjRYMmpGRUpoMWZZSW9kd0hUeW9LWDFlMWFRVzBibG04WFZoTlBRYkFZMkZHCnRhMjBLbTJzanFsZEo4MDVpRUwrbjBuOU4xMnlHYVdtSHkzQUh6bHI4ODhJb1YvM1ZSTmcxNGVQd0VJTDdLVEgKUzlIRnN6NWpud0JUc1ZyZGQ2d1BaaEhkRGtYcU1aQ0hjb1hNSGI4VG5RQjMvSVZMcFJ3Y2dMSXQwdnFJcndESwpsZEEwRytRRk4wNDVDMngxZm9pMWdSN2dwcFpFQVl5Z0hqYjh1NjltanlJRFVSODg1dFlvbDJFL0NQQ3U1eDhKCnUvdWExd2VaL1NDbk5jRGt5a2RmSUtWWUtVUlJMWGNKeGxpVmRrVkdHKzFHckRneTVtQnVPUVJMZUw2SzYrSnQKNDA3eEtWa0NnWUVBeTVPQTBKQ21VSWxOQzlOcEVhcjk4NWVLc0NyTFhQOXFKaDFJV1poQ1JZZlUzTFd3RFZzOApsNC9nZVIvRnhFUW5pdnZ4L1ZtRGdZbDdRbFBBc3BwZDBSWFBMMXVtSWI3WTIxOGs4cXdMdHY1Y1Y1aFFienhWCktJNHNEaWExL01mTVJCNGFIYWh4U1g0azZhMnc4akxIY29rVlFocS8xVTgvTWlVSUJHTzJOZjBDZ1lFQXg3bjQKRkVJZk1XK05CL29XTHVoTS91eDMzanV2bU9MVEVJT1ZmaVd3QjA1aXZ4T1ppd1hjMDFvS2RnemNySWFjeElmRApkMFpDQmlDeHF4OWJUZmExNnhCendacGxsV3lTZmVkTS95MzYxWVkrUmc4QVlOWE1kODhxdzl4c0h4K3JUUSsvCmQwU1FpRVd0a2JrYU9EMFRIbXBsZ2s3S1VDNERKaUo4bE8vT0FkTUNnWUJiNDlMTFVkK2dqcmsyVTFFajVua0cKMFNxSzVtWXhMaUV0M3gzZlF6ajJ4Wjh4bU5sRXppQUZrYTRUUG1JNGUwTVdHeTlaMm1QZnZyemliWWVYbHRJdQpKSmdHbW1uYzVaWmhQd3NnZHNRNjc0bWpDRitXTmplQ1BOcHA4Tk5Jcks3cE9HVTFhZWpvOFlXYjdRam42ai9ZCjFVUEJPTzNLVFNFTGMyZXhBNGtseVFLQmdRQ05hOFFhYkJ0MFFMMkc2WEV0czdWWlNJMHo0ZVZiaHpqV1Y2WFIKMWRQSHlKd3BHaks5ZXVBN0UyV1c0MUthSXhMOElmbXBDaW1UOXpCMnI5UlI1eUEzR3NZc1R5d2cydWo3bDMwdwpyeGtPZW1pNzZNRm16OXhnOVdNZG5vVThvSXNHSE9HQkRSNmVMMkJRYjlYOS9sajhUM0FqRGJFNWh1c1o1STk4ClVqVDNtd0tCZ1FDTVRIL0h5NlZwNnczLzVQa2lsbTFwNVFnN1pZbko4aHlNWkdGSUtHdU9BY1h2aVpKMUtBSWoKOTNIQ0p3cGRwWnZhTm5ZUFFhaWozUGZjTm5ZVkJybm8rNi9MZG9aNEpVMUpsNDUyOW9ZSWU0bTE5YVoxWkVOSwpXcFAyY2kraStHQ3h6Ym5qTTJMbFNObk1xYkI4Ujg2N09qd01zU3Y4cDM3NkhBdi9ESTdTSmc9PQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo=
```

###### Проверяем наличие доступа с локальной машины к нашему кластеру в Yandex Cloud:

```shell
$ kubectl get nodes -o wide
NAME       STATUS   ROLES           AGE     VERSION   INTERNAL-IP      EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
master01   Ready    control-plane   7m32s   v1.27.5   192.168.101.20   <none>        Ubuntu 20.04.6 LTS   5.4.0-153-generic   containerd://1.7.5
node01     Ready    <none>          6m21s   v1.27.5   192.168.101.19   <none>        Ubuntu 20.04.6 LTS   5.4.0-153-generic   containerd://1.7.5
node02     Ready    <none>          6m21s   v1.27.5   192.168.102.12   <none>        Ubuntu 20.04.6 LTS   5.4.0-153-generic   containerd://1.7.5
node03     Ready    <none>          6m23s   v1.27.5   192.168.103.25   <none>        Ubuntu 20.04.6 LTS   5.4.0-153-generic   containerd://1.7.5
```


```shell
$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                                     READY   STATUS    RESTARTS   AGE
jenkins       jenkins-6cc956d9bb-kmkcj                                 1/2     Running   0          2m30s
kube-system   calico-kube-controllers-5c5b57ffb5-pftnd                 1/1     Running   0          5m40s
kube-system   calico-node-lck8l                                        1/1     Running   0          6m46s
kube-system   calico-node-mlbww                                        1/1     Running   0          6m46s
kube-system   calico-node-tzsgl                                        1/1     Running   0          6m46s
kube-system   calico-node-zn6d4                                        1/1     Running   0          6m46s
kube-system   coredns-5c469774b8-2b6zk                                 1/1     Running   0          5m6s
kube-system   coredns-5c469774b8-hsc7d                                 1/1     Running   0          5m15s
kube-system   dns-autoscaler-f455cf558-z262r                           1/1     Running   0          5m9s
kube-system   kube-apiserver-master01                                  1/1     Running   1          8m42s
kube-system   kube-controller-manager-master01                         1/1     Running   2          8m46s
kube-system   kube-proxy-9g6kt                                         1/1     Running   0          7m33s
kube-system   kube-proxy-hgqwc                                         1/1     Running   0          7m33s
kube-system   kube-proxy-jjpx7                                         1/1     Running   0          7m33s
kube-system   kube-proxy-rsrwx                                         1/1     Running   0          7m33s
kube-system   kube-scheduler-master01                                  1/1     Running   1          8m42s
kube-system   nginx-proxy-node01                                       1/1     Running   0          7m35s
kube-system   nginx-proxy-node02                                       1/1     Running   0          7m34s
kube-system   nginx-proxy-node03                                       1/1     Running   0          7m34s
kube-system   nodelocaldns-fr79c                                       1/1     Running   0          5m7s
kube-system   nodelocaldns-gfzpb                                       1/1     Running   0          5m7s
kube-system   nodelocaldns-m29z4                                       1/1     Running   0          5m7s
kube-system   nodelocaldns-vhqgr                                       1/1     Running   0          5m7s
monitoring    alertmanager-stable-kube-prometheus-sta-alertmanager-0   2/2     Running   0          3m1s
monitoring    prometheus-stable-kube-prometheus-sta-prometheus-0       2/2     Running   0          3m
monitoring    stable-grafana-5999445d6c-zn2dn                          3/3     Running   0          3m8s
monitoring    stable-kube-prometheus-sta-operator-6f745454df-727pd     1/1     Running   0          3m8s
monitoring    stable-kube-state-metrics-655644f54f-rr76b               1/1     Running   0          3m8s
monitoring    stable-prometheus-node-exporter-7dqts                    1/1     Running   0          3m8s
monitoring    stable-prometheus-node-exporter-gxgkv                    1/1     Running   0          3m8s
monitoring    stable-prometheus-node-exporter-k8vcx                    1/1     Running   0          3m8s
monitoring    stable-prometheus-node-exporter-nhthq                    1/1     Running   0          3m8s
stage         myapp-myapp-stage-5fd6cfbbff-jx9mn                       1/1     Running   0          2m42s
```
 Видим пространства имен monitoring, jenkins, stage (мониторинг, jenkins, наше приложение, соответственно)

###### Для доступа к Grafana из внешней сети нужно внести изменения:

```shell
$ export EDITOR=nano
$ kubectl edit svc stable-grafana -n monitorin
```
![Grafana edit svc](./sreens/grafana_edit_svc.png)

##### Проверяем результаты:

Yandex Cloud:

Dashboard:
![Yandex Cloud](./sreens/yc.png)  

Сети:
![YC net](./sreens/yc_net.png)

Виртуальные машиниы:
![YC VM ](./sreens/yc_vm.png)

Хранилище с состонием terraform`а:
![YC bucket](./sreens/yc_bucket.png)

![Monitoring](./sreens/monitoring.png)

Опубликованное приложение:
![MyApp](./sreens/simple_page.png) 

Интерфейс Jenkins:
![Jenkins](./sreens/jenkins.png) 

Jenkins Dashboard:
![Jenkins Initial Dashboard](./sreens/jenkins_at_start.png) 

Созданный мультибранч:
![Jenkins Initial Multibranch](./sreens/jenkins_at_start_mbr.png) 

![Jenkins Initial Main Branch](./sreens/jenkins_at_start_main.png) 


##### Выполнение тестовых заданий:

###### Скрин DockerHub до тестов:
![DockerHub before](./sreens/dhub_at_start.png) 

###### Делаем коммит в наш репозиторий:
![Git only commit](./sreens/git_commit.png) 

###### Смотрим, реакцию Jenkins - началась сборка (Jenkins успешно увидел изменения в нашем репозитории)

![Jenkins after commit](./sreens/jenkins_after_commit.png) 

###### По условию теста - создан и размещен образ в DockerHub:
![DockerHub after commit](./sreens/dhub_after_commit.png) 

###### Деплоя нашего приложение не случилось:
![Jenkins only commit](./sreens/Jenkins_main_after_commit.png)

###### Делаем комит с тэгом:

![Git commit & tag](./sreens/git_commit&tag.png) 

###### Jenkins "увидел" наш тэг:
![Jenkins after commit & tag](./sreens/jenkins_after_tag_mbranch.png) 

###### Выполнил сборку и отправку образа с указанием тэга, а также разыернул в нашем кластере обновленное приложение:
![Jenkins after commit & tag](./sreens/jenkins_after_tag_pipe.png) 

![DockerHub after commit & tag](./sreens/dhub_after_tag.png) 

![MyApp after commit & tag](./sreens/simple_page_after_tag.png) 


###### Смотрим наш кластер, все на своих местах:

```shell
$ kubectl get pods -n stage
NAME                                READY   STATUS    RESTARTS   AGE
myapp-myapp-stage-845bc9bb7-5cn75   1/1     Running   0          33m

$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                                     READY   STATUS    RESTARTS   AGE
jenkins       jenkins-6cc956d9bb-txpfh                                 2/2     Running   0          52m
kube-system   calico-kube-controllers-5c5b57ffb5-pftnd                 1/1     Running   0          98m
kube-system   calico-node-lck8l                                        1/1     Running   0          99m
kube-system   calico-node-mlbww                                        1/1     Running   0          99m
kube-system   calico-node-tzsgl                                        1/1     Running   0          99m
kube-system   calico-node-zn6d4                                        1/1     Running   0          99m
kube-system   coredns-5c469774b8-2b6zk                                 1/1     Running   0          97m
kube-system   coredns-5c469774b8-hsc7d                                 1/1     Running   0          97m
kube-system   dns-autoscaler-f455cf558-z262r                           1/1     Running   0          97m
kube-system   kube-apiserver-master01                                  1/1     Running   1          101m
kube-system   kube-controller-manager-master01                         1/1     Running   2          101m
kube-system   kube-proxy-9g6kt                                         1/1     Running   0          100m
kube-system   kube-proxy-hgqwc                                         1/1     Running   0          100m
kube-system   kube-proxy-jjpx7                                         1/1     Running   0          100m
kube-system   kube-proxy-rsrwx                                         1/1     Running   0          100m
kube-system   kube-scheduler-master01                                  1/1     Running   1          101m
kube-system   nginx-proxy-node01                                       1/1     Running   0          100m
kube-system   nginx-proxy-node02                                       1/1     Running   0          100m
kube-system   nginx-proxy-node03                                       1/1     Running   0          100m
kube-system   nodelocaldns-fr79c                                       1/1     Running   0          97m
kube-system   nodelocaldns-gfzpb                                       1/1     Running   0          97m
kube-system   nodelocaldns-m29z4                                       1/1     Running   0          97m
kube-system   nodelocaldns-vhqgr                                       1/1     Running   0          97m
monitoring    alertmanager-stable-kube-prometheus-sta-alertmanager-0   2/2     Running   0          95m
monitoring    prometheus-stable-kube-prometheus-sta-prometheus-0       2/2     Running   0          95m
monitoring    stable-grafana-5999445d6c-zn2dn                          3/3     Running   0          95m
monitoring    stable-kube-prometheus-sta-operator-6f745454df-727pd     1/1     Running   0          95m
monitoring    stable-kube-state-metrics-655644f54f-rr76b               1/1     Running   0          95m
monitoring    stable-prometheus-node-exporter-7dqts                    1/1     Running   0          95m
monitoring    stable-prometheus-node-exporter-gxgkv                    1/1     Running   0          95m
monitoring    stable-prometheus-node-exporter-k8vcx                    1/1     Running   0          95m
monitoring    stable-prometheus-node-exporter-nhthq                    1/1     Running   0          95m
stage         myapp-myapp-stage-845bc9bb7-5cn75                        1/1     Running   0          33m
```