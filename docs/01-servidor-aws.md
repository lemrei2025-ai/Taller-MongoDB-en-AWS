# 01 · Crear el servidor en AWS (10 minutos)

[Volver a la agenda](../README.md) · [Siguiente: Instalar MongoDB](02-instalar-mongodb.md)

En este bloque se crea una máquina virtual con **Red Hat Enterprise Linux (RHEL)**, una **instancia EC2**, dentro de la capa gratuita de AWS.

> **Sobre la capa gratuita:** las cuentas creadas desde el 15 de julio de 2025 reciben un *plan gratuito* con créditos (USD 100 al registrarse y hasta USD 100 más por completar actividades, una de ellas es justamente lanzar y terminar una instancia EC2), válido por 6 meses. Las cuentas anteriores conservan la capa gratuita clásica de 12 meses. En ambos casos, el taller no genera costos si se usan una imagen y un tipo de instancia marcados como **"Free tier eligible"** y la instancia se elimina al terminar.

## Paso 1. Abrir el servicio EC2

1. Se inicia sesión en la [consola de AWS](https://console.aws.amazon.com/).
2. En la esquina superior derecha se elige una región cercana, por ejemplo **US East (N. Virginia) `us-east-1`**.
3. En el buscador superior se escribe **EC2** y se abre el servicio.
4. Se hace clic en **Launch instance** (Lanzar instancia).

## Paso 2. Configurar la instancia

| Campo | Valor |
|---|---|
| **Name** | `mongodb-taller` |
| **Application and OS Images (AMI)** | Pestaña **Red Hat** → **Red Hat Enterprise Linux 9** o **10**, arquitectura **64-bit (x86)**, con la etiqueta *Free tier eligible* |
| **Instance type** | **t3.micro** (o la que muestre la etiqueta *Free tier eligible*) |
| **Key pair (login)** | **Create new key pair** → nombre `mongodb-taller`, tipo **RSA**, formato **.pem** → **Create key pair**. El navegador descarga el archivo `mongodb-taller.pem`. |

> **Importante:** el archivo `.pem` es la llave para entrar al servidor y AWS no permite descargarlo de nuevo. Se guarda en una carpeta conocida, por ejemplo *Descargas*. A diferencia de Ubuntu, las imágenes de Red Hat no traen habilitada la conexión desde el navegador (*EC2 Instance Connect*), por eso se usa SSH con esta llave.

## Paso 3. Configurar la red (Security Group)

En **Network settings** se hace clic en **Edit** y se deja así:

| Regla | Tipo | Puerto | Origen | Para qué sirve |
|---|---|---|---|---|
| 1 | SSH | 22 | `0.0.0.0/0` (o *My IP*) | Entrar a la terminal del servidor |
| 2 | Custom TCP | **27017** | `0.0.0.0/0` | Que Google Colab llegue a MongoDB |

Para agregar la regla 2 se usa **Add security group rule**.

> **Seguridad:** abrir el puerto 27017 a todo internet (`0.0.0.0/0`) es necesario porque Google Colab no tiene una IP fija. Por eso el script del siguiente paso **obliga a usar usuario y contraseña**, y al final del taller el servidor se elimina.

## Paso 4. Lanzar la instancia

1. El almacenamiento se deja en el valor por defecto y se hace clic en **Launch instance**.
2. Se hace clic en el identificador de la instancia (`i-0abc…`) y se espera a que el estado diga **Running** (aproximadamente 1 minuto).
3. Se copia la **Public IPv4 address** (por ejemplo `34.201.138.106`). Se usará para SSH y en Colab.

## Paso 5. Conectarse por SSH

Se abre una terminal en el computador del participante: **PowerShell** en Windows o **Terminal** en macOS y Linux. Luego se va a la carpeta donde quedó la llave y se conecta con el usuario **`ec2-user`** (el usuario por defecto de Red Hat en AWS):

**Windows (PowerShell):**

```powershell
cd $HOME\Downloads
ssh -i .\mongodb-taller.pem ec2-user@34.201.138.106
```

**macOS / Linux:**

```bash
cd ~/Downloads
chmod 400 mongodb-taller.pem
ssh -i mongodb-taller.pem ec2-user@34.201.138.106
```

La primera vez aparece la pregunta `Are you sure you want to continue connecting?` y se responde `yes`. Al entrar se ve un indicador similar a este:

```
[ec2-user@ip-172-31-25-10 ~]$
```

**Punto de control:** la terminal del servidor está abierta y la IP pública está anotada.

## Si la conexión SSH falla

| Mensaje | Causa probable | Solución |
|---|---|---|
| `Connection timed out` | Falta la regla del puerto 22 o la IP no es la pública | Revisar el Security Group y la *Public IPv4 address* |
| `Permission denied (publickey)` | Usuario incorrecto o llave equivocada | El usuario es `ec2-user` y la llave es `mongodb-taller.pem` |
| `UNPROTECTED PRIVATE KEY FILE` (macOS/Linux) | Permisos muy abiertos en la llave | `chmod 400 mongodb-taller.pem` |
| `UNPROTECTED PRIVATE KEY FILE` (Windows) | Permisos muy abiertos en la llave | `icacls .\mongodb-taller.pem /inheritance:r /grant:r "$($env:USERNAME):R"` |

---

[Siguiente: Instalar MongoDB](02-instalar-mongodb.md)
