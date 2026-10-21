#!/usr/bin/env bash
# =============================================================================
# Taller MongoDB + AWS + Google Colab
# Instala MongoDB 8.0 en Ubuntu 24.04, carga los datos del taller en la base
# "cundinamarca", crea un usuario y habilita el acceso remoto con contraseña.
#
# Uso (en la instancia EC2):
#   curl -fsSLO https://raw.githubusercontent.com/TU_USUARIO/taller-mongodb-aws-colab/main/scripts/instalar_mongodb.sh
#   bash instalar_mongodb.sh
# =============================================================================
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/TU_USUARIO/taller-mongodb-aws-colab/main"
BD="cundinamarca"
COLECCION="produccion_agricola"
USUARIO="taller"

echo "==> 1/6 Definiendo la contraseña del usuario '$USUARIO'"
read -rsp "Escriba una contraseña para MongoDB: " CLAVE < /dev/tty; echo
if [ -z "$CLAVE" ]; then echo "La contraseña no puede estar vacía."; exit 1; fi

echo "==> 2/6 Agregando el repositorio oficial de MongoDB 8.0"
sudo apt-get update -qq
sudo apt-get install -y -qq gnupg curl
curl -fsSL https://pgp.mongodb.com/server-8.0.asc \
  | sudo gpg --yes -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" \
  | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list > /dev/null

echo "==> 3/6 Instalando MongoDB (tarda 1-2 minutos)"
sudo apt-get update -qq
sudo apt-get install -y -qq mongodb-org
sudo systemctl daemon-reload
sudo systemctl enable --now mongod
until mongosh --quiet --eval "db.runCommand({ping:1}).ok" > /dev/null 2>&1; do sleep 2; done

echo "==> 4/6 Cargando los datos en $BD.$COLECCION"
curl -fsSL "$REPO_RAW/datos/produccion_agricola.json" -o /tmp/produccion_agricola.json
mongoimport --quiet --db "$BD" --collection "$COLECCION" --drop --jsonArray \
  --file /tmp/produccion_agricola.json
mongosh --quiet "$BD" --eval "print('Documentos cargados: ' + db.$COLECCION.countDocuments())"

echo "==> 5/6 Creando el usuario '$USUARIO' con permisos sobre '$BD'"
CLAVE="$CLAVE" mongosh --quiet admin --eval "
  if (db.getUser('$USUARIO')) { db.dropUser('$USUARIO'); }
  db.createUser({user: '$USUARIO', pwd: process.env.CLAVE,
                 roles: [{role: 'readWrite', db: '$BD'}]});
  print('Usuario creado.');
"

echo "==> 6/6 Habilitando acceso remoto con autenticación"
sudo sed -i 's/^\(\s*bindIp:\).*/\1 0.0.0.0/' /etc/mongod.conf
if ! grep -q '^security:' /etc/mongod.conf; then
  printf '\nsecurity:\n  authorization: enabled\n' | sudo tee -a /etc/mongod.conf > /dev/null
fi
sudo systemctl restart mongod
sleep 3

IP=$(curl -fsS -m 3 https://checkip.amazonaws.com || echo "IP_PUBLICA")
echo
echo "============================================================"
echo " MongoDB quedó listo."
echo " Datos de conexión para Google Colab:"
echo "   IP_SERVIDOR = \"$IP\""
echo "   PUERTO      = 27017"
echo "   USUARIO     = \"$USUARIO\""
echo "   CLAVE       = (la que acaba de escribir)"
echo "============================================================"
