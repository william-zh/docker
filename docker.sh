#!/bin/bash

usage ()
{
    echo "dockdock [OPTIONS]"
    echo "OPTIONS = changelog, changelog-man, mysql, debug, build_api dangling, flywayInfo, flywayMigrate, pull_mysql"
    exit
}

if [ "$#" = 0 ]
then
    usage
fi

for arg in $*; do

    if [ $arg = "debug" ]; then
        docker exec api_api_1 /bin/sh -c "sed -ie "\\\$axdebug\.remote_host=192\.168\.65\.1" /etc/php5/mods-available/xdebug.ini"
        docker exec api_api_1 /bin/sh -c "sed -ie "\\\$axdebug\.remote_connect_back=0" /etc/php5/mods-available/xdebug.ini"
        docker exec api_api_1 /bin/sh -c "service php5-fpm restart"
        exit
    fi

    if [ $arg = "build_api" ]; then
       cd $api_path + "/php"
       docker build -t hb_api .
       exit
    fi

    if [ $arg = "dangling" ]; then
       docker rmi $(docker images --quiet --filter "dangling=true")
       exit
    fi

    if [ $arg = "flywayInfo" ]; then
       cd $api_path + "/java"
       gradle migrations:flywayInfo
       exit
    fi

    if [ $arg = "flywayMigrate" ]; then
       cd $api_path + "/java"
       gradle migrations:flywayMigrate
       exit
    fi

done

api_path=/Users/lukexu/dev/api
hbng_path=/Users/lukexu/dev/hbng

cd $api_path
docker-compose stop

for arg in $*; do

    if [ $arg = "mysql" ]; then
        echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
        echo "Removing api_mysql_1"
        echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
        docker rm api_mysql_1
        
        echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
        echo "REMEMBER TO RUN FLYWAY MIGRATE"
        echo "REMEMBER TO RUN FLYWAY MIGRATE"
        echo "REMEMBER TO RUN FLYWAY MIGRATE"
        echo "REMEMBER TO RUN FLYWAY MIGRATE"
        echo "REMEMBER TO RUN FLYWAY MIGRATE"
        echo "REMEMBER TO RUN FLYWAY MIGRATE"
        echo "REMEMBER TO RUN FLYWAY MIGRATE"
        echo "REMEMBER TO RUN FLYWAY MIGRATE"
        echo "REMEMBER TO RUN FLYWAY MIGRATE"
        echo "REMEMBER TO RUN FLYWAY MIGRATE"
        echo "REMEMBER TO RUN FLYWAY MIGRATE"
        echo "REMEMBER TO RUN FLYWAY MIGRATE"
        echo "REMEMBER TO RUN FLYWAY MIGRATE"
        echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    fi

    if [ $arg = "changelog" ]; then
        echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
        echo "Removing api_changelog_1"        
        echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
        docker rm api_changelog_1
        
        echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
        echo "Removing java/changelog image"
        echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
        docker rmi java/changelog

        echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
        echo "Building change log image"
        echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
        cd java
        gradle :changelog:distDocker
    fi

    if [ $arg = "rcash" ]; then
        docker rm api_rcash_1

        docker rmi java/rcash

        cd java
        gradle :rcash:distDocker
    fi

    if [ $arg = "pull_mysql" ]; then
        docker pull quay.io/honestbuildings/hb_mysql
    fi

    if [ $arg = "changelog-man" ]; then
        echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
        echo "Manually building docker image"
        echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
        cd java/services/changelog/build/docker 
        docker build -t java/changelog .
    fi  

done


echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
echo "Starting docker containers"
echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
docker-compose up -d
osascript -e 'display notification "dockdock has completed... restarting containers" with title "dockdock"'


