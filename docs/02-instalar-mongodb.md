# 02 · Instalar MongoDB y cargar los datos (8 minutos)

[Anterior: Servidor en AWS](01-servidor-aws.md) · [Siguiente: Análisis en Colab](03-analisis-colab.md)

En la terminal del servidor se ejecuta un script que hace todo el trabajo en un solo paso.

## Opción rápida (recomendada para el taller)

Se copian y pegan estas dos líneas en la terminal de EC2 Instance Connect:

```bash
curl -fsSLO https://raw.githubusercontent.com/TU_USUARIO/taller-mongodb-aws-colab/main/scripts/instalar_mongodb.sh
bash instalar_mongodb.sh
```

El script pide una **contraseña** para MongoDB (no se ve al escribirla) y luego:

1. Agrega el repositorio oficial de MongoDB 8.0 para Ubuntu 24.04.
2. Instala MongoDB y lo deja iniciado como servicio.
3. Descarga `produccion_agricola.json` y lo carga en la base **`cundinamarca`**.
4. Crea el usuario **`taller`** con permiso de lectura y escritura sobre esa base.
5. Habilita el acceso remoto (`bindIp: 0.0.0.0`) **con autenticación obligatoria**.

Al terminar (≈ 3 minutos) se muestra algo como:

```
Documentos cargados: 276
Usuario creado.
============================================================
 MongoDB quedó listo.
 Datos de conexión para Google Colab:
   IP_SERVIDOR = "34.201.138.106"
   PUERTO      = 27017
   USUARIO     = "taller"
   CLAVE       = (la que acaba de escribir)
============================================================
```

**Punto de control:** aparece el mensaje "MongoDB quedó listo" con 276 documentos cargados.

## ¿Qué hizo el script? (versión manual)

Esto es lo mismo que ejecuta el script, para entender cada paso o realizarlo de forma manual:

```bash
# 1. Repositorio oficial de MongoDB
sudo apt-get install -y gnupg curl
curl -fsSL https://pgp.mongodb.com/server-8.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list

# 2. Instalación e inicio del servicio
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo systemctl enable --now mongod

# 3. Carga de datos
curl -fsSLO https://raw.githubusercontent.com/TU_USUARIO/taller-mongodb-aws-colab/main/datos/produccion_agricola.json
mongoimport --db cundinamarca --collection produccion_agricola --jsonArray --file produccion_agricola.json

# 4. Usuario de la base
mongosh admin --eval 'db.createUser({user:"taller", pwd:"CAMBIAR_CLAVE", roles:[{role:"readWrite", db:"cundinamarca"}]})'

# 5. Acceso remoto con autenticación
sudo sed -i 's/^\(\s*bindIp:\).*/\1 0.0.0.0/' /etc/mongod.conf
printf '\nsecurity:\n  authorization: enabled\n' | sudo tee -a /etc/mongod.conf
sudo systemctl restart mongod
```

## Comprobación opcional en el servidor

```bash
mongosh -u taller -p --authenticationDatabase admin cundinamarca --eval 'db.produccion_agricola.findOne()'
```

## Si algo falla

| Síntoma | Causa probable | Solución |
|---|---|---|
| `Unit mongod.service not found` | systemd no recargó los servicios | `sudo systemctl daemon-reload && sudo systemctl start mongod` |
| `curl: (22) ... 404` al descargar | El repositorio no es público o falta cambiar `TU_USUARIO` | Revisar la URL del repositorio |
| `sudo systemctl status mongod` muestra `failed` | Error en `/etc/mongod.conf` | `sudo tail -n 20 /var/log/mongodb/mongod.log` |

---

[Siguiente: Análisis en Colab](03-analisis-colab.md)
