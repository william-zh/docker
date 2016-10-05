#!/bin/bash

usage ()
{
    echo "dockdock [OPTIONS]"
    echo "OPTIONS = debug, build_api, dangling, flywayInfo, flywayMigrate, mysql, changelog, migrations, rcash, pull_mysql" 
    exit
}

api_path=/Users/lukexu/dev/api
hbng_path=/Users/lukexu/dev/hbng

if [ "$#" = 0 ]
then
    usage
fi

for arg in $*; do

    cd $api_path
    if [ $arg = "debug" ]; then
        docker exec api_api_1 /bin/sh -c "sed -ie "\\\$axdebug\.remote_host=192\.168\.65\.1" /etc/php5/mods-available/xdebug.ini"
        docker exec api_api_1 /bin/sh -c "sed -ie "\\\$axdebug\.remote_connect_back=0" /etc/php5/mods-available/xdebug.ini"
        docker exec api_api_1 /bin/sh -c "service php5-fpm restart"
        exit
    fi

    if [ $arg = "build_api" ]; then
       cd php
       docker build -t hb_api .
       exit
    fi

    if [ $arg = "dangling" ]; then
       docker rmi $(docker images --quiet --filter "dangling=true")
       exit
    fi

    if [ $arg = "flywayInfo" ]; then
       cd java
       ./gradlew migrations:flywayInfo
       exit
    fi

    if [ $arg = "flywayMigrate" ]; then
       cd java
       ./gradlew migrations:flywayMigrate
       exit
    fi

done

cd $api_path
docker-compose stop

for arg in $*; do

    if [ $arg = "mysql" ]; then
        docker rm api_mysql_1
    fi

    if [ $arg = "changelog" ]; then
        docker rm api_changelog_1
        docker rmi java/changelog
        cd java
        ./gradlew changelog:distDocker
    fi

    if [ $arg = "email" ]; then
        docker rm api_email_1
        docker rmi java/email
        cd java
        ./gradlew email:distDocker
    fi

    if [ $arg = "migrations" ]; then
        docker rm api_migrations_1
        docker rmi java/migrations
        cd java
        ./gradlew migrations:clean
        ./gradlew migrations:jar
        ./gradlew migrations:distDocker
    fi

    if [ $arg = "rcash" ]; then
        docker rm api_rcash_1
        docker rmi java/rcash
        cd java
        ./gradlew rcash:distDocker
    fi

    if [ $arg = "pull_mysql" ]; then
        docker pull quay.io/honestbuildings/hb_mysql
    fi
done

docker-compose up -d
osascript -e 'display notification "dockdock has completed... restarting containers" with title "dockdock"'
