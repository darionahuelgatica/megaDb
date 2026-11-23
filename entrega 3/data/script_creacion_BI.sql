/* Tercera entrega - MEGA_DB (13), K3623.
   Ejecutar DESPUES de script_creacion_inicial.sql, sobre GD2C_2026.
   Toda la carga proviene del modelo transaccional MEGA_DB.
   Cabeceras y detalles separados para no multiplicar importes.
   Reejecucion de la carga: EXEC MEGA_DB.BI_Cargar_Modelo (reemplazo atomico).
   La creacion de objetos se ejecuta una sola vez. */
USE GD2C_2026
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO
-- Tiempo: claves y medidas del modelo dimensional.
CREATE TABLE MEGA_DB.BI_Tiempo (
    tiempo_id INT PRIMARY KEY,
    anio INT NOT NULL,
    trimestre INT NOT NULL CHECK (trimestre BETWEEN 1 AND 4),
    mes INT NOT NULL CHECK (mes BETWEEN 1 AND 12),
    UNIQUE(anio,mes)
);
GO
-- Local: claves y medidas del modelo dimensional.
CREATE TABLE MEGA_DB.BI_Local (
    local_id INT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    localidad VARCHAR(255) NOT NULL,
    provincia VARCHAR(255) NOT NULL
);
GO
-- Rango_Etario: claves y medidas del modelo dimensional.
CREATE TABLE MEGA_DB.BI_Rango_Etario (
    rango_etario_id INT PRIMARY KEY,
    descripcion VARCHAR(255) NOT NULL,
    edad_desde INT NULL,
    edad_hasta INT NULL
);
GO
-- Tipo_Producto: claves y medidas del modelo dimensional.
CREATE TABLE MEGA_DB.BI_Tipo_Producto (
    tipo_producto_id INT PRIMARY KEY,
    descripcion VARCHAR(255) NOT NULL
);
GO
-- Categoria_Bicicleta: claves y medidas del modelo dimensional.
CREATE TABLE MEGA_DB.BI_Categoria_Bicicleta (
    categoria_bicicleta_id INT PRIMARY KEY,
    descripcion VARCHAR(255) NOT NULL
);
GO
-- Categoria_Repuesto: claves y medidas del modelo dimensional.
CREATE TABLE MEGA_DB.BI_Categoria_Repuesto (
    categoria_repuesto_id INT PRIMARY KEY,
    descripcion VARCHAR(255) NOT NULL
);
GO
-- Tipo_Ingreso_Reparacion: claves y medidas del modelo dimensional.
CREATE TABLE MEGA_DB.BI_Tipo_Ingreso_Reparacion (
    tipo_ingreso_id INT PRIMARY KEY,
    descripcion VARCHAR(255) NOT NULL
);
GO
-- Venta: claves y medidas del modelo dimensional.
CREATE TABLE MEGA_DB.BI_Venta (
    venta_id INT PRIMARY KEY,
    tiempo_id INT NOT NULL REFERENCES MEGA_DB.BI_Tiempo(tiempo_id),
    local_id INT NOT NULL REFERENCES MEGA_DB.BI_Local(local_id),
    rango_etario_id INT NOT NULL REFERENCES MEGA_DB.BI_Rango_Etario(rango_etario_id),
    total NUMERIC(38,2) NOT NULL
);
GO
-- Venta_Detalle: claves y medidas del modelo dimensional.
CREATE TABLE MEGA_DB.BI_Venta_Detalle (
    venta_detalle_id INT PRIMARY KEY,
    venta_id INT NOT NULL REFERENCES MEGA_DB.BI_Venta(venta_id),
    tipo_producto_id INT NOT NULL REFERENCES MEGA_DB.BI_Tipo_Producto(tipo_producto_id),
    cantidad INT NOT NULL,
    subtotal NUMERIC(38,2) NOT NULL
);
GO
-- Alquiler: claves y medidas del modelo dimensional.
CREATE TABLE MEGA_DB.BI_Alquiler (
    alquiler_id INT PRIMARY KEY,
    tiempo_id INT NOT NULL REFERENCES MEGA_DB.BI_Tiempo(tiempo_id),
    local_id INT NOT NULL REFERENCES MEGA_DB.BI_Local(local_id),
    categoria_bicicleta_id INT NOT NULL REFERENCES MEGA_DB.BI_Categoria_Bicicleta(categoria_bicicleta_id),
    horas_reales DECIMAL(20,6) NULL,
    importe_total NUMERIC(38,2) NOT NULL
);
GO
-- Reparacion: claves y medidas del modelo dimensional.
CREATE TABLE MEGA_DB.BI_Reparacion (
    reparacion_id INT PRIMARY KEY,
    tiempo_id INT NOT NULL REFERENCES MEGA_DB.BI_Tiempo(tiempo_id),
    local_id INT NOT NULL REFERENCES MEGA_DB.BI_Local(local_id),
    desvio_dias DECIMAL(20,6) NULL,
    precio_total NUMERIC(38,2) NOT NULL
);
GO
-- Ingreso_Reparacion: claves y medidas del modelo dimensional.
CREATE TABLE MEGA_DB.BI_Ingreso_Reparacion (
    reparacion_id INT NOT NULL REFERENCES MEGA_DB.BI_Reparacion(reparacion_id),
    tipo_ingreso_id INT NOT NULL REFERENCES MEGA_DB.BI_Tipo_Ingreso_Reparacion(tipo_ingreso_id),
    importe NUMERIC(38,2) NOT NULL,
    PRIMARY KEY(reparacion_id,tipo_ingreso_id)
);
GO
-- Reparacion_Repuesto: claves y medidas del modelo dimensional.
CREATE TABLE MEGA_DB.BI_Reparacion_Repuesto (
    reparacion_repuesto_id INT PRIMARY KEY,
    reparacion_id INT NOT NULL REFERENCES MEGA_DB.BI_Reparacion(reparacion_id),
    categoria_repuesto_id INT NOT NULL REFERENCES MEGA_DB.BI_Categoria_Repuesto(categoria_repuesto_id),
    cantidad INT NOT NULL
);
GO
-- Compra: claves y medidas del modelo dimensional.
CREATE TABLE MEGA_DB.BI_Compra (
    compra_id INT PRIMARY KEY,
    tiempo_id INT NOT NULL REFERENCES MEGA_DB.BI_Tiempo(tiempo_id),
    local_id INT NOT NULL REFERENCES MEGA_DB.BI_Local(local_id),
    total NUMERIC(38,2) NOT NULL
);
GO
-- Compra_Detalle: claves y medidas del modelo dimensional.
CREATE TABLE MEGA_DB.BI_Compra_Detalle (
    compra_detalle_id INT PRIMARY KEY,
    compra_id INT NOT NULL REFERENCES MEGA_DB.BI_Compra(compra_id),
    tipo_producto_id INT NOT NULL REFERENCES MEGA_DB.BI_Tipo_Producto(tipo_producto_id),
    cantidad INT NOT NULL
);
GO
-- Recarga completa: primero hechos, luego dimensiones; revierte ante cualquier error.
CREATE PROCEDURE MEGA_DB.BI_Cargar_Modelo
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

            DELETE FROM MEGA_DB.BI_Compra_Detalle;
            DELETE FROM MEGA_DB.BI_Compra;
            DELETE FROM MEGA_DB.BI_Reparacion_Repuesto;
            DELETE FROM MEGA_DB.BI_Ingreso_Reparacion;
            DELETE FROM MEGA_DB.BI_Reparacion;
            DELETE FROM MEGA_DB.BI_Alquiler;
            DELETE FROM MEGA_DB.BI_Venta_Detalle;
            DELETE FROM MEGA_DB.BI_Venta;
            DELETE FROM MEGA_DB.BI_Tipo_Ingreso_Reparacion;
            DELETE FROM MEGA_DB.BI_Categoria_Repuesto;
            DELETE FROM MEGA_DB.BI_Categoria_Bicicleta;
            DELETE FROM MEGA_DB.BI_Tipo_Producto;
            DELETE FROM MEGA_DB.BI_Rango_Etario;
            DELETE FROM MEGA_DB.BI_Local;
            DELETE FROM MEGA_DB.BI_Tiempo;

            -- Meses presentes en los cuatro procesos, sin fechas ni operaciones inventadas.
            INSERT MEGA_DB.BI_Tiempo
            SELECT DISTINCT YEAR(fecha)*100+MONTH(fecha), YEAR(fecha), DATEPART(QUARTER,fecha), MONTH(fecha)
            FROM (SELECT fecha_venta fecha FROM MEGA_DB.Venta
                UNION ALL SELECT fecha_inicio FROM MEGA_DB.Alquiler
                UNION ALL SELECT fecha_ingreso FROM MEGA_DB.Reparacion
                UNION ALL SELECT fecha_compra FROM MEGA_DB.Compra) f;
            INSERT MEGA_DB.BI_Local
            SELECT l.local_id,l.nombre,u.nombre,p.nombre FROM MEGA_DB.Local l
            JOIN MEGA_DB.Localidad u ON u.localidad_id=l.localidad_id
            JOIN MEGA_DB.Provincia p ON p.provincia_id=u.provincia_id;

            -- El enunciado superpone 25 y 35: se asignan al intervalo inferior.
            INSERT MEGA_DB.BI_Rango_Etario VALUES
            (0,'Sin edad valida',NULL,NULL),(1,'Hasta 25 inclusive',0,25),
            (2,'26 a 35 inclusive',26,35),(3,'36 a 50 inclusive',36,50),(4,'Mayores de 50',51,NULL);

            INSERT MEGA_DB.BI_Tipo_Producto SELECT tipo_producto_id,descripcion FROM MEGA_DB.Tipo_Producto;

            INSERT MEGA_DB.BI_Categoria_Bicicleta SELECT categoria_bicicleta_id,descripcion FROM MEGA_DB.Categoria_Bicicleta;

            INSERT MEGA_DB.BI_Categoria_Repuesto SELECT categoria_repuesto_id,descripcion FROM MEGA_DB.Categoria_Repuesto;

            INSERT MEGA_DB.BI_Tipo_Ingreso_Reparacion VALUES (1,'Mano de Obra'),(2,'Repuestos');

            -- Edad cumplida a la fecha de venta; no depende de la fecha de ejecucion.
            INSERT MEGA_DB.BI_Venta
            SELECT v.venta_id,YEAR(v.fecha_venta)*100+MONTH(v.fecha_venta),v.local_id,
            CASE WHEN p.fecha_nacimiento>v.fecha_venta THEN 0
                WHEN e.edad<=25 THEN 1 WHEN e.edad<=35 THEN 2 WHEN e.edad<=50 THEN 3 ELSE 4 END,v.total
            FROM MEGA_DB.Venta v 
            JOIN MEGA_DB.Persona p ON p.persona_id=v.cliente_id
            CROSS APPLY (SELECT DATEDIFF(YEAR,p.fecha_nacimiento,v.fecha_venta)
            -CASE WHEN DATEADD(YEAR,DATEDIFF(YEAR,p.fecha_nacimiento,v.fecha_venta),p.fecha_nacimiento)>v.fecha_venta THEN 1 ELSE 0 END edad) e;

            -- Subtotales originales, incluso si difieren de cantidad por precio.
            INSERT MEGA_DB.BI_Venta_Detalle
            SELECT d.venta_detalle_id,d.venta_id,p.tipo_producto_id,d.cantidad,d.subtotal
            FROM MEGA_DB.Venta_Detalle d 
            JOIN MEGA_DB.Producto p ON p.producto_id=d.producto_id;

            -- Duracion fraccionaria real. Un alquiler abierto no tiene duracion real.
            INSERT MEGA_DB.BI_Alquiler
            SELECT a.alquiler_id,YEAR(a.fecha_inicio)*100+MONTH(a.fecha_inicio),b.local_id,m.categoria_bicicleta_id,
            CAST(DATEDIFF_BIG(MICROSECOND,a.fecha_inicio,a.fecha_devolucion_real)/3600000000.0 AS DECIMAL(20,6)),a.importe_total
            FROM MEGA_DB.Alquiler a 
            JOIN MEGA_DB.Bicicleta_Alquiler b ON b.bicicleta_alquiler_id=a.bicicleta_alquiler_id
            JOIN MEGA_DB.Modelo_Bicicleta m ON m.modelo_bicicleta_id=b.modelo_bicicleta_id;

            -- Desvio firmado: positivo es atraso; negativo, entrega anticipada.
            INSERT MEGA_DB.BI_Reparacion
            SELECT reparacion_id,YEAR(fecha_ingreso)*100+MONTH(fecha_ingreso),local_id,
            CAST(DATEDIFF_BIG(MICROSECOND,fecha_entrega_estimada,fecha_entrega_real)/86400000000.0 AS DECIMAL(20,6)),precio_total
            FROM MEGA_DB.Reparacion;

            -- Dos componentes por reparacion, sin repetirlos por cada repuesto usado.
            INSERT MEGA_DB.BI_Ingreso_Reparacion
            SELECT reparacion_id,1,precio_mano_obra FROM MEGA_DB.Reparacion
            UNION ALL SELECT reparacion_id,2,precio_repuestos FROM MEGA_DB.Reparacion;

            INSERT MEGA_DB.BI_Reparacion_Repuesto
            SELECT d.reparacion_repuesto_id,d.reparacion_id,r.categoria_repuesto_id,d.cantidad
            FROM MEGA_DB.Reparacion_Repuesto d JOIN MEGA_DB.Repuesto r ON r.repuesto_id=d.repuesto_id;

            INSERT MEGA_DB.BI_Compra
            SELECT compra_id,YEAR(fecha_compra)*100+MONTH(fecha_compra),local_id,total FROM MEGA_DB.Compra;

            INSERT MEGA_DB.BI_Compra_Detalle
            SELECT d.compra_detalle_id,d.compra_id,p.tipo_producto_id,d.cantidad
            FROM MEGA_DB.Compra_Detalle d JOIN MEGA_DB.Producto p ON p.producto_id=d.producto_id;

        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

EXEC MEGA_DB.BI_Cargar_Modelo;
GO

-- Vistas

-- 1. Total de cabeceras de venta por local y mes.
CREATE VIEW MEGA_DB.BI_01_Facturacion_Ventas_Mensual
AS
SELECT t.anio,t.mes,l.local_id,l.nombre local,SUM(v.total) facturacion
FROM MEGA_DB.BI_Venta v 
JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id=v.tiempo_id 
JOIN MEGA_DB.BI_Local l ON l.local_id=v.local_id
GROUP BY t.anio,t.mes,l.local_id,l.nombre;
GO

-- 2. Importe del tipo por ticket que lo contiene, mes y edad.
CREATE VIEW MEGA_DB.BI_02_Ticket_Promedio
AS
SELECT t.anio,t.mes,p.tipo_producto_id,p.descripcion tipo_producto,r.rango_etario_id,r.descripcion rango_etario,
CAST(SUM(d.subtotal)/NULLIF(COUNT(DISTINCT v.venta_id),0) AS DECIMAL(38,2)) ticket_promedio
FROM MEGA_DB.BI_Venta v 
JOIN MEGA_DB.BI_Venta_Detalle d ON d.venta_id=v.venta_id
JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id=v.tiempo_id 
JOIN MEGA_DB.BI_Tipo_Producto p ON p.tipo_producto_id=d.tipo_producto_id
JOIN MEGA_DB.BI_Rango_Etario r ON r.rango_etario_id=v.rango_etario_id
GROUP BY t.anio,t.mes,p.tipo_producto_id,p.descripcion,r.rango_etario_id,r.descripcion;
GO

-- 3. Participacion de cada tipo en unidades vendidas por local/trimestre.
CREATE VIEW MEGA_DB.BI_03_Porcentaje_Ventas_Trimestral
AS
WITH unidades AS (
    SELECT t.anio,t.trimestre,v.local_id,d.tipo_producto_id,SUM(CAST(d.cantidad AS BIGINT)) cantidad
    FROM MEGA_DB.BI_Venta v 
    JOIN MEGA_DB.BI_Venta_Detalle d ON d.venta_id=v.venta_id 
    JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id=v.tiempo_id
    GROUP BY t.anio,t.trimestre,v.local_id,d.tipo_producto_id)
SELECT u.anio,u.trimestre,l.local_id,l.nombre local,p.tipo_producto_id,p.descripcion tipo_producto,u.cantidad,
CAST(100.0*u.cantidad/NULLIF(SUM(u.cantidad) OVER(PARTITION BY u.anio,u.trimestre,u.local_id),0) AS DECIMAL(9,4)) porcentaje
FROM unidades u 
JOIN MEGA_DB.BI_Local l ON l.local_id=u.local_id 
JOIN MEGA_DB.BI_Tipo_Producto p ON p.tipo_producto_id=u.tipo_producto_id;
GO

-- 4. Horas reales promedio; solo alquileres con devolucion real.
CREATE VIEW MEGA_DB.BI_04_Horas_Alquiler_Mensual
AS
SELECT t.anio,t.mes,l.local_id,l.nombre local,AVG(a.horas_reales) horas_promedio,COUNT_BIG(a.horas_reales) alquileres_finalizados
FROM MEGA_DB.BI_Alquiler a 
JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id=a.tiempo_id 
JOIN MEGA_DB.BI_Local l ON l.local_id=a.local_id
WHERE a.horas_reales IS NOT NULL 
GROUP BY t.anio,t.mes,l.local_id,l.nombre;
GO

-- 5. Exactamente hasta cinco categorias por anio; desempate por ID.
CREATE VIEW MEGA_DB.BI_05_Top_Categorias_Alquiler
AS
WITH cantidades AS (
        SELECT t.anio,a.categoria_bicicleta_id,COUNT_BIG(*) cantidad_alquileres 
        FROM MEGA_DB.BI_Alquiler a
        JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id=a.tiempo_id 
        GROUP BY t.anio,a.categoria_bicicleta_id), 
    ranking AS (SELECT *,ROW_NUMBER() OVER(PARTITION BY anio ORDER BY cantidad_alquileres DESC,categoria_bicicleta_id) posicion FROM cantidades)

SELECT r.anio,r.posicion,c.categoria_bicicleta_id,c.descripcion categoria,r.cantidad_alquileres
FROM ranking r 
JOIN MEGA_DB.BI_Categoria_Bicicleta c ON c.categoria_bicicleta_id=r.categoria_bicicleta_id 
WHERE r.posicion<=5;
GO

-- 6. Dias reales de desvio por trimestre de ingreso y local.
CREATE VIEW MEGA_DB.BI_06_Desvio_Reparaciones
AS
SELECT t.anio,t.trimestre,l.local_id,l.nombre local,AVG(r.desvio_dias) desvio_promedio_dias,COUNT_BIG(r.desvio_dias) reparaciones_entregadas
FROM MEGA_DB.BI_Reparacion r 
JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id=r.tiempo_id 
JOIN MEGA_DB.BI_Local l ON l.local_id=r.local_id
WHERE r.desvio_dias IS NOT NULL 
GROUP BY t.anio,t.trimestre,l.local_id,l.nombre;
GO

-- 7. Categorias ordenadas por unidades utilizadas, con empates.
CREATE VIEW MEGA_DB.BI_07_Ranking_Repuestos
AS
WITH cantidades AS (
    SELECT t.anio,t.mes,d.categoria_repuesto_id,SUM(CAST(d.cantidad AS BIGINT)) unidades
    FROM MEGA_DB.BI_Reparacion_Repuesto d 
    JOIN MEGA_DB.BI_Reparacion r ON r.reparacion_id=d.reparacion_id
    JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id=r.tiempo_id 
    GROUP BY t.anio,t.mes,d.categoria_repuesto_id)
SELECT u.anio,u.mes,c.categoria_repuesto_id,c.descripcion categoria,u.unidades,
DENSE_RANK() OVER(PARTITION BY u.anio,u.mes ORDER BY u.unidades DESC) posicion
FROM cantidades u 
JOIN MEGA_DB.BI_Categoria_Repuesto c ON c.categoria_repuesto_id=u.categoria_repuesto_id;
GO

-- 8. Componentes sobre suma de componentes, por trimestre.
CREATE VIEW MEGA_DB.BI_08_Porcentaje_Ingresos_Reparacion
AS
WITH importes AS (
    SELECT t.anio,t.trimestre,i.tipo_ingreso_id,SUM(i.importe) importe
    FROM MEGA_DB.BI_Ingreso_Reparacion i JOIN MEGA_DB.BI_Reparacion r ON r.reparacion_id=i.reparacion_id
    JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id=r.tiempo_id GROUP BY t.anio,t.trimestre,i.tipo_ingreso_id)
SELECT i.anio,i.trimestre,p.tipo_ingreso_id,p.descripcion tipo_ingreso,i.importe,
CAST(CAST(i.importe AS DECIMAL(28,2))/NULLIF(CAST(SUM(i.importe) OVER(PARTITION BY i.anio,i.trimestre) AS DECIMAL(28,2)),0)*100 AS DECIMAL(9,4)) porcentaje
FROM importes i 
JOIN MEGA_DB.BI_Tipo_Ingreso_Reparacion p ON p.tipo_ingreso_id=i.tipo_ingreso_id;
GO

-- 9. Unidades por compra que contiene el tipo, no promedio de renglones.
CREATE VIEW MEGA_DB.BI_09_Unidades_Compradas_Promedio
AS
    SELECT t.anio,t.trimestre,p.tipo_producto_id,p.descripcion tipo_producto,
    CAST(SUM(CAST(d.cantidad AS DECIMAL(28,4)))/NULLIF(COUNT(DISTINCT c.compra_id),0) AS DECIMAL(28,4)) unidades_promedio
    FROM MEGA_DB.BI_Compra c 
    JOIN MEGA_DB.BI_Compra_Detalle d ON d.compra_id=c.compra_id 
    JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id=c.tiempo_id
    JOIN MEGA_DB.BI_Tipo_Producto p ON p.tipo_producto_id=d.tipo_producto_id 
    GROUP BY t.anio,t.trimestre,p.tipo_producto_id,p.descripcion;
GO

-- 10. Total original de compra, sin recalcular desde detalles.
CREATE VIEW MEGA_DB.BI_10_Importe_Compras_Mensual
AS
    SELECT t.anio,t.mes,l.local_id,l.nombre local,SUM(c.total) importe_total
    FROM MEGA_DB.BI_Compra c 
    JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id=c.tiempo_id 
    JOIN MEGA_DB.BI_Local l ON l.local_id=c.local_id
    GROUP BY t.anio,t.mes,l.local_id,l.nombre;
GO

-- Vista
CREATE VIEW MEGA_DB.BI_11_Facturacion_Negocio_Mensual
AS
WITH ingresos AS (
    SELECT tiempo_id,local_id,total importe FROM MEGA_DB.BI_Venta UNION ALL
    SELECT tiempo_id,local_id,importe_total FROM MEGA_DB.BI_Alquiler UNION ALL
    SELECT tiempo_id,local_id,precio_total FROM MEGA_DB.BI_Reparacion)
SELECT t.anio,t.mes,l.local_id,l.nombre local,SUM(i.importe) facturacion_total
FROM ingresos i 
JOIN MEGA_DB.BI_Tiempo t ON t.tiempo_id=i.tiempo_id 
JOIN MEGA_DB.BI_Local l ON l.local_id=i.local_id
GROUP BY t.anio,t.mes,l.local_id,l.nombre;
GO


-- Indices
CREATE INDEX IX_BI_Venta_Periodo_Local ON MEGA_DB.BI_Venta(tiempo_id,local_id);
GO
CREATE INDEX IX_BI_Alquiler_Periodo_Local ON MEGA_DB.BI_Alquiler(tiempo_id,local_id);
GO
CREATE INDEX IX_BI_Reparacion_Periodo_Local ON MEGA_DB.BI_Reparacion(tiempo_id,local_id);
GO
CREATE INDEX IX_BI_Compra_Periodo_Local ON MEGA_DB.BI_Compra(tiempo_id,local_id);
GO
CREATE INDEX IX_BI_Venta_Detalle_Cabecera ON MEGA_DB.BI_Venta_Detalle(venta_id);
GO
CREATE INDEX IX_BI_Compra_Detalle_Cabecera ON MEGA_DB.BI_Compra_Detalle(compra_id);
GO
CREATE INDEX IX_BI_Reparacion_Repuesto_Cabecera ON MEGA_DB.BI_Reparacion_Repuesto(reparacion_id);
GO
