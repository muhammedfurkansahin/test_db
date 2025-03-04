FROM mediagis/nominatim:4.5-2024-11-13T11-17

# Çevre değişkenlerini ayarla
ENV PBF_URL=https://download.geofabrik.de/europe/turkey-latest.osm.pbf \
    PROJECT_DIR=/nominatim/data \
    NOMINATIM_PASSWORD=123456 \
    POSTGRES_PASSWORD=123456

# Veri dizinini oluştur
RUN mkdir -p /nominatim/data

# Çalışma dizinini ayarla
WORKDIR /app

# Port ayarı
EXPOSE 8080
