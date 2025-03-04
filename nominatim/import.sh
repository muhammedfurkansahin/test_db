#!/bin/bash

# Veri import edilmiş mi kontrol et
if [ ! -f /data/nominatim/imported ]; then
    # Nominatim import işlemini başlat
    /app/init.sh

    # Import başarılı olduysa işaretle
    if [ $? -eq 0 ]; then
        touch /data/nominatim/imported
    fi
fi

# Apache2 servisini başlat
apache2ctl start

# Servisi başlat
/app/start.sh 