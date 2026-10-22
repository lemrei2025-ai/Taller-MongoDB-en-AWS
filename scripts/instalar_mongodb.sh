#!/usr/bin/env bash
# =============================================================================
# Taller MongoDB + AWS + Google Colab
# Instala MongoDB 8.0 en Red Hat Enterprise Linux 9 o 10, carga los datos del
# taller en la base "cundinamarca", crea un usuario y habilita el acceso remoto
# con contraseña.
#
# Uso (en la instancia EC2, conectado como ec2-user):
#   curl -fsSLO https://raw.githubusercontent.com/lemrei2025-ai/Taller-MongoDB-en-AWS/refs/heads/main/scripts/instalar_mongodb.sh
#   bash instalar_mongodb.sh
# =============================================================================
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/lemrei2025-ai/Taller-MongoDB-en-AWS/refs/heads/main"
BD="cundinamarca"
COLECCION="produccion_agricola"
USUARIO="taller"
VERSION_RHEL=$(rpm -E %rhel)

echo "==> 1/7 Definiendo la contraseña del usuario '$USUARIO'"
read -rsp "Escriba una contraseña para MongoDB: " CLAVE < /dev/tty; echo
if [ -z "$CLAVE" ]; then echo "La contraseña no puede estar vacía."; exit 1; fi

echo "==> 2/7 Agregando el repositorio oficial de MongoDB 8.0 (RHEL $VERSION_RHEL)"
sudo tee /etc/yum.repos.d/mongodb-org-8.0.repo > /dev/null <<EOF
[mongodb-org-8.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/${VERSION_RHEL}/mongodb-org/8.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-8.0.asc
EOF

echo "==> 3/7 Instalando MongoDB (tarda 1-2 minutos)"
sudo dnf install -y -q mongodb-org

echo "==> 4/7 Configurando SELinux para MongoDB"
if [ "$(getenforce 2>/dev/null || echo Disabled)" = "Enforcing" ]; then
  sudo dnf install -y -q git make checkpolicy policycoreutils selinux-policy-devel
  rm -rf /tmp/mongodb-selinux
  git clone -q https://github.com/mongodb/mongodb-selinux /tmp/mongodb-selinux
  make -s -C /tmp/mongodb-selinux
  sudo make -s -C /tmp/mongodb-selinux install
else
  echo "SELinux no está en modo Enforcing; no se requiere política."
fi

sudo systemctl daemon-reload
sudo systemctl enable --now mongod
until mongosh --quiet --eval "db.runCommand({ping:1}).ok" > /dev/null 2>&1; do sleep 2; done

echo "==> 5/7 Cargando los datos en $BD.$COLECCION"
curl -fsSL "$REPO_RAW/datos/produccion_agricola.json" -o /tmp/produccion_agricola.json
mongoimport --quiet --db "$BD" --collection "$COLECCION" --drop --jsonArray \
  --file /tmp/produccion_agricola.json
mongosh --quiet "$BD" --eval "print('Documentos cargados: ' + db.$COLECCION.countDocuments())"

echo "==> 6/7 Creando el usuario '$USUARIO' con permisos sobre '$BD'"
CLAVE="$CLAVE" mongosh --quiet admin --eval "
  if (db.getUser('$USUARIO')) { db.dropUser('$USUARIO'); }
  db.createUser({user: '$USUARIO', pwd: process.env.CLAVE,
                 roles: [{role: 'readWrite', db: '$BD'}]});
  print('Usuario creado.');
"

echo "==> 7/7 Habilitando acceso remoto con autenticación"
sudo sed -i 's/^\(\s*bindIp:\).*/\1 0.0.0.0/' /etc/mongod.conf
if ! grep -q '^security:' /etc/mongod.conf; then
  printf '\nsecurity:\n  authorization: enabled\n' | sudo tee -a /etc/mongod.conf > /dev/null
fi
if systemctl is-active --quiet firewalld; then
  sudo firewall-cmd --quiet --permanent --add-port=27017/tcp
  sudo firewall-cmd --quiet --reload
  echo "Puerto 27017 abierto en firewalld."
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
