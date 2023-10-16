#!/bin/bash

#Скрипт для создания RAID 10


#Занулим суперболки, необходимо для очистки данных о возможных предыдущих рейдах.
sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e}

#Создание рейд один ноль из 4х устройств. 
sudo mdadm --create --verbose /dev/md0 -l 10 -n 4 /dev/sd{b,c,d,e}

#Конфиг для mdadm для настройки RAID после перезагрузки
sudo su

sudo touch /etc/mdadm.conf
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm.conf

#Создаём партиции
parted -s /dev/md0 mklabel gpt

parted -s /dev/md0 mklabel gpt
parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 80%
parted /dev/md0 mkpart primary ext4 80% 100%

#Создаем на партициях FS
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done


#Монтируем по каталогам
mkdir -p /raid/part{1,2,3,4,5}
for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done

