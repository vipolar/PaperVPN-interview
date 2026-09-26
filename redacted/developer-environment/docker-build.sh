#!/bin/bash

script_file="./$(basename "${BASH_SOURCE[0]}")"
redacted_frontend_path="./redacted-frontend"
redacted_backend_path="./redacted-backend"

if [ "$EUID" -eq 0 ]; then
    echo "ABORTING: script was invoked by a super user!"
    echo "HINT: no sudoers allowed!"
    exit
fi

if [ "$0" != "$script_file" ]; then
    echo "ABORTING: script invocation error occurred!"
    echo "HINT: invoke the script as a local executable: ./example.sh"
    exit
fi

if [ -f .env ]; then
    # Load variables from .env file excluding comments
    while IFS= read -r line; do
        if [[ "$line" =~ ^[^#]*= ]]; then
            export "$line"
        fi
    done < .env

    # Export variables with self-references using envsubst
    envsubst < .env > .env.tmp
    source .env.tmp
    rm .env.tmp
else
    echo "ABORTING: .env file not found!"
    exit
fi

if [ -f ./resources/nginx/conf.template/default.conf.template ]; then
    mkdir -p nginx/conf.d/
    mkdir -p nginx/certbot/www
    mkdir -p nginx/server/logs
    mkdir -p nginx/letsencrypt/live
    mkdir -p nginx/letsencrypt/archive
    mkdir -p nginx/letsencrypt/accounts
    sudo chmod -R o+w ./nginx

    envsubst < ./resources/nginx/conf.template/default.conf.template > ./nginx/conf.d/default.conf
    echo "Success: nginx configuration ready!"

    if [ -f ./resources/nginx/healthcheck.sh ]; then
        cp ./resources/nginx/healthcheck.sh ./nginx
        chmod +x ./nginx/healthcheck.sh 

        echo "Success: nginx healthcheck script installed successfully!"
    else
        echo "ERROR: nginx healthcheck script not found!"
    fi
else
    echo "ABORTING: nginx configuration failed! (template file not found)"
    exit
fi

if [ -f ./resources/postgresdb/init-scripts/create-multiple-postgresql-databases.sh ]; then
    mkdir -p postgresdb/data
    mkdir -p postgresdb/config
    mkdir -p postgresdb/scripts
    sudo chmod -R o+w ./postgresdb

    cp ./resources/postgresdb/init-scripts/create-multiple-postgresql-databases.sh ./postgresdb/scripts
    echo "Success: postgreSQL init script ready!"
else
    echo "ABORTING: postgreSQL init script not found!"
    exit
fi

if [ -f ./resources/pgadmin/servers.json.template ]; then
    mkdir -p pgadmin/var/lib/pgadmin/sessions
    sudo chmod -R o+w ./pgadmin

    envsubst < ./resources/pgadmin/servers.json.template > ./pgadmin/servers.json
    echo "Success: pgadmin servers configuration ready!"
else
    echo "ABORTING: pgadmin configuration failed! (template file not found)"
    exit
fi

if [ -f ./resources/keycloak/realm.json ]; then
    mkdir -p keycloak
    mkdir -p keycloak/providers
    #TODO: add script to download custom providers!
    sudo chmod -R o+w ./keycloak

    cp ./resources/keycloak/realm.json ./keycloak
    echo "Success: keycloak realm ready!"
else
    echo "ABORTING: keacloak realm.json not found!"
    exit
fi

# Pull redacted repositories
# Backend
if [ -d "$redacted_backend_path" ]; then
    echo "Folder '$redacted_backend_path' exists, meaning the repository has already been cloned locally!"
    echo "Would you like remove the existing local repository and clone it again? [y/N]: "
    
    read confirmation
    confirmation_lower=$(echo "$confirmation" | tr '[:upper:]' '[:lower:]')

    if [ "$confirmation_lower" = "y" ]; then
        rm -rf $redacted_backend_path
        git clone https://github.com/redacted/redacted-backend.git
        sudo chmod -R o+w $redacted_backend_path
        sudo chmod -R o+r $redacted_backend_path
    else
        echo "Cloning repository skipped"
    fi
else
    git clone https://github.com/redacted/redacted-backend.git
    sudo chmod -R o+w $redacted_backend_path
    sudo chmod -R o+r $redacted_backend_path
fi

# Frontend
if [ -d "$redacted_frontend_path" ]; then
    echo "Folder '$redacted_frontend_path' exists, meaning the repository has already been cloned locally!"
    echo "Would you like remove the existing local repository and clone it again? [y/N]: "
    
    read confirmation
    confirmation_lower=$(echo "$confirmation" | tr '[:upper:]' '[:lower:]')

    if [ "$confirmation_lower" = "y" ]; then
        rm -rf $redacted_frontend_path
        git clone https://github.com/redacted/redacted-frontend.git
        mkdir -p ./redacted-frontend/.angular
        sudo chmod -R o+w ./redacted-frontend/.angular
        sudo chmod -R o+r ./redacted-frontend/.angular
        mkdir -p ./redacted-frontend/node_modules
        sudo chmod -R o+w ./redacted-frontend/node_modules
        sudo chmod -R o+r ./redacted-frontend/node_modules
        sudo chmod o+w ./redacted-frontend
        sudo chmod o+r ./redacted-frontend
    else
        echo "Cloning repository skipped"
    fi
else
    git clone https://github.com/redacted/redacted-frontend.git #DIRNAME
    mkdir -p ./redacted-frontend/.angular
    sudo chmod -R o+w ./redacted-frontend/.angular
    sudo chmod -R o+r ./redacted-frontend/.angular
    mkdir -p ./redacted-frontend/node_modules
    sudo chmod -R o+w ./redacted-frontend/node_modules
    sudo chmod -R o+r ./redacted-frontend/node_modules
fi

# Build
#sudo docker compose build
#sudo docker compose up
