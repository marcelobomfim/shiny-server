# microservice shiny-server

# Para criar a imagem a partir do dockerfile, utilizar o seguinte comando docker

$ docker build -t shiny-server .

# Para subir o container, utilizar o seguinte comando docker

$ docker run -d -p 3838:80 -v /srv/shiny-server:/srv/shiny-server --name shiny-server shiny-server
