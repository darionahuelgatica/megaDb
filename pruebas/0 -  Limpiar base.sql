USE [GD2C_2026];
GO

-----------Borrar SPs
IF OBJECT_ID(N'MEGA_DB.sp_Migrar_Ubicaciones', N'P') IS NOT NULL
BEGIN
    DROP PROCEDURE MEGA_DB.sp_Migrar_Ubicaciones;
    PRINT 'Se elimino el SP MEGA_DB.sp_Migrar_Ubicaciones';
END
GO
IF OBJECT_ID(N'MEGA_DB.sp_Migrar_Locales', N'P') IS NOT NULL
BEGIN
    DROP PROCEDURE MEGA_DB.sp_Migrar_Locales;
    PRINT 'Se elimino el SP MEGA_DB.sp_Migrar_Locales';
END
GO
IF OBJECT_ID(N'MEGA_DB.sp_Migrar_Enums', N'P') IS NOT NULL
BEGIN
    DROP PROCEDURE MEGA_DB.sp_Migrar_Enums;
    PRINT 'Se elimino el SP MEGA_DB.sp_Migrar_Enums';
END
GO
IF OBJECT_ID(N'MEGA_DB.sp_Migrar_Personas', N'P') IS NOT NULL
BEGIN
    DROP PROCEDURE MEGA_DB.sp_Migrar_Personas;
    PRINT 'Se elimino el SP MEGA_DB.sp_Migrar_Personas';
END
GO
IF OBJECT_ID(N'MEGA_DB.sp_Migrar_Productos', N'P') IS NOT NULL
BEGIN
    DROP PROCEDURE MEGA_DB.sp_Migrar_Productos;
    PRINT 'Se elimino el SP MEGA_DB.sp_Migrar_Productos';
END
GO
IF OBJECT_ID(N'MEGA_DB.sp_Migrar_Alquileres', N'P') IS NOT NULL
BEGIN
    DROP PROCEDURE MEGA_DB.sp_Migrar_Alquileres;
    PRINT 'Se elimino el SP MEGA_DB.sp_Migrar_Alquileres';
END
GO
IF OBJECT_ID(N'MEGA_DB.sp_Migrar_Ventas', N'P') IS NOT NULL
BEGIN
    DROP PROCEDURE MEGA_DB.sp_Migrar_Ventas;
    PRINT 'Se elimino el SP MEGA_DB.sp_Migrar_Ventas';
END
GO
IF OBJECT_ID(N'MEGA_DB.sp_Migrar_Compras', N'P') IS NOT NULL
BEGIN
    DROP PROCEDURE MEGA_DB.sp_Migrar_Compras;
    PRINT 'Se elimino el SP MEGA_DB.sp_Migrar_Compras';
END
GO
IF OBJECT_ID(N'MEGA_DB.sp_Migrar_Reparaciones', N'P') IS NOT NULL
BEGIN
    DROP PROCEDURE MEGA_DB.sp_Migrar_Reparaciones;
    PRINT 'Se elimino el SP MEGA_DB.sp_Migrar_Reparaciones';
END
GO


-----------Borrar Tablas
IF OBJECT_ID(N'MEGA_DB.Accesorio', N'U') IS NOT NULL
BEGIN
    DROP TABLE MEGA_DB.Accesorio;
    PRINT 'Se elimino la tabla MEGA_DB.Accesorio';
END
GO
IF OBJECT_ID(N'MEGA_DB.Alquiler', N'U') IS NOT NULL
BEGIN
    DROP TABLE MEGA_DB.Alquiler;
    PRINT 'Se elimino la tabla MEGA_DB.Alquiler';
END
GO
IF OBJECT_ID(N'MEGA_DB.Estado_Alquiler', N'U') IS NOT NULL
BEGIN
    DROP TABLE MEGA_DB.Estado_Alquiler;
    PRINT 'Se elimino la tabla MEGA_DB.Estado_Alquiler';
END
GO
IF OBJECT_ID(N'MEGA_DB.Bicicleta_Alquiler', N'U') IS NOT NULL
BEGIN
    DROP TABLE MEGA_DB.Bicicleta_Alquiler;
    PRINT 'Se elimino la tabla MEGA_DB.Bicicleta_Alquiler';
END
GO
IF OBJECT_ID(N'MEGA_DB.Estado_Bicicleta_Alquiler', N'U') IS NOT NULL
BEGIN
    DROP TABLE MEGA_DB.Estado_Bicicleta_Alquiler;
    PRINT 'Se elimino la tabla MEGA_DB.Estado_Bicicleta_Alquiler';
END
GO
IF OBJECT_ID(N'MEGA_DB.Bicicleta_Venta', N'U') IS NOT NULL
BEGIN
    DROP TABLE MEGA_DB.Bicicleta_Venta;
    PRINT 'Se elimino la tabla MEGA_DB.Bicicleta_Venta';
END
GO
IF OBJECT_ID(N'MEGA_DB.Categoria_Accesorio', N'U') IS NOT NULL
BEGIN
    DROP TABLE MEGA_DB.Categoria_Accesorio;
    PRINT 'Se elimino la tabla MEGA_DB.Categoria_Accesorio';
END
GO
IF OBJECT_ID(N'MEGA_DB.Compra_Detalle', N'U') IS NOT NULL
BEGIN
    DROP TABLE MEGA_DB.Compra_Detalle;
    PRINT 'Se elimino la tabla MEGA_DB.Compra_Detalle';
END
GO
IF OBJECT_ID(N'MEGA_DB.Compra', N'U') IS NOT NULL
BEGIN
    DROP TABLE MEGA_DB.Compra;
    PRINT 'Se elimino la tabla MEGA_DB.Compra';
END
GO
IF OBJECT_ID(N'MEGA_DB.Venta_Detalle', N'U') IS NOT NULL
BEGIN
    DROP TABLE MEGA_DB.Venta_Detalle;
    PRINT 'Se elimino la tabla MEGA_DB.Venta_Detalle';
END
GO
IF OBJECT_ID(N'MEGA_DB.Venta', N'U') IS NOT NULL
BEGIN
    DROP TABLE MEGA_DB.Venta;
    PRINT 'Se elimino la tabla MEGA_DB.Venta';
END
GO
IF OBJECT_ID(N'MEGA_DB.Proveedor', N'U') IS NOT NULL
BEGIN
    DROP TABLE MEGA_DB.Proveedor;
    PRINT 'Se elimino la tabla MEGA_DB.Proveedor';
END
GO
IF OBJECT_ID(N'MEGA_DB.Reparacion_Repuesto', N'U') IS NOT NULL
BEGIN
    DROP TABLE MEGA_DB.Reparacion_Repuesto;
    PRINT 'Se elimino la tabla MEGA_DB.Reparacion_Repuesto';
END
GO
IF OBJECT_ID(N'MEGA_DB.Repuesto', N'U') IS NOT NULL
BEGIN
    DROP TABLE MEGA_DB.Repuesto;
    PRINT 'Se elimino la tabla MEGA_DB.Repuesto';
END
GO
IF OBJECT_ID(N'MEGA_DB.Reparacion', N'U') IS NOT NULL
BEGIN
    DROP TABLE MEGA_DB.Reparacion;
    PRINT 'Se elimino la tabla MEGA_DB.Reparacion';
END
GO
IF OBJECT_ID(N'MEGA_DB.Estado_Reparacion', N'U') IS NOT NULL
BEGIN
    DROP TABLE MEGA_DB.Estado_Reparacion;
    PRINT 'Se elimino la tabla MEGA_DB.Estado_Reparacion';
END
GO
IF OBJECT_ID(N'MEGA_DB.Categoria_Repuesto', N'U') IS NOT NULL
BEGIN
    DROP TABLE MEGA_DB.Categoria_Repuesto;
    PRINT 'Se elimino la tabla MEGA_DB.Categoria_Repuesto';
END
GO
IF OBJECT_ID(N'MEGA_DB.Producto', N'U') IS NOT NULL
BEGIN
    DROP TABLE MEGA_DB.Producto;
    PRINT 'Se elimino la tabla MEGA_DB.Producto';
END
GO
IF OBJECT_ID(N'MEGA_DB.Tipo_Producto', N'U') IS NOT NULL
BEGIN
    DROP TABLE MEGA_DB.Tipo_Producto;
    PRINT 'Se elimino la tabla MEGA_DB.Tipo_Producto';
END
GO
IF OBJECT_ID(N'MEGA_DB.Modelo_Bicicleta', N'U') IS NOT NULL
BEGIN
    DROP TABLE MEGA_DB.Modelo_Bicicleta;
    PRINT 'Se elimino la tabla MEGA_DB.Modelo_Bicicleta';
END
GO
IF OBJECT_ID(N'MEGA_DB.Categoria_Bicicleta', N'U') IS NOT NULL
BEGIN
    DROP TABLE MEGA_DB.Categoria_Bicicleta;
    PRINT 'Se elimino la tabla MEGA_DB.Categoria_Bicicleta';
END
GO
IF OBJECT_ID(N'MEGA_DB.Marca', N'U') IS NOT NULL
BEGIN
    DROP TABLE MEGA_DB.Marca;
    PRINT 'Se elimino la tabla MEGA_DB.Marca';
END
GO
IF OBJECT_ID(N'MEGA_DB.Cliente', N'U') IS NOT NULL
BEGIN
    DROP TABLE MEGA_DB.Cliente;
    PRINT 'Se elimino la tabla MEGA_DB.Cliente';
END
GO
IF OBJECT_ID(N'MEGA_DB.Empleado', N'U') IS NOT NULL
BEGIN
    DROP TABLE MEGA_DB.Empleado;
    PRINT 'Se elimino la tabla MEGA_DB.Empleado';
END
GO
IF OBJECT_ID(N'MEGA_DB.Forma_Pago', N'U') IS NOT NULL
BEGIN
    DROP TABLE MEGA_DB.Forma_Pago;
    PRINT 'Se elimino la tabla MEGA_DB.Forma_Pago';
END
GO
IF OBJECT_ID(N'MEGA_DB.Local', N'U') IS NOT NULL
BEGIN
    DROP TABLE MEGA_DB.[Local];
    PRINT 'Se elimino la tabla MEGA_DB.Local';
END
GO
IF OBJECT_ID(N'MEGA_DB.Persona', N'U') IS NOT NULL
BEGIN
    DROP TABLE MEGA_DB.Persona;
    PRINT 'Se elimino la tabla MEGA_DB.Persona';
END
GO
IF OBJECT_ID(N'MEGA_DB.Localidad', N'U') IS NOT NULL
BEGIN
    DROP TABLE MEGA_DB.Localidad;
    PRINT 'Se elimino la tabla MEGA_DB.Localidad';
END
GO
IF OBJECT_ID(N'MEGA_DB.Provincia', N'U') IS NOT NULL
BEGIN
    DROP TABLE MEGA_DB.Provincia;
    PRINT 'Se elimino la tabla MEGA_DB.Provincia';
END
GO

IF OBJECT_ID(N'MEGA_DB.vw_Estado_Migracion', N'V') IS NOT NULL
BEGIN
    DROP VIEW MEGA_DB.vw_Estado_Migracion;
    PRINT 'Se eliminó la vista MEGA_DB.vw_Estado_Migracion';
END
GO


-----------Borrar Schema
IF SCHEMA_ID(N'MEGA_DB') IS NOT NULL
BEGIN
    DROP SCHEMA MEGA_DB;
    PRINT 'Se eliminó el schema MEGA_DB';
END
GO
