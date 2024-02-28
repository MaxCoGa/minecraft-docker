# Minecraft-Docker
self-hosted solution

## Requirments
docker

## Steps

### 1 . Configure the [config.yml](config.yml) file:

The server config can be edited to assign more memory.

Choose a tunnel by setting it to true in the config file.

    ## tunnel config
    tunnel:
      serveo: false
        hostname: serveo.net
        port: <PORTNUMBER>
    
      connect: true
        token: <TOKEN>
        endpoint: EXAMPLE
        hostname: play.minekube.net
        
> The default tunnel in use is *connect* for its simplicity and it will
> give you a static address. If you already have endpoint created with
> minekube's plugin you and want to reuse it, you will need your token.
> If not, then you can let, you can let a random endpoint being choose
> for you or you can choose one. Don't forget to save your token
> somewhere, so that you don't lost it forever! [LOCATION]

The dns config is optionnal.

### 2. Build the image:

    docker build -t minecraft .

### 3. Create the container from the image:

    docker run  --privileged -itd --name --network host minecraft -v ./mcdata:/mcdata minecraft:latest

 ***If the container is already built, but is stop, start it with***:

    docker exec --privileged -it minecraft bash

### 4. Enter the container:

    docker start  minecraft
 
### 5. Execute run.sh from the container:

    ./run.sh

### 6. Access server console

    tmux a -t server
 
### 7. Play

## Credits

