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
   1. CREACION DE DIMENSIONES
   Se conservan los IDs del transaccional. Las dimensiones de dominio
   propias de BI se cargan con IDs fijos.
   ===================================================================== */

--Meses en los que hubo alguna operacion. PK = anio * 100 + mes
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

--Tipos de producto (bicicleta / accesorio)
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

/* =====================================================================
   2. CREACION DE HECHOS
   Cada hecho guarda medidas agregadas por la combinacion de sus
   dimensiones (la PK es esa combinacion). Se guardan sumas y conteos,
   no promedios, para que las vistas calculen los promedios sin
   promediar promedios.
   ===================================================================== */

--Ventas por mes, local, rango etario del cliente y tipo de producto.
--cantidad_ventas: ventas distintas que incluyen ese tipo de producto.
CREATE TABLE MEGA_DB.[BI_Hecho_Venta] (
    [tiempo_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Tiempo]([tiempo_id]),
    [local_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Local]([local_id]),
    [rango_etario_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Rango_Etario]([rango_etario_id]),
    [tipo_producto_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Tipo_Producto]([tipo_producto_id]),
    [cantidad_ventas] INT NOT NULL,
    [unidades] INT NOT NULL,
    [importe] NUMERIC(38,2) NOT NULL,
    PRIMARY KEY ([tiempo_id], [local_id], [rango_etario_id], [tipo_producto_id])
);
GO

--Alquileres por mes de inicio, local de la bicicleta y categoria de bicicleta.
--horas_totales suma solo la duracion de los alquileres con devolucion real.
CREATE TABLE MEGA_DB.[BI_Hecho_Alquiler] (
    [tiempo_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Tiempo]([tiempo_id]),
    [local_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Local]([local_id]),
    [categoria_bicicleta_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Categoria_Bicicleta]([categoria_bicicleta_id]),
    [cantidad_alquileres] INT NOT NULL,
    [cantidad_finalizados] INT NOT NULL,
    [horas_totales] DECIMAL(38,6) NOT NULL,
    [importe] NUMERIC(38,2) NOT NULL,
    PRIMARY KEY ([tiempo_id], [local_id], [categoria_bicicleta_id])
);
GO

--Reparaciones por mes de ingreso y local.
--desvio_total_dias suma (entrega real - estimada) solo de las reparaciones entregadas.
CREATE TABLE MEGA_DB.[BI_Hecho_Reparacion] (
    [tiempo_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Tiempo]([tiempo_id]),
    [local_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Local]([local_id]),
    [cantidad_reparaciones] INT NOT NULL,
    [cantidad_entregadas] INT NOT NULL,
    [desvio_total_dias] DECIMAL(38,6) NOT NULL,
    [importe] NUMERIC(38,2) NOT NULL,
    PRIMARY KEY ([tiempo_id], [local_id])
);
GO

--Facturacion de reparaciones por mes de ingreso, local y tipo de ingreso
CREATE TABLE MEGA_DB.[BI_Hecho_Ingreso_Reparacion] (
    [tiempo_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Tiempo]([tiempo_id]),
    [local_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Local]([local_id]),
    [tipo_ingreso_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Tipo_Ingreso_Reparacion]([tipo_ingreso_id]),
    [importe] NUMERIC(38,2) NOT NULL,
    PRIMARY KEY ([tiempo_id], [local_id], [tipo_ingreso_id])
);
GO

--Repuestos utilizados por mes de ingreso de la reparacion, local y categoria de repuesto
CREATE TABLE MEGA_DB.[BI_Hecho_Repuesto] (
    [tiempo_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Tiempo]([tiempo_id]),
    [local_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Local]([local_id]),
    [categoria_repuesto_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Categoria_Repuesto]([categoria_repuesto_id]),
    [unidades] INT NOT NULL,
    PRIMARY KEY ([tiempo_id], [local_id], [categoria_repuesto_id])
);
GO

--Compras por mes y local, con el total original de cada compra.
--El total no se puede repartir por tipo de producto (ver Inconsistencias - Totales de compra).
CREATE TABLE MEGA_DB.[BI_Hecho_Compra] (
    [tiempo_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Tiempo]([tiempo_id]),
    [local_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Local]([local_id]),
    [cantidad_compras] INT NOT NULL,
    [importe] NUMERIC(38,2) NOT NULL,
    PRIMARY KEY ([tiempo_id], [local_id])
);
GO

--Unidades compradas por mes, local y tipo de producto.
--cantidad_compras: compras distintas que incluyen ese tipo de producto.
CREATE TABLE MEGA_DB.[BI_Hecho_Compra_Producto] (
    [tiempo_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Tiempo]([tiempo_id]),
    [local_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Local]([local_id]),
    [tipo_producto_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[BI_Tipo_Producto]([tipo_producto_id]),
    [cantidad_compras] INT NOT NULL,
    [unidades] INT NOT NULL,
    PRIMARY KEY ([tiempo_id], [local_id], [tipo_producto_id])
);
GO

/* =====================================================================
   3. MIGRACION AL MODELO BI
   Se realiza una carga completa desde las tablas del modelo relacional.
   ===================================================================== */

CREATE PROCEDURE MEGA_DB.BI_Cargar_Modelo
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        --Si se vuelve a ejecutar el SP, primero se eliminan los datos anteriores (hechos y luego dimensiones).
        DELETE FROM MEGA_DB.BI_Hecho_Compra_Producto;
        DELETE FROM MEGA_DB.BI_Hecho_Compra;
        DELETE FROM MEGA_DB.BI_Hecho_Repuesto;
        DELETE FROM MEGA_DB.BI_Hecho_Ingreso_Reparacion;
        DELETE FROM MEGA_DB.BI_Hecho_Reparacion;
        DELETE FROM MEGA_DB.BI_Hecho_Alquiler;
        DELETE FROM MEGA_DB.BI_Hecho_Venta;
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

        --Tipos de producto del modelo relacional.
        INSERT INTO MEGA_DB.BI_Tipo_Producto (tipo_producto_id, descripcion)
        SELECT tipo_producto_id, descripcion FROM MEGA_DB.Tipo_Producto;

        --Categorias de bicicleta del modelo relacional.
        INSERT INTO MEGA_DB.BI_Categoria_Bicicleta (categoria_bicicleta_id, descripcion)
        SELECT categoria_bicicleta_id, descripcion FROM MEGA_DB.Categoria_Bicicleta;

        --Categorias de repuesto del modelo relacional.
        INSERT INTO MEGA_DB.BI_Categoria_Repuesto (categoria_repuesto_id, descripcion)
        SELECT categoria_repuesto_id, descripcion FROM MEGA_DB.Categoria_Repuesto;

        --Tipos de ingreso establecidos segun el enunciado.
        INSERT INTO MEGA_DB.BI_Tipo_Ingreso_Reparacion (tipo_ingreso_id, descripcion)
        VALUES (1, 'Mano de Obra'), (2, 'Repuestos');

        --Ventas: se calcula la edad del cliente al momento de la venta, se asigna su rango
        --etario y se agregan los renglones por mes, local, rango y tipo de producto.
        --Se usan los subtotales originales (su suma coincide con el total de cada venta).
        WITH ventas AS (
            SELECT venta_id,
                   YEAR(fecha_venta) * 100 + MONTH(fecha_venta) AS tiempo_id,
                   local_id,
                   CASE
                       WHEN edad < 0 THEN 0
                       WHEN edad <= 25 THEN 1
                       WHEN edad <= 35 THEN 2
                       WHEN edad <= 50 THEN 3
                       ELSE 4
                   END AS rango_etario_id
            FROM (
                SELECT v.venta_id, v.fecha_venta, v.local_id,
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
            ) edades
        )
        INSERT INTO MEGA_DB.BI_Hecho_Venta
            (tiempo_id, local_id, rango_etario_id, tipo_producto_id, cantidad_ventas, unidades, importe)
        SELECT v.tiempo_id, v.local_id, v.rango_etario_id, p.tipo_producto_id,
               COUNT(DISTINCT v.venta_id), SUM(d.cantidad), SUM(d.subtotal)
        FROM ventas v
        JOIN MEGA_DB.Venta_Detalle d ON d.venta_id = v.venta_id
        JOIN MEGA_DB.Producto p ON p.producto_id = d.producto_id
        GROUP BY v.tiempo_id, v.local_id, v.rango_etario_id, p.tipo_producto_id;

        --Alquileres: se utiliza el local de la bicicleta, no el del empleado.
        --La duracion se calcula en segundos y se pasa a horas; solo suman los alquileres con devolucion real.
        INSERT INTO MEGA_DB.BI_Hecho_Alquiler
            (tiempo_id, local_id, categoria_bicicleta_id, cantidad_alquileres, cantidad_finalizados, horas_totales, importe)
        SELECT YEAR(a.fecha_inicio) * 100 + MONTH(a.fecha_inicio),
               b.local_id,
               m.categoria_bicicleta_id,
               COUNT(*),
               SUM(CASE WHEN a.fecha_devolucion_real IS NULL THEN 0 ELSE 1 END),
               CAST(SUM(CASE WHEN a.fecha_devolucion_real IS NULL THEN 0
                             ELSE DATEDIFF_BIG(SECOND, a.fecha_inicio, a.fecha_devolucion_real)
                        END) / 3600.0 AS DECIMAL(38,6)),
               SUM(a.importe_total)
        FROM MEGA_DB.Alquiler a
        JOIN MEGA_DB.Bicicleta_Alquiler b ON b.bicicleta_alquiler_id = a.bicicleta_alquiler_id
        JOIN MEGA_DB.Modelo_Bicicleta m ON m.modelo_bicicleta_id = b.modelo_bicicleta_id
        GROUP BY YEAR(a.fecha_inicio) * 100 + MONTH(a.fecha_inicio), b.local_id, m.categoria_bicicleta_id;

        --Reparaciones: desvio en dias entre la entrega estimada y la real (positivo si se entrego tarde,
        --negativo si se entrego antes). Solo suman las reparaciones con fecha real de entrega.
        INSERT INTO MEGA_DB.BI_Hecho_Reparacion
            (tiempo_id, local_id, cantidad_reparaciones, cantidad_entregadas, desvio_total_dias, importe)
        SELECT YEAR(fecha_ingreso) * 100 + MONTH(fecha_ingreso),
               local_id,
               COUNT(*),
               SUM(CASE WHEN fecha_entrega_real IS NULL THEN 0 ELSE 1 END),
               CAST(SUM(CASE WHEN fecha_entrega_real IS NULL THEN 0
                             ELSE DATEDIFF_BIG(SECOND, fecha_entrega_estimada, fecha_entrega_real)
                        END) / 86400.0 AS DECIMAL(38,6)),
               SUM(precio_total)
        FROM MEGA_DB.Reparacion
        GROUP BY YEAR(fecha_ingreso) * 100 + MONTH(fecha_ingreso), local_id;

        --Ingresos de reparaciones: una fila por mes, local y tipo de ingreso (1 mano de obra, 2 repuestos).
        INSERT INTO MEGA_DB.BI_Hecho_Ingreso_Reparacion (tiempo_id, local_id, tipo_ingreso_id, importe)
        SELECT YEAR(r.fecha_ingreso) * 100 + MONTH(r.fecha_ingreso), r.local_id, i.tipo_ingreso_id,
               SUM(CASE i.tipo_ingreso_id WHEN 1 THEN r.precio_mano_obra ELSE r.precio_repuestos END)
        FROM MEGA_DB.Reparacion r
        CROSS JOIN (VALUES (1), (2)) i (tipo_ingreso_id)
        GROUP BY YEAR(r.fecha_ingreso) * 100 + MONTH(r.fecha_ingreso), r.local_id, i.tipo_ingreso_id;

        --Repuestos utilizados: unidades por mes de ingreso de la reparacion, local y categoria.
        INSERT INTO MEGA_DB.BI_Hecho_Repuesto (tiempo_id, local_id, categoria_repuesto_id, unidades)
        SELECT YEAR(r.fecha_ingreso) * 100 + MONTH(r.fecha_ingreso), r.local_id,
               rep.categoria_repuesto_id, SUM(d.cantidad)
        FROM MEGA_DB.Reparacion_Repuesto d
        JOIN MEGA_DB.Reparacion r ON r.reparacion_id = d.reparacion_id
        JOIN MEGA_DB.Repuesto rep ON rep.repuesto_id = d.repuesto_id
        GROUP BY YEAR(r.fecha_ingreso) * 100 + MONTH(r.fecha_ingreso), r.local_id, rep.categoria_repuesto_id;

        --Compras: se suma el total original de cada compra, sin recalcularlo desde los detalles.
        INSERT INTO MEGA_DB.BI_Hecho_Compra (tiempo_id, local_id, cantidad_compras, importe)
        SELECT YEAR(fecha_compra) * 100 + MONTH(fecha_compra), local_id, COUNT(*), SUM(total)
        FROM MEGA_DB.Compra
        GROUP BY YEAR(fecha_compra) * 100 + MONTH(fecha_compra), local_id;

        --Unidades compradas por mes, local y tipo de producto.
        INSERT INTO MEGA_DB.BI_Hecho_Compra_Producto
            (tiempo_id, local_id, tipo_producto_id, cantidad_compras, unidades)
        SELECT YEAR(c.fecha_compra) * 100 + MONTH(c.fecha_compra), c.local_id, p.tipo_producto_id,
               COUNT(DISTINCT c.compra_id), SUM(d.cantidad)
        FROM MEGA_DB.Compra c
        JOIN MEGA_DB.Compra_Detalle d ON d.compra_id = c.compra_id
        JOIN MEGA_DB.Producto p ON p.producto_id = d.producto_id
        GROUP BY YEAR(c.fecha_compra) * 100 + MONTH(c.fecha_compra), c.local_id, p.tipo_producto_id;

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

--Se ejecuta la primera carga del modelo.
EXEC MEGA_DB.BI_Cargar_Modelo;
GO

/* =====================================================================
   4. VISTAS DE INDICADORES
   Las vistas consultan solo el modelo BI.
   ===================================================================== */

--1. Facturacion total mensual de ventas por local.
CREATE VIEW MEGA_DB.BI_01_Facturacion_Ventas_Mensual
AS
SELECT t.anio, t.mes, l.local_id, l.nombre AS local,
       SUM(h.importe) AS facturacion
FROM MEGA_DB.BI_Hecho_Venta h
JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id = h.tiempo_id
JOIN MEGA_DB.BI_Local l ON l.local_id = h.local_id
GROUP BY t.anio, t.mes, l.local_id, l.nombre;
GO

--2. Ticket promedio mensual por tipo de producto y rango etario.
--Importe vendido del tipo dividido por la cantidad de ventas que incluyen ese tipo.
CREATE VIEW MEGA_DB.BI_02_Ticket_Promedio
AS
SELECT t.anio, t.mes,
       p.tipo_producto_id, p.descripcion AS tipo_producto,
       r.rango_etario_id, r.descripcion AS rango_etario,
       CAST(SUM(h.importe) / SUM(h.cantidad_ventas) AS DECIMAL(38,2)) AS ticket_promedio
FROM MEGA_DB.BI_Hecho_Venta h
JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id = h.tiempo_id
JOIN MEGA_DB.BI_Tipo_Producto p ON p.tipo_producto_id = h.tipo_producto_id
JOIN MEGA_DB.BI_Rango_Etario r ON r.rango_etario_id = h.rango_etario_id
GROUP BY t.anio, t.mes, p.tipo_producto_id, p.descripcion,
         r.rango_etario_id, r.descripcion;
GO

--3. Porcentaje de ventas trimestrales por tipo de producto y local,
--calculado sobre las unidades vendidas y sobre el importe facturado.
CREATE VIEW MEGA_DB.BI_03_Porcentaje_Ventas_Trimestral
AS
SELECT u.anio, u.trimestre,
       l.local_id, l.nombre AS local,
       p.tipo_producto_id, p.descripcion AS tipo_producto,
       u.unidades,
       CAST(
           100.0 * u.unidades / NULLIF(SUM(u.unidades) OVER (
               PARTITION BY u.anio, u.trimestre, u.local_id
           ), 0)
           AS DECIMAL(9,4)
       ) AS porcentaje_unidades,
       u.importe,
       CAST(
           100.0 * u.importe / NULLIF(SUM(u.importe) OVER (
               PARTITION BY u.anio, u.trimestre, u.local_id
           ), 0)
           AS DECIMAL(9,4)
       ) AS porcentaje_importe
FROM (
    SELECT t.anio, t.trimestre, h.local_id, h.tipo_producto_id,
           SUM(h.unidades) AS unidades,
           SUM(h.importe) AS importe
    FROM MEGA_DB.BI_Hecho_Venta h
    JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id = h.tiempo_id
    GROUP BY t.anio, t.trimestre, h.local_id, h.tipo_producto_id
) u
JOIN MEGA_DB.BI_Local l ON l.local_id = u.local_id
JOIN MEGA_DB.BI_Tipo_Producto p ON p.tipo_producto_id = u.tipo_producto_id;
GO

--4. Promedio de horas de alquiler por local y mes.
--Solo se consideran alquileres con devolucion real.
CREATE VIEW MEGA_DB.BI_04_Horas_Alquiler_Mensual
AS
SELECT t.anio, t.mes, l.local_id, l.nombre AS local,
       CAST(SUM(h.horas_totales) / SUM(h.cantidad_finalizados) AS DECIMAL(38,6)) AS horas_promedio,
       SUM(h.cantidad_finalizados) AS alquileres_finalizados
FROM MEGA_DB.BI_Hecho_Alquiler h
JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id = h.tiempo_id
JOIN MEGA_DB.BI_Local l ON l.local_id = h.local_id
GROUP BY t.anio, t.mes, l.local_id, l.nombre
HAVING SUM(h.cantidad_finalizados) > 0;
GO

--5. Top 5 categorias de bicicletas mas alquiladas por anio.
CREATE VIEW MEGA_DB.BI_05_Top_Categorias_Alquiler
AS
SELECT r.anio, r.posicion, r.categoria_bicicleta_id,
       r.categoria, r.cantidad_alquileres
FROM (
    SELECT t.anio, c.categoria_bicicleta_id, c.descripcion AS categoria,
           SUM(h.cantidad_alquileres) AS cantidad_alquileres,
           ROW_NUMBER() OVER (
               PARTITION BY t.anio
               ORDER BY SUM(h.cantidad_alquileres) DESC, c.categoria_bicicleta_id
           ) AS posicion
    FROM MEGA_DB.BI_Hecho_Alquiler h
    JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id = h.tiempo_id
    JOIN MEGA_DB.BI_Categoria_Bicicleta c
        ON c.categoria_bicicleta_id = h.categoria_bicicleta_id
    GROUP BY t.anio, c.categoria_bicicleta_id, c.descripcion
) r
WHERE r.posicion <= 5;
GO

--6. Desvio promedio de reparaciones (en dias) por local y trimestre.
--Solo se consideran reparaciones con fecha real de entrega.
CREATE VIEW MEGA_DB.BI_06_Desvio_Reparaciones
AS
SELECT t.anio, t.trimestre, l.local_id, l.nombre AS local,
       CAST(SUM(h.desvio_total_dias) / SUM(h.cantidad_entregadas) AS DECIMAL(38,6)) AS desvio_promedio_dias,
       SUM(h.cantidad_entregadas) AS reparaciones_entregadas
FROM MEGA_DB.BI_Hecho_Reparacion h
JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id = h.tiempo_id
JOIN MEGA_DB.BI_Local l ON l.local_id = h.local_id
GROUP BY t.anio, t.trimestre, l.local_id, l.nombre
HAVING SUM(h.cantidad_entregadas) > 0;
GO

--7. Ranking mensual de categorias de repuestos segun unidades utilizadas.
CREATE VIEW MEGA_DB.BI_07_Ranking_Repuestos
AS
SELECT t.anio, t.mes, c.categoria_repuesto_id,
       c.descripcion AS categoria,
       SUM(h.unidades) AS unidades,
       ROW_NUMBER() OVER (
           PARTITION BY t.anio, t.mes
           ORDER BY SUM(h.unidades) DESC, c.categoria_repuesto_id
       ) AS posicion
FROM MEGA_DB.BI_Hecho_Repuesto h
JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id = h.tiempo_id
JOIN MEGA_DB.BI_Categoria_Repuesto c
    ON c.categoria_repuesto_id = h.categoria_repuesto_id
GROUP BY t.anio, t.mes, c.categoria_repuesto_id, c.descripcion;
GO

--8. Porcentaje de facturacion de reparaciones por tipo de ingreso y trimestre.
CREATE VIEW MEGA_DB.BI_08_Porcentaje_Ingresos_Reparacion
AS
SELECT i.anio, i.trimestre, p.tipo_ingreso_id,
       p.descripcion AS tipo_ingreso, i.importe,
       CAST(
           100.0 * i.importe / NULLIF(SUM(i.importe) OVER (
               PARTITION BY i.anio, i.trimestre
           ), 0)
           AS DECIMAL(9,4)
       ) AS porcentaje
FROM (
    SELECT t.anio, t.trimestre, h.tipo_ingreso_id,
           SUM(h.importe) AS importe
    FROM MEGA_DB.BI_Hecho_Ingreso_Reparacion h
    JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id = h.tiempo_id
    GROUP BY t.anio, t.trimestre, h.tipo_ingreso_id
) i
JOIN MEGA_DB.BI_Tipo_Ingreso_Reparacion p
    ON p.tipo_ingreso_id = i.tipo_ingreso_id;
GO

--9. Promedio de unidades compradas por tipo de producto y trimestre.
--Unidades compradas del tipo divididas por la cantidad de compras que incluyen ese tipo.
CREATE VIEW MEGA_DB.BI_09_Unidades_Compradas_Promedio
AS
SELECT t.anio, t.trimestre, p.tipo_producto_id,
       p.descripcion AS tipo_producto,
       CAST(
           SUM(h.unidades) * 1.0 / SUM(h.cantidad_compras)
           AS DECIMAL(28,4)
       ) AS unidades_promedio
FROM MEGA_DB.BI_Hecho_Compra_Producto h
JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id = h.tiempo_id
JOIN MEGA_DB.BI_Tipo_Producto p ON p.tipo_producto_id = h.tipo_producto_id
GROUP BY t.anio, t.trimestre, p.tipo_producto_id, p.descripcion;
GO

--10. Importe total de compras mensuales por local.
CREATE VIEW MEGA_DB.BI_10_Importe_Compras_Mensual
AS
SELECT t.anio, t.mes, l.local_id, l.nombre AS local, SUM(h.importe) AS importe_total
FROM MEGA_DB.BI_Hecho_Compra h
JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id = h.tiempo_id
JOIN MEGA_DB.BI_Local l ON l.local_id = h.local_id
GROUP BY t.anio, t.mes, l.local_id, l.nombre;
GO

--11. Facturacion mensual del negocio por local.
--Se suman los importes de ventas, alquileres y reparaciones.
--Al no haber fecha de cobro, se usa el inicio del alquiler y el ingreso al taller.
CREATE VIEW MEGA_DB.BI_11_Facturacion_Negocio_Mensual
AS
SELECT t.anio, t.mes, l.local_id, l.nombre AS local,
       SUM(i.importe) AS facturacion_total
FROM (
    SELECT tiempo_id, local_id, importe
    FROM MEGA_DB.BI_Hecho_Venta

    UNION ALL

    SELECT tiempo_id, local_id, importe
    FROM MEGA_DB.BI_Hecho_Alquiler

    UNION ALL

    SELECT tiempo_id, local_id, importe
    FROM MEGA_DB.BI_Hecho_Reparacion
) i
JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id = i.tiempo_id
JOIN MEGA_DB.BI_Local l ON l.local_id = i.local_id
GROUP BY t.anio, t.mes, l.local_id, l.nombre;
GO

/* =====================================================================
   5. VISTA DE CONTROL DE LA MIGRACION BI
   Compara cantidades, unidades e importes con el modelo relacional.
   No es un indicador de negocio ni reemplaza la prueba de las 11 vistas.
   ===================================================================== */
CREATE VIEW MEGA_DB.BI_vw_Estado_Migracion
AS
SELECT entidad, control, esperado, actual,
       CASE WHEN esperado = actual THEN 'OK' ELSE 'REVISAR' END AS estado
FROM (
    --Dimensiones: cantidad de filas
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
    SELECT 'Rango_Etario', 'Filas', 5,
           (SELECT COUNT(*) FROM MEGA_DB.BI_Rango_Etario)
    UNION ALL
    SELECT 'Tipo_Ingreso_Reparacion', 'Filas', 2,
           (SELECT COUNT(*) FROM MEGA_DB.BI_Tipo_Ingreso_Reparacion)
    UNION ALL
    --Tiempo: cantidad de meses distintos con alguna operacion
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

    --Hecho_Venta: pares venta/tipo de producto, unidades e importes
    SELECT 'Hecho_Venta', 'Ventas por tipo',
           (SELECT COUNT(*) FROM (
                SELECT DISTINCT d.venta_id, p.tipo_producto_id
                FROM MEGA_DB.Venta_Detalle d
                JOIN MEGA_DB.Producto p ON p.producto_id = d.producto_id
            ) vt),
           (SELECT ISNULL(SUM(cantidad_ventas), 0) FROM MEGA_DB.BI_Hecho_Venta)
    UNION ALL
    SELECT 'Hecho_Venta', 'Unidades',
           (SELECT ISNULL(SUM(cantidad), 0) FROM MEGA_DB.Venta_Detalle),
           (SELECT ISNULL(SUM(unidades), 0) FROM MEGA_DB.BI_Hecho_Venta)
    UNION ALL
    SELECT 'Hecho_Venta', 'Importe (subtotales)',
           (SELECT ISNULL(SUM(subtotal), 0) FROM MEGA_DB.Venta_Detalle),
           (SELECT ISNULL(SUM(importe), 0) FROM MEGA_DB.BI_Hecho_Venta)
    UNION ALL
    SELECT 'Hecho_Venta', 'Importe (totales de venta)',
           (SELECT ISNULL(SUM(total), 0) FROM MEGA_DB.Venta),
           (SELECT ISNULL(SUM(importe), 0) FROM MEGA_DB.BI_Hecho_Venta)
    UNION ALL

    --Hecho_Alquiler
    SELECT 'Hecho_Alquiler', 'Alquileres',
           (SELECT COUNT(*) FROM MEGA_DB.Alquiler),
           (SELECT ISNULL(SUM(cantidad_alquileres), 0) FROM MEGA_DB.BI_Hecho_Alquiler)
    UNION ALL
    SELECT 'Hecho_Alquiler', 'Finalizados',
           (SELECT COUNT(*) FROM MEGA_DB.Alquiler WHERE fecha_devolucion_real IS NOT NULL),
           (SELECT ISNULL(SUM(cantidad_finalizados), 0) FROM MEGA_DB.BI_Hecho_Alquiler)
    UNION ALL
    SELECT 'Hecho_Alquiler', 'Importe',
           (SELECT ISNULL(SUM(importe_total), 0) FROM MEGA_DB.Alquiler),
           (SELECT ISNULL(SUM(importe), 0) FROM MEGA_DB.BI_Hecho_Alquiler)
    UNION ALL

    --Hechos de reparaciones
    SELECT 'Hecho_Reparacion', 'Reparaciones',
           (SELECT COUNT(*) FROM MEGA_DB.Reparacion),
           (SELECT ISNULL(SUM(cantidad_reparaciones), 0) FROM MEGA_DB.BI_Hecho_Reparacion)
    UNION ALL
    SELECT 'Hecho_Reparacion', 'Entregadas',
           (SELECT COUNT(*) FROM MEGA_DB.Reparacion WHERE fecha_entrega_real IS NOT NULL),
           (SELECT ISNULL(SUM(cantidad_entregadas), 0) FROM MEGA_DB.BI_Hecho_Reparacion)
    UNION ALL
    SELECT 'Hecho_Reparacion', 'Importe',
           (SELECT ISNULL(SUM(precio_total), 0) FROM MEGA_DB.Reparacion),
           (SELECT ISNULL(SUM(importe), 0) FROM MEGA_DB.BI_Hecho_Reparacion)
    UNION ALL
    SELECT 'Hecho_Ingreso_Reparacion', 'Mano de obra',
           (SELECT ISNULL(SUM(precio_mano_obra), 0) FROM MEGA_DB.Reparacion),
           (SELECT ISNULL(SUM(importe), 0) FROM MEGA_DB.BI_Hecho_Ingreso_Reparacion
            WHERE tipo_ingreso_id = 1)
    UNION ALL
    SELECT 'Hecho_Ingreso_Reparacion', 'Repuestos',
           (SELECT ISNULL(SUM(precio_repuestos), 0) FROM MEGA_DB.Reparacion),
           (SELECT ISNULL(SUM(importe), 0) FROM MEGA_DB.BI_Hecho_Ingreso_Reparacion
            WHERE tipo_ingreso_id = 2)
    UNION ALL
    SELECT 'Hecho_Repuesto', 'Unidades',
           (SELECT ISNULL(SUM(cantidad), 0) FROM MEGA_DB.Reparacion_Repuesto),
           (SELECT ISNULL(SUM(unidades), 0) FROM MEGA_DB.BI_Hecho_Repuesto)
    UNION ALL

    --Hechos de compras
    SELECT 'Hecho_Compra', 'Compras',
           (SELECT COUNT(*) FROM MEGA_DB.Compra),
           (SELECT ISNULL(SUM(cantidad_compras), 0) FROM MEGA_DB.BI_Hecho_Compra)
    UNION ALL
    SELECT 'Hecho_Compra', 'Importe',
           (SELECT ISNULL(SUM(total), 0) FROM MEGA_DB.Compra),
           (SELECT ISNULL(SUM(importe), 0) FROM MEGA_DB.BI_Hecho_Compra)
    UNION ALL
    SELECT 'Hecho_Compra_Producto', 'Compras por tipo',
           (SELECT COUNT(*) FROM (
                SELECT DISTINCT d.compra_id, p.tipo_producto_id
                FROM MEGA_DB.Compra_Detalle d
                JOIN MEGA_DB.Producto p ON p.producto_id = d.producto_id
            ) ct),
           (SELECT ISNULL(SUM(cantidad_compras), 0) FROM MEGA_DB.BI_Hecho_Compra_Producto)
    UNION ALL
    SELECT 'Hecho_Compra_Producto', 'Unidades',
           (SELECT ISNULL(SUM(cantidad), 0) FROM MEGA_DB.Compra_Detalle),
           (SELECT ISNULL(SUM(unidades), 0) FROM MEGA_DB.BI_Hecho_Compra_Producto)
) v;
GO

--Se muestra el resultado del control al ejecutar el script.
SELECT * FROM MEGA_DB.BI_vw_Estado_Migracion;
GO

/* =====================================================================
   6. INDICES
   La PK clustered de cada hecho empieza por (tiempo_id, local_id), que es
   por donde agrupan la mayoria de las vistas. Se agregan indices sobre la
   otra dimension de los hechos que algunas vistas agrupan sin local.
   ===================================================================== */

--Hecho_Venta: agrupacion por tipo de producto y rango etario (vista 2).
CREATE NONCLUSTERED INDEX IX_BI_Hecho_Venta_Tipo_Rango
ON MEGA_DB.BI_Hecho_Venta (tipo_producto_id, rango_etario_id)
INCLUDE (cantidad_ventas, importe);
GO

--Hecho_Alquiler: agrupacion por categoria de bicicleta (vista 5).
CREATE NONCLUSTERED INDEX IX_BI_Hecho_Alquiler_Categoria
ON MEGA_DB.BI_Hecho_Alquiler (categoria_bicicleta_id)
INCLUDE (cantidad_alquileres);
GO

--Hecho_Repuesto: agrupacion por categoria de repuesto (vista 7).
CREATE NONCLUSTERED INDEX IX_BI_Hecho_Repuesto_Categoria
ON MEGA_DB.BI_Hecho_Repuesto (categoria_repuesto_id)
INCLUDE (unidades);
GO

--Hecho_Compra_Producto: agrupacion por tipo de producto (vista 9).
CREATE NONCLUSTERED INDEX IX_BI_Hecho_Compra_Producto_Tipo
ON MEGA_DB.BI_Hecho_Compra_Producto (tipo_producto_id)
INCLUDE (cantidad_compras, unidades);
GO

PRINT 'Modelo BI creado y cargado con exito.';
GO
