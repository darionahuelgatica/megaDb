--Script auxiliar para borrar exclusivamente los objetos del modelo BI.
--No elimina el esquema MEGA_DB ni los objetos del modelo transaccional.
--Los indices y constraints se eliminan junto con sus tablas.
USE [GD2C_2026];
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRAN;

    --Vistas de BI
    IF OBJECT_ID(N'MEGA_DB.BI_01_Facturacion_Ventas_Mensual', N'V') IS NOT NULL
    BEGIN
        DROP VIEW MEGA_DB.[BI_01_Facturacion_Ventas_Mensual];
        PRINT 'Se elimino MEGA_DB.BI_01_Facturacion_Ventas_Mensual';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_02_Ticket_Promedio', N'V') IS NOT NULL
    BEGIN
        DROP VIEW MEGA_DB.[BI_02_Ticket_Promedio];
        PRINT 'Se elimino MEGA_DB.BI_02_Ticket_Promedio';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_03_Porcentaje_Ventas_Trimestral', N'V') IS NOT NULL
    BEGIN
        DROP VIEW MEGA_DB.[BI_03_Porcentaje_Ventas_Trimestral];
        PRINT 'Se elimino MEGA_DB.BI_03_Porcentaje_Ventas_Trimestral';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_04_Horas_Alquiler_Mensual', N'V') IS NOT NULL
    BEGIN
        DROP VIEW MEGA_DB.[BI_04_Horas_Alquiler_Mensual];
        PRINT 'Se elimino MEGA_DB.BI_04_Horas_Alquiler_Mensual';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_05_Top_Categorias_Alquiler', N'V') IS NOT NULL
    BEGIN
        DROP VIEW MEGA_DB.[BI_05_Top_Categorias_Alquiler];
        PRINT 'Se elimino MEGA_DB.BI_05_Top_Categorias_Alquiler';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_06_Desvio_Reparaciones', N'V') IS NOT NULL
    BEGIN
        DROP VIEW MEGA_DB.[BI_06_Desvio_Reparaciones];
        PRINT 'Se elimino MEGA_DB.BI_06_Desvio_Reparaciones';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_07_Ranking_Repuestos', N'V') IS NOT NULL
    BEGIN
        DROP VIEW MEGA_DB.[BI_07_Ranking_Repuestos];
        PRINT 'Se elimino MEGA_DB.BI_07_Ranking_Repuestos';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_08_Porcentaje_Ingresos_Reparacion', N'V') IS NOT NULL
    BEGIN
        DROP VIEW MEGA_DB.[BI_08_Porcentaje_Ingresos_Reparacion];
        PRINT 'Se elimino MEGA_DB.BI_08_Porcentaje_Ingresos_Reparacion';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_09_Unidades_Compradas_Promedio', N'V') IS NOT NULL
    BEGIN
        DROP VIEW MEGA_DB.[BI_09_Unidades_Compradas_Promedio];
        PRINT 'Se elimino MEGA_DB.BI_09_Unidades_Compradas_Promedio';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_10_Importe_Compras_Mensual', N'V') IS NOT NULL
    BEGIN
        DROP VIEW MEGA_DB.[BI_10_Importe_Compras_Mensual];
        PRINT 'Se elimino MEGA_DB.BI_10_Importe_Compras_Mensual';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_11_Facturacion_Negocio_Mensual', N'V') IS NOT NULL
    BEGIN
        DROP VIEW MEGA_DB.[BI_11_Facturacion_Negocio_Mensual];
        PRINT 'Se elimino MEGA_DB.BI_11_Facturacion_Negocio_Mensual';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_vw_Estado_Migracion', N'V') IS NOT NULL
    BEGIN
        DROP VIEW MEGA_DB.[BI_vw_Estado_Migracion];
        PRINT 'Se elimino MEGA_DB.BI_vw_Estado_Migracion';
    END

    IF OBJECT_ID(N'MEGA_DB.vw_Estado_Migracion_BI', N'V') IS NOT NULL
    BEGIN
        DROP VIEW MEGA_DB.[vw_Estado_Migracion_BI];
        PRINT 'Se elimino MEGA_DB.vw_Estado_Migracion_BI';
    END


    --Stored procedure de carga
    IF OBJECT_ID(N'MEGA_DB.BI_Cargar_Modelo', N'P') IS NOT NULL
    BEGIN
        DROP PROCEDURE MEGA_DB.[BI_Cargar_Modelo];
        PRINT 'Se elimino MEGA_DB.BI_Cargar_Modelo';
    END


    --Tablas de hechos del modelo actual
    IF OBJECT_ID(N'MEGA_DB.BI_Hecho_Venta', N'U') IS NOT NULL
    BEGIN
        DROP TABLE MEGA_DB.[BI_Hecho_Venta];
        PRINT 'Se elimino MEGA_DB.BI_Hecho_Venta';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_Hecho_Alquiler', N'U') IS NOT NULL
    BEGIN
        DROP TABLE MEGA_DB.[BI_Hecho_Alquiler];
        PRINT 'Se elimino MEGA_DB.BI_Hecho_Alquiler';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_Hecho_Reparacion', N'U') IS NOT NULL
    BEGIN
        DROP TABLE MEGA_DB.[BI_Hecho_Reparacion];
        PRINT 'Se elimino MEGA_DB.BI_Hecho_Reparacion';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_Hecho_Ingreso_Reparacion', N'U') IS NOT NULL
    BEGIN
        DROP TABLE MEGA_DB.[BI_Hecho_Ingreso_Reparacion];
        PRINT 'Se elimino MEGA_DB.BI_Hecho_Ingreso_Reparacion';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_Hecho_Repuesto', N'U') IS NOT NULL
    BEGIN
        DROP TABLE MEGA_DB.[BI_Hecho_Repuesto];
        PRINT 'Se elimino MEGA_DB.BI_Hecho_Repuesto';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_Hecho_Compra', N'U') IS NOT NULL
    BEGIN
        DROP TABLE MEGA_DB.[BI_Hecho_Compra];
        PRINT 'Se elimino MEGA_DB.BI_Hecho_Compra';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_Hecho_Compra_Producto', N'U') IS NOT NULL
    BEGIN
        DROP TABLE MEGA_DB.[BI_Hecho_Compra_Producto];
        PRINT 'Se elimino MEGA_DB.BI_Hecho_Compra_Producto';
    END


    --Tablas de la version anterior (si quedaron de pruebas previas)
    IF OBJECT_ID(N'MEGA_DB.BI_Venta_Detalle', N'U') IS NOT NULL
    BEGIN
        DROP TABLE MEGA_DB.[BI_Venta_Detalle];
        PRINT 'Se elimino MEGA_DB.BI_Venta_Detalle';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_Compra_Detalle', N'U') IS NOT NULL
    BEGIN
        DROP TABLE MEGA_DB.[BI_Compra_Detalle];
        PRINT 'Se elimino MEGA_DB.BI_Compra_Detalle';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_Ingreso_Reparacion', N'U') IS NOT NULL
    BEGIN
        DROP TABLE MEGA_DB.[BI_Ingreso_Reparacion];
        PRINT 'Se elimino MEGA_DB.BI_Ingreso_Reparacion';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_Reparacion_Repuesto', N'U') IS NOT NULL
    BEGIN
        DROP TABLE MEGA_DB.[BI_Reparacion_Repuesto];
        PRINT 'Se elimino MEGA_DB.BI_Reparacion_Repuesto';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_Venta', N'U') IS NOT NULL
    BEGIN
        DROP TABLE MEGA_DB.[BI_Venta];
        PRINT 'Se elimino MEGA_DB.BI_Venta';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_Compra', N'U') IS NOT NULL
    BEGIN
        DROP TABLE MEGA_DB.[BI_Compra];
        PRINT 'Se elimino MEGA_DB.BI_Compra';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_Alquiler', N'U') IS NOT NULL
    BEGIN
        DROP TABLE MEGA_DB.[BI_Alquiler];
        PRINT 'Se elimino MEGA_DB.BI_Alquiler';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_Reparacion', N'U') IS NOT NULL
    BEGIN
        DROP TABLE MEGA_DB.[BI_Reparacion];
        PRINT 'Se elimino MEGA_DB.BI_Reparacion';
    END


    --Dimensiones compartidas
    IF OBJECT_ID(N'MEGA_DB.BI_Tiempo', N'U') IS NOT NULL
    BEGIN
        DROP TABLE MEGA_DB.[BI_Tiempo];
        PRINT 'Se elimino MEGA_DB.BI_Tiempo';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_Local', N'U') IS NOT NULL
    BEGIN
        DROP TABLE MEGA_DB.[BI_Local];
        PRINT 'Se elimino MEGA_DB.BI_Local';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_Rango_Etario', N'U') IS NOT NULL
    BEGIN
        DROP TABLE MEGA_DB.[BI_Rango_Etario];
        PRINT 'Se elimino MEGA_DB.BI_Rango_Etario';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_Tipo_Producto', N'U') IS NOT NULL
    BEGIN
        DROP TABLE MEGA_DB.[BI_Tipo_Producto];
        PRINT 'Se elimino MEGA_DB.BI_Tipo_Producto';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_Categoria_Bicicleta', N'U') IS NOT NULL
    BEGIN
        DROP TABLE MEGA_DB.[BI_Categoria_Bicicleta];
        PRINT 'Se elimino MEGA_DB.BI_Categoria_Bicicleta';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_Categoria_Repuesto', N'U') IS NOT NULL
    BEGIN
        DROP TABLE MEGA_DB.[BI_Categoria_Repuesto];
        PRINT 'Se elimino MEGA_DB.BI_Categoria_Repuesto';
    END

    IF OBJECT_ID(N'MEGA_DB.BI_Tipo_Ingreso_Reparacion', N'U') IS NOT NULL
    BEGIN
        DROP TABLE MEGA_DB.[BI_Tipo_Ingreso_Reparacion];
        PRINT 'Se elimino MEGA_DB.BI_Tipo_Ingreso_Reparacion';
    END

    COMMIT;
    PRINT 'Limpieza del modelo BI finalizada.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK;
    THROW;
END CATCH;
GO
