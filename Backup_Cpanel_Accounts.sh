#!/bin/bash

#Config
Host=`hostname`
Current_Date=$(date +%Y%m%d)
Backup_folder='/home/cloud_backup'
Full_Backup_Path="${Backup_folder}/${Host}/${Current_Date}/"

#Notify
echo 'El $Host Inicia Proceso de Respaldo' | mail -s 'Alerta Inicio Backups' cm@itfinden.com 
        
#unblock Ip 
csf -a 201.217.242.101

#Verificamos si el directorio Backup existe
if [ -d '/home/cloud_backup/' ]
then
    echo "Verificado el Directorio ";
else
    mkdir $Backup_folder
fi

#Montamos el Cloud
sshfs -o password_stdin -o nonempty -p 7432 Vps79@cloud.itfinden.com:/home/Vps79/ /home/cloud_backup <<< "QazWsxEdc2019"

#Validamos que este montado

isMounted='mount | grep Vps79@cloud.itfinden.com'

mkdir -p $Full_Backup_Path

if [ -z "$isMounted" ];
then
        echo "NO ESTA MONTADO"
        echo 'en el hostnme $Host no esta montada cloud_backup' | mail -s 'Alerta No Backups' cm@itfinden.com 
        ##Matar proceso##
else
        echo ""
            for a in /home* ; do
                    cd $a
                    for i in * ; do
                    		
                    		if [ "$i" == "0_README_BEFORE_DELETING_VIRTFS" ] ; then
              						continue;
        					fi

        					if [ "$i" == "var_mysql" ] ; then
              						continue;
        					fi

        					if [ "$i" == "virtfs" ] ; then
              						continue;
        					fi
        					
                    		Full_client_Backup_Path="${Full_Backup_Path}/${i}"
                            mkdir -p $Full_client_Backup_Path
                            
                            echo "Backup to $i "
                            echo "backup into ${Full_Backup_Path} in folder ${i}"
                            #/scripts/pkgacct --userbackup $i /home/cloud_backup > /dev/null 2>&1
                    done
            done
fi
#sleep 5

umount /home/cloud_backup


#Notify
echo 'El $Host Termino Proceso de Respaldo' | mail -s 'Alerta Termino Backups' cm@itfinden.com 
