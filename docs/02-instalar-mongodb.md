# 02 · Instalar MongoDB y cargar los datos (8 minutos)

[Anterior: Servidor en AWS](01-servidor-aws.md) · [Siguiente: Análisis en Colab](03-analisis-colab.md)

En la terminal del servidor Red Hat se ejecuta un script que hace todo el trabajo en un solo paso.

## Opción rápida (recomendada para el taller)

Se copian y pegan estas dos líneas en la terminal SSH:

```bash
curl -fsSLO https://raw.githubusercontent.com/TU_USUARIO/taller-mongodb-aws-colab/main/scripts/instalar_mongodb.sh
bash instalar_mongodb.sh
```

El script pide una **contraseña** para MongoDB (no se ve al escribirla) y luego:

1. Detecta la versión de Red Hat (9 o 10) y agrega el repositorio oficial de MongoDB 8.0.
2. Instala MongoDB con `dnf`.
3. Si SELinux está activo (modo *Enforcing*, el valor por defecto en Red Hat), instala la política oficial de MongoDB para SELinux.
4. Inicia MongoDB como servicio.
5. Descarga `produccion_agricola.json` y lo carga en la base **`cundinamarca`**.
6. Crea el usuario **`taller`** con permiso de lectura y escritura sobre esa base.
7. Habilita el acceso remoto (`bindIp: 0.0.0.0`) **con autenticación obligatoria** y, si `firewalld` está activo, abre el puerto 27017.

Al terminar (entre 3 y 4 minutos) se muestra algo como:

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
# 1. Repositorio oficial de MongoDB (rpm -E %rhel devuelve 9 o 10)
sudo tee /etc/yum.repos.d/mongodb-org-8.0.repo <<EOF
[mongodb-org-8.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$(rpm -E %rhel)/mongodb-org/8.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-8.0.asc
EOF

# 2. Instalación
sudo dnf install -y mongodb-org

# 3. Política de SELinux para MongoDB
sudo dnf install -y git make checkpolicy policycoreutils selinux-policy-devel
git clone https://github.com/mongodb/mongodb-selinux
cd mongodb-selinux && make && sudo make install && cd ..

# 4. Inicio del servicio
sudo systemctl enable --now mongod

# 5. Carga de datos
curl -fsSLO https://raw.githubusercontent.com/TU_USUARIO/taller-mongodb-aws-colab/main/datos/produccion_agricola.json
mongoimport --db cundinamarca --collection produccion_agricola --jsonArray --file produccion_agricola.json

# 6. Usuario de la base
mongosh admin --eval 'db.createUser({user:"taller", pwd:"CAMBIAR_CLAVE", roles:[{role:"readWrite", db:"cundinamarca"}]})'

# 7. Acceso remoto con autenticación
sudo sed -i 's/^\(\s*bindIp:\).*/\1 0.0.0.0/' /etc/mongod.conf
printf '\nsecurity:\n  authorization: enabled\n' | sudo tee -a /etc/mongod.conf
sudo systemctl restart mongod
```

Si `firewalld` está activo en el servidor (`systemctl is-active firewalld` responde `active`), también se abre el puerto:

```bash
sudo firewall-cmd --permanent --add-port=27017/tcp
sudo firewall-cmd --reload
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
| `sudo systemctl status mongod` muestra `failed` | Error en `/etc/mongod.conf` o bloqueo de SELinux | `sudo tail -n 20 /var/log/mongodb/mongod.log` y `sudo ausearch -m avc -ts recent` |
| `Error: Failed to download metadata for repo 'mongodb-org-8.0'` | Versión de Red Hat no soportada | Usar una imagen de Red Hat 9 o 10 de 64 bits (x86) |

---

[Siguiente: Análisis en Colab](03-analisis-colab.md)
