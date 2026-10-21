# 03 · Análisis con Pandas en Google Colab (17 minutos)

[Anterior: Instalar MongoDB](02-instalar-mongodb.md) · [Siguiente: Cierre](04-cierre.md)

## Abrir el cuaderno

Se abre el enlace y se inicia sesión con la cuenta de Google:

**Enlace al cuaderno en Google Colab:** [taller_mongodb_pandas.ipynb](https://colab.research.google.com/github/TU_USUARIO/taller-mongodb-aws-colab/blob/main/notebooks/taller_mongodb_pandas.ipynb)

> Para guardar cambios propios: **Archivo → Guardar una copia en Drive**.

## Recorrido del cuaderno

| Paso | Tiempo | Qué se hace |
|---|---|---|
| 1. Instalación | 1 min | Se instala `pymongo` |
| 2. Conexión | 3 min | Se escriben la IP del servidor, el usuario `taller` y la contraseña |
| 3. Carga | 2 min | La colección `produccion_agricola` se convierte en un `DataFrame` |
| 4. Revisión y limpieza | 3 min | Tipos de datos, valores faltantes y nueva columna `rendimiento` |
| 5. Estadística descriptiva | 4 min | `describe()`, media vs. mediana, frecuencias |
| 6. Agrupaciones y gráficos | 4 min | `groupby`, tabla dinámica, gráficos de barras y de línea |

Cada celda se ejecuta en orden con `Shift + Enter`.

## Preguntas que se responden con los datos

1. ¿Cuántos registros hay y cuántos tienen datos faltantes?
2. ¿Qué cultivo ocupa más hectáreas en total?
3. ¿Qué cultivo tiene mayor **rendimiento** (toneladas por hectárea)?
4. ¿Qué provincia produce más papa?
5. ¿Cómo cambia la producción total entre 2022 y 2025?

## Si la conexión falla

El error típico es `ServerSelectionTimeoutError` después de unos 10 segundos.

| Revisar | Dónde |
|---|---|
| La IP es la **pública** (no la que empieza por `172.`) | Consola EC2 → instancia → *Public IPv4 address* |
| Existe la regla de entrada del puerto **27017** | EC2 → instancia → pestaña *Security* → *Security groups* |
| MongoDB está corriendo | En el servidor: `sudo systemctl status mongod` |

Si el error es `Authentication failed`, el usuario o la contraseña no coinciden con los del script.

---

[Siguiente: Cierre](04-cierre.md)
