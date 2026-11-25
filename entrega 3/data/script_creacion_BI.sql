/* =====================================================================
   TP GDD 2C 2026 - FRBA Gestion de Bicicleteria
   Grupo: MEGA_DB (13) - Curso K3623
   Script de creacion y carga del modelo BI.
   Ejecutar despues del script de creacion inicial, una sola vez.
   Para volver a cargar los datos: EXEC MEGA_DB.BI_Cargar_Modelo
   ===================================================================== */

USE GD2C_2026
GO
SET NOCOUNT ON;
GO

/* =====================================================================
   1. CREACION DE TABLAS
   Se conservan los IDs del transaccional. Las dimensiones de dominio
   propias de BI se cargan con IDs fijos.
   ===================================================================== */

--Meses en los que hubo alguna operacio
CREATE TABLE MEGA_DB.[BI_Tiempo] (
    [tiempo_id] INT PRIMARY KEY,
    [anio] INT NOT NULL,
    [trimestre] INT NOT NULL CHECK ([trimestre] BETWEEN 1 AND 4),
    [mes] INT NOT NULL CHECK ([mes] BETWEEN 1 AND 12),
    UNIQUE ([anio], [mes])
);
GO

--Locales con su localidad y provincia
CREATE TABLE MEGA_DB.[BI_Local] (
    [local_id] INT PRIMARY KEY,
    [nombre] VARCHAR(255) NOT NULL,
    [localidad] VARCHAR(255) NOT NULL,
    [provincia] VARCHAR(255) NOT NULL
);
GO

--Rangos de edad del cliente al momento de la venta
CREATE TABLE MEGA_DB.[BI_Rango_Etario] (
    [rango_etario_id] INT PRIMARY KEY,
    [descripcion] VARCHAR(255) NOT NULL,
    [edad_desde] INT NULL,
    [edad_hasta] INT NULL
);
GO

--Tipos de producto
CREATE TABLE MEGA_DB.[BI_Tipo_Producto] (
    [tipo_producto_id] INT PRIMARY KEY,
    [descripcion] VARCHAR(255) NOT NULL
);
GO

--Categorias de bicicletas
CREATE TABLE MEGA_DB.[BI_Categoria_Bicicleta] (
    [categoria_bicicleta_id] INT PRIMARY KEY,
    [descripcion] VARCHAR(255) NOT NULL
);
GO

--Categorias de repuestos
CREATE TABLE MEGA_DB.[BI_Categoria_Repuesto] (
    [categoria_repuesto_id] INT PRIMARY KEY,
    [descripcion] VARCHAR(255) NOT NULL
);
GO

--Tipos de ingreso de una reparacion: mano de obra y repuestos
CREATE TABLE MEGA_DB.[BI_Tipo_Ingreso_Reparacion] (
    [tipo_ingreso_id] INT PRIMARY KEY,
    [descripcion] VARCHAR(255) NOT NULL
);
GO

--Una fila por venta; se conserva el total original de la cabecera
CREATE TABLE MEGA_DB.[BI_Venta] (
    [venta_id] INT PRIMARY KEY,
    [tiempo_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Tiempo]([tiempo_id]),
    [local_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Local]([local_id]),
    [rango_etario_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Rango_Etario]([rango_etario_id]),
    [total] NUMERIC(38,2) NOT NULL
);
GO

--Una fila por detalle de venta, con su tipo de producto y subtotal original
CREATE TABLE MEGA_DB.[BI_Venta_Detalle] (
    [venta_detalle_id] INT PRIMARY KEY,
    [venta_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Venta]([venta_id]),
    [tipo_producto_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Tipo_Producto]([tipo_producto_id]),
    [cantidad] INT NOT NULL,
    [subtotal] NUMERIC(38,2) NOT NULL
);
GO

--Una fila por alquiler, con la duracion real en horas si se conoce
CREATE TABLE MEGA_DB.[BI_Alquiler] (
    [alquiler_id] INT PRIMARY KEY,
    [tiempo_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Tiempo]([tiempo_id]),
    [local_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Local]([local_id]),
    [categoria_bicicleta_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Categoria_Bicicleta]([categoria_bicicleta_id]),
    [horas_reales] DECIMAL(20,6) NULL,
    [importe_total] NUMERIC(38,2) NOT NULL
);
GO

--Una fila por reparacion, con su total y desvio de entrega en dias
CREATE TABLE MEGA_DB.[BI_Reparacion] (
    [reparacion_id] INT PRIMARY KEY,
    [tiempo_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Tiempo]([tiempo_id]),
    [local_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Local]([local_id]),
    [desvio_dias] DECIMAL(20,6) NULL,
    [precio_total] NUMERIC(38,2) NOT NULL
);
GO

--Dos filas por reparacion: mano de obra y repuestos
CREATE TABLE MEGA_DB.[BI_Ingreso_Reparacion] (
    [reparacion_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Reparacion]([reparacion_id]),
    [tipo_ingreso_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Tipo_Ingreso_Reparacion]([tipo_ingreso_id]),
    [importe] NUMERIC(38,2) NOT NULL,
    PRIMARY KEY ([reparacion_id], [tipo_ingreso_id])
);
GO

--Una fila por renglon de repuesto usado, con su categoria y cantidad
CREATE TABLE MEGA_DB.[BI_Reparacion_Repuesto] (
    [reparacion_repuesto_id] INT PRIMARY KEY,
    [reparacion_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Reparacion]([reparacion_id]),
    [categoria_repuesto_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Categoria_Repuesto]([categoria_repuesto_id]),
    [cantidad] INT NOT NULL
);
GO

--Una fila por compra; se conserva el total original de la cabecera
CREATE TABLE MEGA_DB.[BI_Compra] (
    [compra_id] INT PRIMARY KEY,
    [tiempo_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Tiempo]([tiempo_id]),
    [local_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Local]([local_id]),
    [total] NUMERIC(38,2) NOT NULL
);
GO

--Una fila por renglon de compra, con tipo de producto y cantidad
CREATE TABLE MEGA_DB.[BI_Compra_Detalle] (
    [compra_detalle_id] INT PRIMARY KEY,
    [compra_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Compra]([compra_id]),
    [tipo_producto_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Tipo_Producto]([tipo_producto_id]),
    [cantidad] INT NOT NULL
);
GO

/* =====================================================================
   2. MIGRACION AL MODELO BI
   Se realiza una carga completa desde las tablas del modelo relacional.
   ===================================================================== */

CREATE PROCEDURE MEGA_DB.BI_Cargar_Modelo
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN

        --Si se vuelve a ejecutar el SP, primero se eliminan los datos anteriores.
        DELETE FROM MEGA_DB.BI_Compra_Detalle;
        DELETE FROM MEGA_DB.BI_Reparacion_Repuesto;
        DELETE FROM MEGA_DB.BI_Ingreso_Reparacion;
        DELETE FROM MEGA_DB.BI_Venta_Detalle;
        DELETE FROM MEGA_DB.BI_Compra;
        DELETE FROM MEGA_DB.BI_Reparacion;
        DELETE FROM MEGA_DB.BI_Alquiler;
        DELETE FROM MEGA_DB.BI_Venta;
        DELETE FROM MEGA_DB.BI_Tipo_Ingreso_Reparacion;
        DELETE FROM MEGA_DB.BI_Categoria_Repuesto;
        DELETE FROM MEGA_DB.BI_Categoria_Bicicleta;
        DELETE FROM MEGA_DB.BI_Tipo_Producto;
        DELETE FROM MEGA_DB.BI_Rango_Etario;
        DELETE FROM MEGA_DB.BI_Local;
        DELETE FROM MEGA_DB.BI_Tiempo;

        --Tiempo: se toman los meses de las cuatro operaciones.
        INSERT INTO MEGA_DB.BI_Tiempo (tiempo_id, anio, trimestre, mes)
        SELECT DISTINCT YEAR(fecha) * 100 + MONTH(fecha),
                        YEAR(fecha), DATEPART(QUARTER, fecha), MONTH(fecha)
        FROM (
            SELECT fecha_venta AS fecha FROM MEGA_DB.Venta
            UNION ALL
            SELECT fecha_inicio FROM MEGA_DB.Alquiler
            UNION ALL
            SELECT fecha_ingreso FROM MEGA_DB.Reparacion
            UNION ALL
            SELECT fecha_compra FROM MEGA_DB.Compra
        ) fechas;

        --Local: se incluye la ubicacion directamente en la dimension.
        INSERT INTO MEGA_DB.BI_Local (local_id, nombre, localidad, provincia)
        SELECT l.local_id, l.nombre, loc.nombre, p.nombre
        FROM MEGA_DB.Local l
        JOIN MEGA_DB.Localidad loc ON loc.localidad_id = l.localidad_id
        JOIN MEGA_DB.Provincia p ON p.provincia_id = loc.provincia_id;

        --Rangos sin superposicion: los limites 25 y 35 quedan en el rango inferior.
        --El rango 0 permite conservar ventas con fecha de nacimiento invalida.
        INSERT INTO MEGA_DB.BI_Rango_Etario (rango_etario_id, descripcion, edad_desde, edad_hasta)
        VALUES (0, 'Sin edad valida', NULL, NULL),
               (1, 'Hasta 25 inclusive', 0, 25),
               (2, '26 a 35 inclusive', 26, 35),
               (3, '36 a 50 inclusive', 36, 50),
               (4, 'Mayores de 50', 51, NULL);

        --Tipos y categorias del modelo relacional.
        INSERT INTO MEGA_DB.BI_Tipo_Producto (tipo_producto_id, descripcion)
        SELECT tipo_producto_id, descripcion FROM MEGA_DB.Tipo_Producto;

        INSERT MEGA_DB.BI_Categoria_Bicicleta (categoria_bicicleta_id, descripcion)
        SELECT categoria_bicicleta_id, descripcion FROM MEGA_DB.Categoria_Bicicleta;

         INSERT INTO MEGA_DB.BI_Categoria_Repuesto (categoria_repuesto_id, descripcion)
        SELECT categoria_repuesto_id, descripcion FROM MEGA_DB.Categoria_Repuesto;

        --Tipos de ingreso establecidos segun el enunciado
        INSERT INTO MEGA_DB.BI_Tipo_Ingreso_Reparacion (tipo_ingreso_id, descripcion)
        VALUES (1, 'Mano de Obra'), (2, 'Repuestos');

        --Calcula la edad del cliente al momento de la venta y asigna su rango etario.
        INSERT INTO MEGA_DB.BI_Venta (venta_id, tiempo_id, local_id, rango_etario_id, total)
        SELECT venta_id,
               YEAR(fecha_venta) * 100 + MONTH(fecha_venta),
               local_id,
               CASE
                   WHEN edad < 0 THEN 0
                   WHEN edad <= 25 THEN 1
                   WHEN edad <= 35 THEN 2
                   WHEN edad <= 50 THEN 3
                   ELSE 4
               END,
               total
        FROM (
            SELECT v.venta_id, v.fecha_venta, v.local_id, v.total,
                   CASE
                       WHEN CAST(p.fecha_nacimiento AS DATE) > CAST(v.fecha_venta AS DATE) THEN -1
                       ELSE DATEDIFF(YEAR, p.fecha_nacimiento, v.fecha_venta) -
                            CASE
                                WHEN DATEADD(YEAR, DATEDIFF(YEAR, p.fecha_nacimiento, v.fecha_venta),
                                             CAST(p.fecha_nacimiento AS DATE)) > CAST(v.fecha_venta AS DATE)
                                THEN 1
                                ELSE 0
                            END
                   END AS edad
            FROM MEGA_DB.Venta v
            JOIN MEGA_DB.Persona p ON p.persona_id = v.cliente_id
        ) edades;
        --Se mantienen los subtotales originales y los renglones repetidos.
        INSERT INTO MEGA_DB.BI_Venta_Detalle 
        (venta_detalle_id, venta_id, tipo_producto_id, cantidad, subtotal)
        SELECT d.venta_detalle_id, d.venta_id, p.tipo_producto_id, d.cantidad, d.subtotal
        FROM MEGA_DB.Venta_Detalle d
        JOIN MEGA_DB.Producto p ON p.producto_id = d.producto_id;

        --Alquileres: se utiliza el local de la bicicleta, no el del empleado.
        --Se calcula la duracion en horas a partir de la diferencia en segundos.
        INSERT INTO MEGA_DB.BI_Alquiler (alquiler_id, tiempo_id, local_id, categoria_bicicleta_id, horas_reales, importe_total)
        SELECT a.alquiler_id,
               YEAR(a.fecha_inicio) * 100 + MONTH(a.fecha_inicio),
               b.local_id,
               m.categoria_bicicleta_id,
               DATEDIFF(SECOND, a.fecha_inicio, a.fecha_devolucion_real) / 3600.0,
               a.importe_total
        FROM MEGA_DB.Alquiler a
        JOIN MEGA_DB.Bicicleta_Alquiler b ON b.bicicleta_alquiler_id = a.bicicleta_alquiler_id
        JOIN MEGA_DB.Modelo_Bicicleta m ON m.modelo_bicicleta_id = b.modelo_bicicleta_id;

        --Reparaciones: se calcula el desvio en dias entre la entrega estimada y la real.
        --Positivo si se entrego tarde, negativo si se entrego antes.
        INSERT INTO MEGA_DB.BI_Reparacion (reparacion_id, tiempo_id, local_id, desvio_dias, precio_total)
        SELECT reparacion_id,
               YEAR(fecha_ingreso) * 100 + MONTH(fecha_ingreso),
               local_id,
               DATEDIFF(SECOND, fecha_entrega_estimada, fecha_entrega_real) / 86400.0,
               precio_total
        FROM MEGA_DB.Reparacion;

        --Se carga un registro por cada tipo de ingreso de la reparacion.
        INSERT INTO MEGA_DB.BI_Ingreso_Reparacion (reparacion_id, tipo_ingreso_id, importe)
        SELECT reparacion_id, 1, precio_mano_obra FROM MEGA_DB.Reparacion;

        INSERT INTO MEGA_DB.BI_Ingreso_Reparacion (reparacion_id, tipo_ingreso_id, importe)
        SELECT reparacion_id, 2, precio_repuestos FROM MEGA_DB.Reparacion;

        --Repuestos usados: se conserva cada renglon y su cantidad.
        INSERT INTO MEGA_DB.BI_Reparacion_Repuesto (reparacion_repuesto_id, reparacion_id, categoria_repuesto_id, cantidad)
        SELECT d.reparacion_repuesto_id, d.reparacion_id, r.categoria_repuesto_id, d.cantidad
        FROM MEGA_DB.Reparacion_Repuesto d
        JOIN MEGA_DB.Repuesto r ON r.repuesto_id = d.repuesto_id;

        --Compras: no se recalcula el total desde los detalles.
        INSERT INTO MEGA_DB.BI_Compra (compra_id, tiempo_id, local_id, total)
        SELECT compra_id, YEAR(fecha_compra) * 100 + MONTH(fecha_compra), local_id, total
        FROM MEGA_DB.Compra;

        INSERT INTO MEGA_DB.BI_Compra_Detalle (compra_detalle_id, compra_id, tipo_producto_id, cantidad)
        SELECT d.compra_detalle_id, d.compra_id, p.tipo_producto_id, d.cantidad
        FROM MEGA_DB.Compra_Detalle d
        JOIN MEGA_DB.Producto p ON p.producto_id = d.producto_id;

        --Si toda la carga termino correctamente se confirman los cambios.
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;
        THROW;
    END CATCH
END
GO

--Se ejecuta la primera carga antes de crear los indices.
EXEC MEGA_DB.BI_Cargar_Modelo;
GO

/* =====================================================================
   3. VISTAS DE INDICADORES
   Las vistas consultan solo el modelo BI.
   ===================================================================== */

--1. Facturacion total mensual de ventas por local.
CREATE VIEW MEGA_DB.BI_01_Facturacion_Ventas_Mensual
AS
SELECT t.anio, t.mes, l.local_id, l.nombre AS local,
       SUM(v.total) AS facturacion
FROM MEGA_DB.BI_Venta v
JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id = v.tiempo_id
JOIN MEGA_DB.BI_Local l ON l.local_id = v.local_id
GROUP BY t.anio, t.mes, l.local_id, l.nombre;
GO

--2. Ticket promedio mensual por tipo de producto y rango etario.
--Se divide el importe vendido por la cantidad de ventas distintas del tipo de producto.
CREATE VIEW MEGA_DB.BI_02_Ticket_Promedio
AS
SELECT t.anio, t.mes, 
       p.tipo_producto_id, p.descripcion AS tipo_producto,
       r.rango_etario_id, r.descripcion AS rango_etario,
       CAST(SUM(d.subtotal) / COUNT(DISTINCT v.venta_id) AS DECIMAL(38,2)) AS ticket_promedio
FROM MEGA_DB.BI_Venta v
JOIN MEGA_DB.BI_Venta_Detalle d ON d.venta_id = v.venta_id
JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id = v.tiempo_id
JOIN MEGA_DB.BI_Tipo_Producto p ON p.tipo_producto_id = d.tipo_producto_id
JOIN MEGA_DB.BI_Rango_Etario r ON r.rango_etario_id = v.rango_etario_id
GROUP BY t.anio, t.mes, p.tipo_producto_id, p.descripcion, 
         r.rango_etario_id, r.descripcion;
GO

--3. Porcentaje de unidades vendidas por tipo de producto, local y trimestre.
CREATE VIEW MEGA_DB.BI_03_Porcentaje_Ventas_Trimestral
AS
SELECT u.anio, u.trimestre, 
       l.local_id, l.nombre AS local,
       p.tipo_producto_id, p.descripcion AS tipo_producto,
       u.cantidad,
       CAST(
           100.0 * u.cantidad / NULLIF(SUM(u.cantidad) OVER (
               PARTITION BY u.anio, u.trimestre, u.local_id
           ), 0)
           AS DECIMAL(9,4)
       ) AS porcentaje
FROM (
    SELECT t.anio, t.trimestre, v.local_id, d.tipo_producto_id,
           SUM(d.cantidad) AS cantidad
    FROM MEGA_DB.BI_Venta v
    JOIN MEGA_DB.BI_Venta_Detalle d ON d.venta_id = v.venta_id
    JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id = v.tiempo_id
    GROUP BY t.anio, t.trimestre, v.local_id, d.tipo_producto_id
) u
JOIN MEGA_DB.BI_Local l ON l.local_id = u.local_id
JOIN MEGA_DB.BI_Tipo_Producto p ON p.tipo_producto_id = u.tipo_producto_id;
GO

--4. Promedio de horas de alquiler por local y mes.
--Solo se consideran alquileres con devolucion real.
CREATE VIEW MEGA_DB.BI_04_Horas_Alquiler_Mensual
AS
SELECT t.anio, t.mes, l.local_id, l.nombre AS local,
       AVG(a.horas_reales) AS horas_promedio, 
       COUNT(*) AS alquileres_finalizados
FROM MEGA_DB.BI_Alquiler a
JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id = a.tiempo_id
JOIN MEGA_DB.BI_Local l ON l.local_id = a.local_id
WHERE a.horas_reales IS NOT NULL
GROUP BY t.anio, t.mes, l.local_id, l.nombre;
GO

--5. Top 5 categorias de bicicletas mas alquiladas por anio.
CREATE VIEW MEGA_DB.BI_05_Top_Categorias_Alquiler
AS
SELECT r.anio, r.posicion, r.categoria_bicicleta_id,
       r.categoria, r.cantidad_alquileres
FROM (
    SELECT t.anio, c.categoria_bicicleta_id, c.descripcion AS categoria,
           COUNT(*) AS cantidad_alquileres,
           ROW_NUMBER() OVER (
               PARTITION BY t.anio 
               ORDER BY COUNT(*) DESC, c.categoria_bicicleta_id
           ) AS posicion
    FROM MEGA_DB.BI_Alquiler a
    JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id = a.tiempo_id
    JOIN MEGA_DB.BI_Categoria_Bicicleta c 
        ON c.categoria_bicicleta_id = a.categoria_bicicleta_id
    GROUP BY t.anio, c.categoria_bicicleta_id, c.descripcion
) r
WHERE r.posicion <= 5;
GO

--6. Desvio promedio de reparaciones por local y trimestre.
--Solo se consideran reparaciones con fecha real de entrega.
CREATE VIEW MEGA_DB.BI_06_Desvio_Reparaciones
AS
SELECT t.anio, t.trimestre, l.local_id, l.nombre AS local,
       AVG(r.desvio_dias) AS desvio_promedio_dias, 
       COUNT(*) AS reparaciones_entregadas
FROM MEGA_DB.BI_Reparacion r
JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id = r.tiempo_id
JOIN MEGA_DB.BI_Local l ON l.local_id = r.local_id
WHERE r.desvio_dias IS NOT NULL
GROUP BY t.anio, t.trimestre, l.local_id, l.nombre;
GO

--7. Ranking mensual de categorias de repuestos segun unidades utilizadas.
CREATE VIEW MEGA_DB.BI_07_Ranking_Repuestos
AS
SELECT t.anio, t.mes, c.categoria_repuesto_id,
       c.descripcion AS categoria,
       SUM(d.cantidad) AS unidades,
       ROW_NUMBER() OVER (
           PARTITION BY t.anio, t.mes
           ORDER BY SUM(d.cantidad) DESC, c.categoria_repuesto_id
       ) AS posicion
FROM MEGA_DB.BI_Reparacion_Repuesto d
JOIN MEGA_DB.BI_Reparacion r ON r.reparacion_id = d.reparacion_id
JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id = r.tiempo_id
JOIN MEGA_DB.BI_Categoria_Repuesto c 
    ON c.categoria_repuesto_id = d.categoria_repuesto_id
GROUP BY t.anio, t.mes, c.categoria_repuesto_id, c.descripcion;
GO
--8. Porcentaje de facturacion de reparaciones por tipo de ingreso y trimestre.
CREATE VIEW MEGA_DB.BI_08_Porcentaje_Ingresos_Reparacion
AS
SELECT i.anio, i.trimestre, p.tipo_ingreso_id,
       p.descripcion AS tipo_ingreso, i.importe,
       CAST(
           i.importe / NULLIF(SUM(i.importe) OVER (
               PARTITION BY i.anio, i.trimestre
           ), 0) * 100
           AS DECIMAL(9,4)
       ) AS porcentaje
FROM (
    SELECT t.anio, t.trimestre, i.tipo_ingreso_id,
           SUM(i.importe) AS importe
    FROM MEGA_DB.BI_Ingreso_Reparacion i
    JOIN MEGA_DB.BI_Reparacion r ON r.reparacion_id = i.reparacion_id
    JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id = r.tiempo_id
    GROUP BY t.anio, t.trimestre, i.tipo_ingreso_id
) i
JOIN MEGA_DB.BI_Tipo_Ingreso_Reparacion p 
    ON p.tipo_ingreso_id = i.tipo_ingreso_id;
GO

--9. Promedio de unidades compradas por tipo de producto y trimestre.
--Se divide la cantidad de unidades por la cantidad de compras distintas del tipo.
CREATE VIEW MEGA_DB.BI_09_Unidades_Compradas_Promedio
AS
SELECT t.anio, t.trimestre, p.tipo_producto_id,
       p.descripcion AS tipo_producto,
       CAST(
           SUM(d.cantidad) * 1.0 / COUNT(DISTINCT c.compra_id)
           AS DECIMAL(28,4)
       ) AS unidades_promedio
FROM MEGA_DB.BI_Compra c
JOIN MEGA_DB.BI_Compra_Detalle d ON d.compra_id = c.compra_id
JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id = c.tiempo_id
JOIN MEGA_DB.BI_Tipo_Producto p ON p.tipo_producto_id = d.tipo_producto_id
GROUP BY t.anio, t.trimestre, p.tipo_producto_id, p.descripcion;
GO

--10. Importe total de compras mensuales por local.
CREATE VIEW MEGA_DB.BI_10_Importe_Compras_Mensual
AS
SELECT t.anio, t.mes, l.local_id, l.nombre AS local, SUM(c.total) AS importe_total
FROM MEGA_DB.BI_Compra c
JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id = c.tiempo_id
JOIN MEGA_DB.BI_Local l ON l.local_id = c.local_id
GROUP BY t.anio, t.mes, l.local_id, l.nombre;
GO

--11. Facturacion mensual del negocio por local.
--Se suman los importes registrados de ventas, alquileres y reparaciones.
--Al no haber fecha de cobro, se usa el inicio del alquiler y el ingreso al taller.
CREATE VIEW MEGA_DB.BI_11_Facturacion_Negocio_Mensual
AS
SELECT t.anio, t.mes, l.local_id, l.nombre AS local,
       SUM(i.importe) AS facturacion_total
FROM (
    SELECT tiempo_id, local_id, total AS importe
    FROM MEGA_DB.BI_Venta

    UNION ALL

    SELECT tiempo_id, local_id, importe_total
    FROM MEGA_DB.BI_Alquiler

    UNION ALL

    SELECT tiempo_id, local_id, precio_total
    FROM MEGA_DB.BI_Reparacion
) i
JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id = i.tiempo_id
JOIN MEGA_DB.BI_Local l ON l.local_id = i.local_id
GROUP BY t.anio, t.mes, l.local_id, l.nombre;
GO

/* =====================================================================
   4. VISTA DE CONTROL DE LA MIGRACION BI
   Compara cantidades, unidades e importes con el modelo relacional.
   No es un indicador de negocio ni reemplaza la prueba de las 11 vistas.
   ===================================================================== */
CREATE VIEW MEGA_DB.vw_Estado_Migracion_BI
AS
SELECT entidad, control, esperado, actual,
       CASE WHEN esperado = actual THEN 'OK' ELSE 'REVISAR' END AS estado
FROM (
    --Control de cantidad de registros
    SELECT 'Local' AS entidad, 'Filas' AS control,
           (SELECT COUNT(*) FROM MEGA_DB.Local) AS esperado,
           (SELECT COUNT(*) FROM MEGA_DB.BI_Local) AS actual
    UNION ALL
    SELECT 'Tipo_Producto', 'Filas',
           (SELECT COUNT(*) FROM MEGA_DB.Tipo_Producto),
           (SELECT COUNT(*) FROM MEGA_DB.BI_Tipo_Producto)
    UNION ALL
    SELECT 'Categoria_Bicicleta', 'Filas',
           (SELECT COUNT(*) FROM MEGA_DB.Categoria_Bicicleta),
           (SELECT COUNT(*) FROM MEGA_DB.BI_Categoria_Bicicleta)
    UNION ALL
    SELECT 'Categoria_Repuesto', 'Filas',
           (SELECT COUNT(*) FROM MEGA_DB.Categoria_Repuesto),
           (SELECT COUNT(*) FROM MEGA_DB.BI_Categoria_Repuesto)
    UNION ALL
    SELECT 'Venta', 'Filas',
           (SELECT COUNT(*) FROM MEGA_DB.Venta),
           (SELECT COUNT(*) FROM MEGA_DB.BI_Venta)
    UNION ALL
    SELECT 'Venta_Detalle', 'Filas',
           (SELECT COUNT(*) FROM MEGA_DB.Venta_Detalle),
           (SELECT COUNT(*) FROM MEGA_DB.BI_Venta_Detalle)
    UNION ALL
    SELECT 'Alquiler', 'Filas',
           (SELECT COUNT(*) FROM MEGA_DB.Alquiler),
           (SELECT COUNT(*) FROM MEGA_DB.BI_Alquiler)
    UNION ALL
    SELECT 'Reparacion', 'Filas',
           (SELECT COUNT(*) FROM MEGA_DB.Reparacion),
           (SELECT COUNT(*) FROM MEGA_DB.BI_Reparacion)
    UNION ALL
    SELECT 'Reparacion_Repuesto', 'Filas',
           (SELECT COUNT(*) FROM MEGA_DB.Reparacion_Repuesto),
           (SELECT COUNT(*) FROM MEGA_DB.BI_Reparacion_Repuesto)
    UNION ALL
    SELECT 'Compra', 'Filas',
           (SELECT COUNT(*) FROM MEGA_DB.Compra),
           (SELECT COUNT(*) FROM MEGA_DB.BI_Compra)
    UNION ALL
    SELECT 'Compra_Detalle', 'Filas',
           (SELECT COUNT(*) FROM MEGA_DB.Compra_Detalle),
           (SELECT COUNT(*) FROM MEGA_DB.BI_Compra_Detalle)
    UNION ALL

    --Control de cantidad de periodos distintos
    SELECT 'Tiempo', 'Filas',
           (SELECT COUNT(*) FROM (
                SELECT YEAR(fecha_venta) AS anio, MONTH(fecha_venta) AS mes
                FROM MEGA_DB.Venta
                UNION
                SELECT YEAR(fecha_inicio), MONTH(fecha_inicio)
                FROM MEGA_DB.Alquiler
                UNION
                SELECT YEAR(fecha_ingreso), MONTH(fecha_ingreso)
                FROM MEGA_DB.Reparacion
                UNION
                SELECT YEAR(fecha_compra), MONTH(fecha_compra)
                FROM MEGA_DB.Compra
            ) periodos),
           (SELECT COUNT(*) FROM MEGA_DB.BI_Tiempo)
    UNION ALL

    --Control de dimensiones con valores predefinidos
    SELECT 'Rango_Etario', 'Filas', 5,
           (SELECT COUNT(*) FROM MEGA_DB.BI_Rango_Etario)
    UNION ALL
    SELECT 'Tipo_Ingreso_Reparacion', 'Filas', 2,
           (SELECT COUNT(*) FROM MEGA_DB.BI_Tipo_Ingreso_Reparacion)
    UNION ALL

    --Cada reparacion tiene dos tipos de ingreso
    SELECT 'Ingreso_Reparacion', 'Filas',
           (SELECT COUNT(*) * 2 FROM MEGA_DB.Reparacion),
           (SELECT COUNT(*) FROM MEGA_DB.BI_Ingreso_Reparacion)
    UNION ALL

    --Control de importes
    SELECT 'Venta', 'Importe',
           (SELECT ISNULL(SUM(total), 0) FROM MEGA_DB.Venta),
           (SELECT ISNULL(SUM(total), 0) FROM MEGA_DB.BI_Venta)
    UNION ALL
    SELECT 'Venta_Detalle', 'Importe',
           (SELECT ISNULL(SUM(subtotal), 0) FROM MEGA_DB.Venta_Detalle),
           (SELECT ISNULL(SUM(subtotal), 0) FROM MEGA_DB.BI_Venta_Detalle)
    UNION ALL
    SELECT 'Alquiler', 'Importe',
           (SELECT ISNULL(SUM(importe_total), 0) FROM MEGA_DB.Alquiler),
           (SELECT ISNULL(SUM(importe_total), 0) FROM MEGA_DB.BI_Alquiler)
    UNION ALL
    SELECT 'Reparacion', 'Importe',
           (SELECT ISNULL(SUM(precio_total), 0) FROM MEGA_DB.Reparacion),
           (SELECT ISNULL(SUM(precio_total), 0) FROM MEGA_DB.BI_Reparacion)
    UNION ALL
    SELECT 'Compra', 'Importe',
           (SELECT ISNULL(SUM(total), 0) FROM MEGA_DB.Compra),
           (SELECT ISNULL(SUM(total), 0) FROM MEGA_DB.BI_Compra)
    UNION ALL
    SELECT 'Ingreso_Reparacion', 'Mano de obra',
           (SELECT ISNULL(SUM(precio_mano_obra), 0) FROM MEGA_DB.Reparacion),
           (SELECT ISNULL(SUM(importe), 0) FROM MEGA_DB.BI_Ingreso_Reparacion
            WHERE tipo_ingreso_id = 1)
    UNION ALL
    SELECT 'Ingreso_Reparacion', 'Repuestos',
           (SELECT ISNULL(SUM(precio_repuestos), 0) FROM MEGA_DB.Reparacion),
           (SELECT ISNULL(SUM(importe), 0) FROM MEGA_DB.BI_Ingreso_Reparacion
            WHERE tipo_ingreso_id = 2)
    UNION ALL

    --Control de cantidades de productos y repuestos
    SELECT 'Venta_Detalle', 'Unidades',
           (SELECT ISNULL(SUM(cantidad), 0) FROM MEGA_DB.Venta_Detalle),
           (SELECT ISNULL(SUM(cantidad), 0) FROM MEGA_DB.BI_Venta_Detalle)
    UNION ALL
    SELECT 'Compra_Detalle', 'Unidades',
           (SELECT ISNULL(SUM(cantidad), 0) FROM MEGA_DB.Compra_Detalle),
           (SELECT ISNULL(SUM(cantidad), 0) FROM MEGA_DB.BI_Compra_Detalle)
    UNION ALL
    SELECT 'Reparacion_Repuesto', 'Unidades',
           (SELECT ISNULL(SUM(cantidad), 0) FROM MEGA_DB.Reparacion_Repuesto),
           (SELECT ISNULL(SUM(cantidad), 0) FROM MEGA_DB.BI_Reparacion_Repuesto)
) v;
GO

--Se muestra el resultado del control al ejecutar el script.
SELECT * FROM MEGA_DB.vw_Estado_Migracion_BI;
GO

/* =====================================================================
   5. INDICES
   Se crean luego de la carga inicial, igual qu el script de migracion.
   ===================================================================== */

--Venta: acceso por tiempo_id, local_id y medidas del indicador.
CREATE NONCLUSTERED INDEX IX_BI_Venta_Periodo_Local
ON MEGA_DB.BI_Venta (tiempo_id, local_id)
INCLUDE (total, rango_etario_id);
GO

--Alquiler: acceso por tiempo_id, local_id y medidas del indicador.
CREATE NONCLUSTERED INDEX IX_BI_Alquiler_Periodo_Local
ON MEGA_DB.BI_Alquiler (tiempo_id, local_id)
INCLUDE (horas_reales, importe_total, categoria_bicicleta_id);
GO

--Reparacion: acceso por tiempo_id, local_id y medidas del indicador.
CREATE NONCLUSTERED INDEX IX_BI_Reparacion_Periodo_Local
ON MEGA_DB.BI_Reparacion (tiempo_id, local_id)
INCLUDE (desvio_dias, precio_total);
GO

--Compra: acceso por tiempo_id, local_id y medidas del indicador.
CREATE NONCLUSTERED INDEX IX_BI_Compra_Periodo_Local
ON MEGA_DB.BI_Compra (tiempo_id, local_id)
INCLUDE (total);
GO

--Venta_Detalle: acceso por venta_id y medidas del indicador.
CREATE NONCLUSTERED INDEX IX_BI_Venta_Detalle_Cabecera
ON MEGA_DB.BI_Venta_Detalle (venta_id)
INCLUDE (tipo_producto_id, cantidad, subtotal);
GO

--Compra_Detalle: acceso por compra_id y medidas del indicador.
CREATE NONCLUSTERED INDEX IX_BI_Compra_Detalle_Cabecera
ON MEGA_DB.BI_Compra_Detalle (compra_id)
INCLUDE (tipo_producto_id, cantidad);
GO

--Reparacion_Repuesto: acceso por reparacion_id y medidas del indicador.
CREATE NONCLUSTERED INDEX IX_BI_Reparacion_Repuesto_Cabecera
ON MEGA_DB.BI_Reparacion_Repuesto (reparacion_id)
INCLUDE (categoria_repuesto_id, cantidad);
GO

PRINT 'Modelo BI creado y cargado. Revisar el resultado de la vista de control.';
GO
