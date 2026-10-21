# 04 · Cierre y apagado del servidor (5 minutos)

[Anterior: Análisis en Colab](03-analisis-colab.md) · [Volver a la agenda](../README.md)

## Lo que se logró

- Se creó un servidor Linux en AWS dentro de la capa gratuita.
- Se instaló MongoDB, se cargaron datos y se protegió el acceso con usuario y contraseña.
- Se leyó una colección de MongoDB desde Google Colab y se convirtió en un `DataFrame`.
- Se calcularon estadísticas descriptivas, agrupaciones y gráficos con Pandas.

## Eliminar el servidor (obligatorio)

Una instancia encendida consume horas de la capa gratuita y, con el puerto 27017 abierto, queda expuesta en internet. Al terminar el taller se elimina:

1. Consola de AWS → **EC2** → **Instances**.
2. Se selecciona `mongodb-taller`.
3. **Instance state** → **Terminate (delete) instance** → **Terminate**.

> En cuentas con el plan gratuito nuevo, lanzar y terminar una instancia EC2 es una de las actividades que otorgan créditos adicionales.

Si se desea conservar el servidor para seguir practicando, la alternativa es **Stop instance**: se detiene sin borrarse, pero la IP pública cambia al volver a encenderla.

## Retos para practicar en casa

1. Calcular el rendimiento promedio por **provincia** y ordenarlo de mayor a menor.
2. Traer desde MongoDB solo los registros de café con un filtro: `coleccion.find({"cultivo": "Café"}, {"_id": 0})`.
3. Hacer en MongoDB la misma agrupación que se hizo en Pandas, usando `coleccion.aggregate(...)` con `$group`.
4. Insertar un nuevo registro desde Colab con `coleccion.insert_one({...})` y verificar que aparece al recargar el `DataFrame`.
5. Exportar el `DataFrame` limpio a CSV con `df.to_csv("produccion.csv", index=False)`.

## Recursos

- [Documentación oficial: instalar MongoDB en Ubuntu](https://www.mongodb.com/docs/v8.0/tutorial/install-mongodb-on-ubuntu/)
- [Documentación de PyMongo](https://pymongo.readthedocs.io/)
- [Guía de inicio de Pandas](https://pandas.pydata.org/docs/getting_started/index.html)
- [Capa gratuita de AWS](https://aws.amazon.com/free/)
