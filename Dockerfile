# Usa la imagen base oficial de NGINX
FROM nginx:alpine

# Crea el archivo index.html directamente desde el Dockerfile
RUN echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Hello World</title></head><body><h1>Hello World</h1></body></html>' > /usr/share/nginx/html/index.html

# Expone el puerto 80 para el tráfico HTTP
EXPOSE 80

# Comando predeterminado para ejecutar NGINX
CMD ["nginx", "-g", "daemon off;"]
