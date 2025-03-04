FROM mfurkansahin/overpass-places-api-x86-64:v1.0-n-u

# OVERPASS_PLANET_URL değişkenini ayarla
ENV OVERPASS_PLANET_URL="http://34.40.36.36:8000/konya.osm.bz2"
ENV OVERPASS_RULES_LOAD=100
ENV OVERPASS_SERVER_BIND_ADDR="0.0.0.0"

# Nginx için yapılandırma
RUN mkdir -p /etc/nginx/conf.d
COPY nginx-custom.conf /etc/nginx/conf.d/default.conf

# Diğer ayarlar varsayılan olarak imajdan gelecek

# Portları aç
EXPOSE 80
EXPOSE 8080


