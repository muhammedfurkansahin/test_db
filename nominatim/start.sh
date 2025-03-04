#!/bin/bash

# Environment variables
export PATH=$PATH:/usr/lib/postgresql/15/bin
export NOMINATIM_DATABASE_DSN="postgresql://nominatim:nominatim@localhost/nominatimtest12"
export NOMINATIM_USER_AGENT="nominatim-turkey"
export NOMINATIM_READONLY_USER="www-data"
export NOMINATIM_LISTEN_HOST="0.0.0.0"

# PostgreSQL veri dizinini başlat
mkdir -p /var/lib/postgresql/data
chown -R postgres:postgres /var/lib/postgresql/data

# PostgreSQL cluster'ı başlat (eğer yoksa)
if [ ! -f "/var/lib/postgresql/data/PG_VERSION" ]; then
    echo "PostgreSQL veritabanı ilk kez başlatılıyor..."
    gosu postgres initdb -D /var/lib/postgresql/data --auth=trust
    
    # PostgreSQL yapılandırmasını güncelle
    cat >> /var/lib/postgresql/data/postgresql.conf <<EOL
listen_addresses = '*'
port = 5432
unix_socket_directories = '/var/run/postgresql'
EOL

    # Kimlik doğrulama yapılandırmasını güncelle
    cat > /var/lib/postgresql/data/pg_hba.conf <<EOL
local   all             all                                     trust
host    all             all             127.0.0.1/32           trust
host    all             all             ::1/128                trust
host    all             all             0.0.0.0/0              trust
EOL
fi

# PostgreSQL socket dizinini oluştur
mkdir -p /var/run/postgresql
chown -R postgres:postgres /var/run/postgresql

# PostgreSQL servisini başlat
echo "PostgreSQL servisi başlatılıyor..."
gosu postgres pg_ctl -D /var/lib/postgresql/data -l /var/log/postgresql/postgresql.log start

# PostgreSQL'in başlamasını bekle
until gosu postgres pg_isready -h localhost; do
    echo "PostgreSQL başlatılıyor..."
    sleep 2
done

echo "PostgreSQL başarıyla başlatıldı."

# Tüm bağlantıları kes ve veritabanını zorla sil
echo "Veritabanı temizleniyor..."
gosu postgres psql -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='nominatimtest12';"
gosu postgres dropdb --if-exists --force nominatimtest12

# PostgreSQL kullanıcılarını oluştur
echo "PostgreSQL kullanıcıları oluşturuluyor..."
gosu postgres psql -c "DROP ROLE IF EXISTS nominatim;"
gosu postgres psql -c "DROP ROLE IF EXISTS \"www-data\";"
gosu postgres createuser -s nominatim
gosu postgres createuser -SDR "www-data"
gosu postgres psql -c "ALTER USER nominatim WITH PASSWORD 'nominatim';"

# PostGIS eklentisini etkinleştir
echo "PostGIS eklentisi yükleniyor..."
gosu postgres psql -c "CREATE EXTENSION IF NOT EXISTS postgis;" template1

# Veri import et
if [ ! -f "/app/nominatim-project/imported" ]; then
    echo "Veri import ediliyor..."
    
    # Nominatim'in kendi veritabanı oluşturmasına izin ver
    ./nominatim-venv/bin/nominatim import --osm-file /app/turkey-data.osm.pbf --project-dir /app/nominatim-project
    
    # Import başarılı olduysa işaretleyelim
    if [ $? -eq 0 ]; then
        touch /app/nominatim-project/imported
    fi
fi

# Nominatim servisini başlat
echo "Nominatim servisi başlatılıyor..."
cd /app
source nominatim-venv/bin/activate

# Servis başlatma komutu
exec ./nominatim-venv/bin/nominatim serve 

