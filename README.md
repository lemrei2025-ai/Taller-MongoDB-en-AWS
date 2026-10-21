# Taller: MongoDB en AWS + análisis con Pandas en Google Colab

**Enlace al cuaderno en Google Colab:** [taller_mongodb_pandas.ipynb](https://colab.research.google.com/github/TU_USUARIO/taller-mongodb-aws-colab/blob/main/notebooks/taller_mongodb_pandas.ipynb)

En este taller se instala una base de datos **MongoDB** en un servidor **Red Hat Enterprise Linux** de **AWS (capa gratuita)**, se cargan datos de producción agrícola de Cundinamarca y se analizan desde **Google Colab** con **Pandas**.

**Duración:** 45 minutos · **Nivel:** básico · **Costo:** $0 con la capa gratuita de AWS

---

## Agenda

| Tiempo | Bloque | Guía |
|---|---|---|
| 0 – 5 min | Presentación y requisitos | Este archivo |
| 5 – 15 min | Crear el servidor Red Hat en AWS (EC2) y conectarse por SSH | [01 · Servidor en AWS](docs/01-servidor-aws.md) |
| 15 – 23 min | Instalar MongoDB y cargar los datos | [02 · Instalar MongoDB](docs/02-instalar-mongodb.md) |
| 23 – 40 min | Análisis con Pandas en Google Colab | [03 · Análisis en Colab](docs/03-analisis-colab.md) |
| 40 – 45 min | Cierre y **apagado del servidor** | [04 · Cierre](docs/04-cierre.md) |

## Arquitectura

```
┌────────────────────┐   Internet, puerto 27017   ┌──────────────────────────┐
│   Google Colab     │ ─────────────────────────▶ │  AWS EC2 (Red Hat 9/10)  │
│  Python + Pandas   │   usuario y contraseña     │  MongoDB 8.0             │
│  pymongo           │ ◀───────────────────────── │  base: cundinamarca      │
└────────────────────┘        documentos          └──────────────────────────┘
```

## Requisitos previos

Cada participante necesita, **antes de iniciar el taller**:

1. Una **cuenta de AWS** activa (la creación y verificación de la cuenta puede tardar varias horas, por eso se hace antes).
2. Una **cuenta de Google** para usar Google Colab.
3. Un navegador web y una terminal con SSH: **PowerShell** en Windows 10/11 o **Terminal** en macOS y Linux. Ambas traen SSH incluido, por lo que no se requiere instalar nada adicional.

## Los datos

La colección `produccion_agricola` contiene **276 registros** de producción por municipio, cultivo y año (2022 – 2025):

```json
{"municipio": "Zipaquirá", "provincia": "Sabana Centro", "cultivo": "Fresa",
 "anio": 2024, "hectareas": 123.9, "toneladas": 2754.1}
```

> **Nota:** Los municipios y provincias son reales, pero **las cifras de hectáreas y toneladas son ficticias**, generadas con fines didácticos. No representan estadísticas oficiales.

## Estructura del repositorio

```
taller-mongodb-aws-colab/
├── README.md                     # esta guía y la agenda
├── docs/
│   ├── 01-servidor-aws.md        # crear la instancia EC2
│   ├── 02-instalar-mongodb.md    # instalar MongoDB y cargar datos
│   ├── 03-analisis-colab.md      # ejercicio en Colab
│   └── 04-cierre.md              # retos y apagado del servidor
├── scripts/
│   └── instalar_mongodb.sh       # instalación automática en un solo comando
├── datos/
│   └── produccion_agricola.json  # datos del taller
└── notebooks/
    └── taller_mongodb_pandas.ipynb
```

## Para quien dirige el taller

- Al publicar el repositorio, se reemplaza `TU_USUARIO` por el usuario real de GitHub en: este README, `scripts/instalar_mongodb.sh` y `docs/02-instalar-mongodb.md`. El repositorio debe ser **público** para que el script descargue los datos y funcione el enlace de Colab.
- El mayor riesgo de tiempo es la creación de la instancia en AWS. Conviene hacer una demostración en pantalla mientras los participantes siguen los pasos.
- Si algún participante no logra conectarse a su servidor, puede usar el servidor de quien dirige el taller (con un usuario de solo lectura) para no quedarse atrás en el bloque de Colab.
