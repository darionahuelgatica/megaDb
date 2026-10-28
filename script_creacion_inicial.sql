/* =====================================================================
   TP GDD 2C 2026 - FRBA Gestion de Bicicleteria
   Grupo: MEGA_DB (13) - Curso K3623
   Script de creacion inicial: crea el esquema MEGA_DB, las tablas del
   modelo relacional, los stored procedures de migracion, la vista de
   control, ejecuta la migracion desde gd_esquema.Maestra y crea los
   indices y triggers.
   ===================================================================== */

--Se trabaja sobre la base de datos del TP
USE GD2C_2026
GO

--Esquema del grupo: todos los objetos creados por el script viven aca
CREATE SCHEMA MEGA_DB
GO

/* =====================================================================
   1. CREACION DE TABLAS
   Los tipos de datos respetan los de la columna de origen en la Maestra.
   Las PK son IDENTITY (claves subrogadas) y los datos de negocio que
   identifican a cada entidad se protegen con constraints UNIQUE.
   ===================================================================== */

--Provincias de clientes, empleados, locales y proveedores (sin repetir)
CREATE TABLE MEGA_DB.[Provincia] (
    [provincia_id] INT IDENTITY(1,1) PRIMARY KEY,
    [nombre] VARCHAR(255) NOT NULL,
    CONSTRAINT [UQ_Provincia_Nombre] UNIQUE ([nombre])
);
GO

--Localidades: el nombre solo es unico dentro de una provincia
--(hay localidades con el mismo nombre en provincias distintas)
CREATE TABLE MEGA_DB.[Localidad] (
    [localidad_id] INT IDENTITY(1,1) PRIMARY KEY,
    [provincia_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Provincia]([provincia_id]),
    [nombre] VARCHAR(255) NOT NULL,
    CONSTRAINT [UQ_Localidad_Provincia_Nombre] UNIQUE ([provincia_id], [nombre])
);
GO

--Persona: datos comunes de clientes y empleados (supertipo).
--Una persona se identifica por dni + nombre + apellido + fecha de nacimiento
--porque en la Maestra hay DNIs repetidos entre personas distintas
CREATE TABLE MEGA_DB.[Persona] (
    [persona_id] INT IDENTITY(1,1) PRIMARY KEY,
    [localidad_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Localidad]([localidad_id]),
    [nombre] VARCHAR(255) NOT NULL,
    [apellido] VARCHAR(255) NOT NULL,
    [dni] varchar(255) NOT NULL,
    [telefono] VARCHAR(255) NULL,
    [email] VARCHAR(255) NULL,
    [direccion] VARCHAR(255) NOT NULL,
    [fecha_nacimiento] DATETIME2(6) NOT NULL,
    CONSTRAINT [UQ_Persona_Dni_Nombre_Apellido_FechaNac] UNIQUE ([dni], [nombre], [apellido], [fecha_nacimiento])
);
GO

--Locales de la cadena; el nombre del local es unico
CREATE TABLE MEGA_DB.[Local] (
    [local_id] INT IDENTITY(1,1) PRIMARY KEY,
    [localidad_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Localidad]([localidad_id]),
    [nombre] VARCHAR(255) NOT NULL,
    [telefono] VARCHAR(255) NULL,
    [email] VARCHAR(255) NULL,
    [direccion] VARCHAR(255) NOT NULL,
    CONSTRAINT [UQ_Local_Nombre] UNIQUE ([nombre])
);
GO

--Cliente: subtipo de Persona (la PK es tambien FK a Persona)
CREATE TABLE MEGA_DB.[Cliente] (
    [persona_id] INT PRIMARY KEY FOREIGN KEY REFERENCES MEGA_DB.[Persona]([persona_id])
);
GO

--Empleado: subtipo de Persona. Cada empleado pertenece a un unico local (local_id obligatorio)
CREATE TABLE MEGA_DB.[Empleado] (
    [persona_id] INT PRIMARY KEY FOREIGN KEY REFERENCES MEGA_DB.[Persona]([persona_id]),
    [local_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Local]([local_id]),
    [puesto] VARCHAR(255) NOT NULL,
    [fecha_ingreso] DATETIME2(6) NOT NULL
);
GO

--Marcas, compartidas por modelos de bicicleta y accesorios
CREATE TABLE MEGA_DB.[Marca] (
    [marca_id] INT IDENTITY(1,1) PRIMARY KEY,
    [nombre] VARCHAR(255) NOT NULL,
    CONSTRAINT [UQ_Marca_Nombre] UNIQUE ([nombre])
);
GO

--Categorias de bicicleta (tabla de dominio)
CREATE TABLE MEGA_DB.[Categoria_Bicicleta] (
    [categoria_bicicleta_id] INT IDENTITY(1,1) PRIMARY KEY,
    [descripcion] VARCHAR(255) NOT NULL,
    CONSTRAINT [UQ_Categoria_Bicicleta_Descripcion] UNIQUE ([descripcion])
);
GO

--Modelos de bicicleta, usados por las bicis de venta, las de alquiler y las reparaciones.
--Un modelo queda identificado por modelo + rodado + cuadro + color
CREATE TABLE MEGA_DB.[Modelo_Bicicleta] (
    [modelo_bicicleta_id] INT IDENTITY(1,1) PRIMARY KEY,
    [marca_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Marca]([marca_id]),
    [categoria_bicicleta_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Categoria_Bicicleta]([categoria_bicicleta_id]),
    [modelo] VARCHAR(255) NOT NULL,
    [rodado] VARCHAR(255) NOT NULL,
    [cuadro] VARCHAR(255) NOT NULL,
    [color] VARCHAR(255) NOT NULL,
    CONSTRAINT [UQ_Modelo_Bicicleta_Atributos] UNIQUE ([modelo], [rodado], [cuadro], [color])
);
GO

--Tipos de producto (bicicleta / accesorio)
CREATE TABLE MEGA_DB.[Tipo_Producto] (
    [tipo_producto_id] INT IDENTITY(1,1) PRIMARY KEY,
    [descripcion] VARCHAR(255) NOT NULL,
    CONSTRAINT [UQ_Tipo_Producto_Descripcion] UNIQUE ([descripcion])
);
GO

--Producto: supertipo de lo que se vende y se compra (bicicletas de venta y accesorios).
--El codigo de producto es unico y el precio no puede ser negativo
CREATE TABLE MEGA_DB.[Producto] (
    [producto_id] INT IDENTITY(1,1) PRIMARY KEY,
    [cod_producto] VARCHAR(255) NOT NULL,
    [tipo_producto_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Tipo_Producto]([tipo_producto_id]),
    [nombre] VARCHAR(255) NOT NULL,
    [descripcion] VARCHAR(255) NULL,
    [precio_venta] NUMERIC(38,2) NOT NULL,
    CONSTRAINT [UQ_Producto_Cod] UNIQUE ([cod_producto]),
    CONSTRAINT [CK_Producto_Precio] CHECK ([precio_venta] >= 0)
);
GO

--Bicicleta de venta: subtipo de Producto con su modelo y meses de garantia
CREATE TABLE MEGA_DB.[Bicicleta_Venta] (
    [producto_id] INT PRIMARY KEY FOREIGN KEY REFERENCES MEGA_DB.[Producto]([producto_id]),
    [modelo_bicicleta_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Modelo_Bicicleta]([modelo_bicicleta_id]),
    [meses_garantia] INT NOT NULL,
    CONSTRAINT [CK_Bicicleta_Venta_Garantia] CHECK ([meses_garantia] >= 0)
);
GO

--Categorias de accesorio (tabla de dominio)
CREATE TABLE MEGA_DB.[Categoria_Accesorio] (
    [categoria_accesorio_id] INT IDENTITY(1,1) PRIMARY KEY,
    [descripcion] VARCHAR(255) NOT NULL,
    CONSTRAINT [UQ_Categoria_Accesorio_Descripcion] UNIQUE ([descripcion])
);
GO

--Accesorio: subtipo de Producto con marca, categoria, talle (opcional) y color
CREATE TABLE MEGA_DB.[Accesorio] (
    [producto_id] INT PRIMARY KEY FOREIGN KEY REFERENCES MEGA_DB.[Producto]([producto_id]),
    [marca_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Marca]([marca_id]),
    [categoria_accesorio_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Categoria_Accesorio]([categoria_accesorio_id]),
    [talle] VARCHAR(255) NULL,
    [color] VARCHAR(255) NOT NULL
);
GO

--Formas de pago, usadas por ventas y alquileres
CREATE TABLE MEGA_DB.[Forma_Pago] (
    [forma_pago_id] INT IDENTITY(1,1) PRIMARY KEY,
    [descripcion] VARCHAR(255) NOT NULL,
    CONSTRAINT [UQ_Forma_Pago_Descripcion] UNIQUE ([descripcion])
);
GO

--Cabecera de venta: local, cliente, empleado que la atendio, forma de pago y total.
--El numero de venta de la Maestra es unico
CREATE TABLE MEGA_DB.[Venta] (
    [venta_id] INT IDENTITY(1,1) PRIMARY KEY,
    [nro_venta] INT NOT NULL,
    [local_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Local]([local_id]),
    [cliente_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Cliente]([persona_id]),
    [empleado_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Empleado]([persona_id]),
    [forma_pago_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Forma_Pago]([forma_pago_id]),
    [fecha_venta] DATETIME2(6) NOT NULL,
    [total] NUMERIC(38,2) NOT NULL,
    CONSTRAINT [UQ_Venta_Nro] UNIQUE ([nro_venta])
);
GO

--Renglones de cada venta. La PK es propia (no venta+producto) porque un mismo
--producto puede aparecer en mas de un renglon de la misma venta
CREATE TABLE MEGA_DB.[Venta_Detalle] (
    [venta_detalle_id] INT IDENTITY(1,1) PRIMARY KEY,
    [venta_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Venta]([venta_id]),
    [producto_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Producto]([producto_id]),
    [cantidad] INT NOT NULL,
    [precio_unitario] NUMERIC(38,2) NOT NULL,
    [subtotal] NUMERIC(38,2) NOT NULL,
    CONSTRAINT [CK_Venta_Detalle_Valores] CHECK ([cantidad] > 0 AND [precio_unitario] >= 0)
);
GO

--Estados posibles de una bicicleta de alquiler (Disponible, Alquilada, De baja)
CREATE TABLE MEGA_DB.[Estado_Bicicleta_Alquiler] (
    [estado_bicicleta_alquiler_id] INT IDENTITY(1,1) PRIMARY KEY,
    [descripcion] VARCHAR(255) NOT NULL,
    CONSTRAINT [UQ_Estado_Bicicleta_Alquiler_Descripcion] UNIQUE ([descripcion])
);
GO

--Bicicletas de la flota de alquiler: cada una pertenece a un local y se identifica por su nro de serie
CREATE TABLE MEGA_DB.[Bicicleta_Alquiler] (
    [bicicleta_alquiler_id] INT IDENTITY(1,1) PRIMARY KEY,
    [nro_serie] VARCHAR(255) NOT NULL,
    [modelo_bicicleta_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Modelo_Bicicleta]([modelo_bicicleta_id]),
    [local_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Local]([local_id]),
    [estado_bicicleta_alquiler_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Estado_Bicicleta_Alquiler]([estado_bicicleta_alquiler_id]),
    [precio_hora] NUMERIC(38,2) NOT NULL,
    [precio_dia] NUMERIC(38,2) NOT NULL,
    CONSTRAINT [UQ_Bicicleta_Alquiler_Nro_Serie] UNIQUE ([nro_serie])
);
GO

--Estados posibles de un alquiler (Reservado, En curso, Devuelto, Vencido)
CREATE TABLE MEGA_DB.[Estado_Alquiler] (
    [estado_alquiler_id] INT IDENTITY(1,1) PRIMARY KEY,
    [descripcion] VARCHAR(255) NOT NULL,
    CONSTRAINT [UQ_Estado_Alquiler_Descripcion] UNIQUE ([descripcion])
);
GO

--Alquileres. El local no se guarda porque es el de la bicicleta alquilada.
--El CHECK impide fechas de devolucion (pactada o real) anteriores al inicio
CREATE TABLE MEGA_DB.[Alquiler] (
    [alquiler_id] INT IDENTITY(1,1) PRIMARY KEY,
    [nro_alquiler] INT NOT NULL,
    [cliente_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Cliente]([persona_id]),
    [empleado_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Empleado]([persona_id]),
    [bicicleta_alquiler_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Bicicleta_Alquiler]([bicicleta_alquiler_id]),
    [estado_alquiler_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Estado_Alquiler]([estado_alquiler_id]),
    [forma_pago_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Forma_Pago]([forma_pago_id]),
    [fecha_inicio] DATETIME2(6) NOT NULL,
    [fecha_devolucion_pactada] DATETIME2(6) NOT NULL,
    [fecha_devolucion_real] DATETIME2(6) NULL,
    [importe_total] NUMERIC(38,2) NOT NULL,
    CONSTRAINT [UQ_Alquiler_Nro] UNIQUE ([nro_alquiler]),
    CONSTRAINT [CK_Alquiler_Fechas] CHECK ([fecha_devolucion_pactada] >= [fecha_inicio] AND ([fecha_devolucion_real] IS NULL OR [fecha_devolucion_real] >= [fecha_inicio]))
);
GO

--Categorias de repuesto (tabla de dominio)
CREATE TABLE MEGA_DB.[Categoria_Repuesto] (
    [categoria_repuesto_id] INT IDENTITY(1,1) PRIMARY KEY,
    [descripcion] VARCHAR(255) NOT NULL,
    CONSTRAINT [UQ_Categoria_Repuesto_Descripcion] UNIQUE ([descripcion])
);
GO

--Repuestos usados en reparaciones; el codigo de repuesto es unico
CREATE TABLE MEGA_DB.[Repuesto] (
    [repuesto_id] INT IDENTITY(1,1) PRIMARY KEY,
    [cod_repuesto] VARCHAR(255) NOT NULL,
    [categoria_repuesto_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Categoria_Repuesto]([categoria_repuesto_id]),
    [descripcion] VARCHAR(255) NOT NULL,
    [compatibilidad] VARCHAR(255) NULL,
    [precio] NUMERIC(38,2) NOT NULL,
    CONSTRAINT [UQ_Repuesto_Cod] UNIQUE ([cod_repuesto])
);
GO

--Estados posibles de una reparacion (Presupuestada, En proceso, Lista, Entregada)
CREATE TABLE MEGA_DB.[Estado_Reparacion] (
    [estado_reparacion_id] INT IDENTITY(1,1) PRIMARY KEY,
    [descripcion] VARCHAR(255) NOT NULL,
    CONSTRAINT [UQ_Estado_Reparacion_Descripcion] UNIQUE ([descripcion])
);
GO

--Reparaciones: bici del cliente (modelo y nro de serie), fechas, diagnostico y precios.
--El CHECK impide fechas de entrega (estimada o real) anteriores al ingreso
CREATE TABLE MEGA_DB.[Reparacion] (
    [reparacion_id] INT IDENTITY(1,1) PRIMARY KEY,
    [nro_reparacion] INT NOT NULL,
    [local_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Local]([local_id]),
    [cliente_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Cliente]([persona_id]),
    [empleado_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Empleado]([persona_id]),
    [modelo_bicicleta_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Modelo_Bicicleta]([modelo_bicicleta_id]),
    [estado_reparacion_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Estado_Reparacion]([estado_reparacion_id]),
    [numero_serie_bici] VARCHAR(255) NULL,
    [fecha_ingreso] DATETIME2(6) NOT NULL,
    [fecha_entrega_estimada] DATETIME2(6) NOT NULL,
    [fecha_entrega_real] DATETIME2(6) NULL,
    [diagnostico] VARCHAR(255) NOT NULL,
    [precio_mano_obra] NUMERIC(38,2) NOT NULL,
    [precio_repuestos] NUMERIC(38,2) NOT NULL,
    [precio_total] NUMERIC(38,2) NOT NULL,
    CONSTRAINT [UQ_Reparacion_Nro] UNIQUE ([nro_reparacion]),
    CONSTRAINT [CK_Reparacion_Fechas] CHECK ([fecha_entrega_estimada] >= [fecha_ingreso] AND ([fecha_entrega_real] IS NULL OR [fecha_entrega_real] >= [fecha_ingreso]))
);
GO

--Repuestos usados en cada reparacion. PK propia porque un repuesto puede
--aparecer en mas de un renglon de la misma reparacion
CREATE TABLE MEGA_DB.[Reparacion_Repuesto] (
    [reparacion_repuesto_id] INT IDENTITY(1,1) PRIMARY KEY,
    [reparacion_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Reparacion]([reparacion_id]),
    [repuesto_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Repuesto]([repuesto_id]),
    [cantidad] INT NOT NULL,
    [precio_unitario] NUMERIC(38,2) NOT NULL,
    [subtotal] NUMERIC(38,2) NOT NULL,
    CONSTRAINT [CK_Reparacion_Repuesto_Valores] CHECK ([cantidad] > 0 AND [precio_unitario] >= 0)
);
GO

--Proveedores de productos; se identifican por CUIT
CREATE TABLE MEGA_DB.[Proveedor] (
    [proveedor_id] INT IDENTITY(1,1) PRIMARY KEY,
    [localidad_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Localidad]([localidad_id]),
    [razon_social] VARCHAR(255) NOT NULL,
    [cuit] VARCHAR(255) NOT NULL,
    [telefono] VARCHAR(255) NULL,
    [email] VARCHAR(255) NULL,
    [direccion] VARCHAR(255) NOT NULL,
    CONSTRAINT [UQ_Proveedor_Cuit] UNIQUE ([cuit])
);
GO

--Cabecera de compra a un proveedor: local, empleado que la registro y total
CREATE TABLE MEGA_DB.[Compra] (
    [compra_id] INT IDENTITY(1,1) PRIMARY KEY,
    [nro_compra] INT NOT NULL,
    [proveedor_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Proveedor]([proveedor_id]),
    [local_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Local]([local_id]),
    [empleado_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Empleado]([persona_id]),
    [fecha_compra] DATETIME2(6) NOT NULL,
    [total] NUMERIC(38,2) NOT NULL,
    CONSTRAINT [UQ_Compra_Nro] UNIQUE ([nro_compra])
);
GO

--Renglones de cada compra (sin subtotal: la Maestra no lo trae)
CREATE TABLE MEGA_DB.[Compra_Detalle] (
    [compra_detalle_id] INT IDENTITY(1,1) PRIMARY KEY,
    [compra_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Compra]([compra_id]),
    [producto_id] INT NOT NULL FOREIGN KEY REFERENCES MEGA_DB.[Producto]([producto_id]),
    [cantidad] INT NOT NULL,
    [precio_unitario] NUMERIC(38,2) NOT NULL,
    CONSTRAINT [CK_Compra_Detalle_Valores] CHECK ([cantidad] > 0 AND [precio_unitario] >= 0)
);
GO

--Mensaje de control
PRINT N'Tablas creadas correctamente';
GO

/* =====================================================================
   2. STORED PROCEDURES DE MIGRACION
   Cada SP migra un grupo de tablas desde gd_esquema.Maestra. Se ejecutan
   en orden de dependencias (primero las tablas referenciadas por FKs).
   ===================================================================== */

--Migra provincias y localidades a partir de las direcciones de clientes,
--empleados, locales y proveedores
CREATE PROCEDURE MEGA_DB.sp_Migrar_Ubicaciones
AS
BEGIN
    --Evita los mensajes de "filas afectadas"
    SET NOCOUNT ON;

	--Provincias: union de las cuatro columnas de provincia de la Maestra, sin repetidos
	INSERT MEGA_DB.Provincia
	select Nombre from (
		select Cliente_Provincia as Nombre from gd_esquema.Maestra where Cliente_Provincia is not null UNION
		select Empleado_Provincia as Nombre from gd_esquema.Maestra where Empleado_Provincia is not null UNION
		select Local_Provincia as Nombre from gd_esquema.Maestra where Local_Provincia is not null UNION
		select Proveedor_Provincia as Nombre from gd_esquema.Maestra where Proveedor_Provincia is not null
		) as subconsulta_Provincias
		group by Nombre

	--Localidades: pares localidad + provincia de las cuatro fuentes, asociados
	--a la provincia ya insertada (asi se distinguen localidades homonimas)
	INSERT MEGA_DB.Localidad
	select p.provincia_id, l.Nombre from (
		select Cliente_Localidad as Nombre, Cliente_Provincia as Provincia
			from gd_esquema.Maestra where Cliente_Localidad is not null UNION
		select Empleado_Localidad as Nombre, Empleado_Provincia as Provincia
			from gd_esquema.Maestra where Empleado_Localidad is not null UNION
		select Local_Localidad as Nombre, Local_Provincia as Provincia
			from gd_esquema.Maestra where Local_Localidad is not null UNION
		select Proveedor_Localidad as Nombre, Proveedor_Provincia as Provincia
			from gd_esquema.Maestra where Proveedor_Localidad is not null
		) as l
		join MEGA_DB.Provincia p on l.Provincia = p.Nombre
		group by l.Nombre, provincia_id
END
GO

--Migra los locales con su localidad
CREATE PROCEDURE MEGA_DB.sp_Migrar_Locales
AS
BEGIN
    --Evita los mensajes de "filas afectadas"
    SET NOCOUNT ON;

	--Un local por cada combinacion distinta de sus datos; la localidad se busca
	--por nombre dentro de su provincia
	INSERT MEGA_DB.Local
	select
		l.localidad_id,
		Local_Nombre_Local,
		Local_Telefono_Local,
		Local_Email_Local,
		Local_Direccion_Local
	from gd_esquema.Maestra m
	join MEGA_DB.Provincia p on p.nombre = m.Local_Provincia
	join MEGA_DB.Localidad l on l.nombre = Local_Localidad and l.provincia_id = p.provincia_id
 	where Local_Nombre_Local is not null
	group by
		Local_Nombre_Local,
		Local_Telefono_Local,
		Local_Email_Local,
		Local_Direccion_Local,
		l.localidad_id
END
GO

--Migra las tablas de dominio: formas de pago, marcas, tipos, categorias y estados
CREATE PROCEDURE MEGA_DB.sp_Migrar_Enums
AS
BEGIN
    --Evita los mensajes de "filas afectadas"
    SET NOCOUNT ON;

	--Formas de pago distintas que aparecen en la Maestra
	INSERT MEGA_DB.Forma_pago
	select distinct Forma_Pago_Forma_Pago as descripcion
	from gd_esquema.Maestra m
	where Forma_Pago_Forma_Pago is not null

    --Marcas distintas (de bicicletas y de accesorios)
    INSERT INTO MEGA_DB.Marca (nombre)
    SELECT Marca_Marca FROM gd_esquema.Maestra WHERE Marca_Marca IS NOT NULL
    GROUP BY Marca_Marca;

    --Tipos de producto distintos
    INSERT INTO MEGA_DB.Tipo_Producto (descripcion)
    SELECT Tipo_Producto_Tipo_Producto FROM gd_esquema.Maestra WHERE Tipo_Producto_Tipo_Producto IS NOT NULL
    GROUP BY Tipo_Producto_Tipo_Producto;

    --Categorias de bicicleta distintas
    INSERT INTO MEGA_DB.Categoria_Bicicleta (descripcion)
    SELECT Categoria_Bicicleta_Categoria_Bicicleta FROM gd_esquema.Maestra
    WHERE Categoria_Bicicleta_Categoria_Bicicleta IS NOT NULL
    GROUP BY Categoria_Bicicleta_Categoria_Bicicleta;

    --Categorias de accesorio distintas
    INSERT INTO MEGA_DB.Categoria_Accesorio (descripcion)
    SELECT Categoria_Accesorios_Categoria_Accesorio FROM gd_esquema.Maestra
    WHERE Categoria_Accesorios_Categoria_Accesorio IS NOT NULL
    GROUP BY Categoria_Accesorios_Categoria_Accesorio;

    --Categorias de repuesto distintas
    INSERT INTO MEGA_DB.Categoria_Repuesto (descripcion)
    SELECT Categoria_Repuestos_Categoria_Respuesto FROM gd_esquema.Maestra
    WHERE Categoria_Repuestos_Categoria_Respuesto IS NOT NULL
    GROUP BY Categoria_Repuestos_Categoria_Respuesto;

    --Estados de alquiler definidos por el enunciado
    INSERT INTO MEGA_DB.Estado_Alquiler (descripcion) values
    --No todos los estados de Alquiler están presentes en la tabla Maestra asi que hay que insertarlos con VALUES
	('Reservado'), ('En curso'), ('Devuelto'), ('Vencido');

    --Estados de bicicleta de alquiler definidos por el enunciado
    INSERT INTO MEGA_DB.Estado_Bicicleta_Alquiler (descripcion) values
    --No todos los estados de Bicicleta de Alquiler están presentes en la tabla Maestra asi que hay que insertarlos con VALUES
	('Disponible'), ('Alquilada'), ('De baja');

    --Estados de reparacion definidos por el enunciado
    INSERT INTO MEGA_DB.Estado_Reparacion (descripcion) values
    --No todos los estados de Reparación están presentes en la tabla Maestra asi que hay que insertarlos con VALUES
    ('Presupuestada'), ('En proceso'), ('Lista'), ('Entregada');
END
GO

--Migra personas (clientes y empleados) y sus subtipos Cliente y Empleado
CREATE PROCEDURE MEGA_DB.sp_Migrar_Personas
AS
BEGIN
    --Evita los mensajes de "filas afectadas"
    SET NOCOUNT ON;

	--Personas: union de los datos de empleados y de clientes de la Maestra.
	--El UNION y el GROUP BY eliminan repetidos, asi una persona que es cliente
	--y empleado a la vez se carga una sola vez
	INSERT MEGA_DB.Persona
	select
		localidad_id,
		p.Nombre, p.Apellido, p.Dni, p.Telefono, p.Email, p.Direccion, p.Fecha_Nacimiento
	from
		(select
			l.localidad_id, Empleado_Nombre_Empleado as Nombre, Empleado_Apellido_Empleado as Apellido, Empleado_Dni_Empleado as Dni,
			Empleado_Telefono_Empleado as Telefono, Empleado_Email_Empleado as Email, Empleado_Domicilio_Empleado as Direccion, Empleado_Fecha_Nac_Empleado as Fecha_Nacimiento
		from gd_esquema.Maestra
		join MEGA_DB.Provincia prov on prov.nombre = Empleado_Provincia
		join MEGA_DB.Localidad l on l.nombre = Empleado_Localidad and l.provincia_id = prov.provincia_id
		where Empleado_Dni_Empleado is not null
		group by l.localidad_id, Empleado_Nombre_Empleado ,Empleado_Apellido_Empleado ,Empleado_Dni_Empleado ,Empleado_Telefono_Empleado, Empleado_Email_Empleado ,Empleado_Domicilio_Empleado ,Empleado_Fecha_Nac_Empleado
		union
		select
			l.localidad_id,
			Cliente_Nombre_Cliente as Nombre, Cliente_Apellido_Cliente as Apellido, Cliente_Dni_Cliente as Dni,
			Cliente_Telefono_Cliente as Telefono, Cliente_Email_Cliente as Email, Cliente_Direccion_Cliente as Direccion, Cliente_Fecha_Nacimiento_Cliente as Fecha_Nacimiento
		from gd_esquema.Maestra
		join MEGA_DB.Provincia prov on prov.nombre = Cliente_Provincia
		join MEGA_DB.Localidad l on l.nombre = Cliente_Localidad and l.provincia_id = prov.provincia_id
		where Cliente_Dni_Cliente is not null
		group by l.localidad_id, Cliente_Nombre_Cliente, Cliente_Apellido_Cliente, Cliente_Dni_Cliente, Cliente_Telefono_Cliente, Cliente_Email_Cliente, Cliente_Direccion_Cliente, Cliente_Fecha_Nacimiento_Cliente
		) as p
	group by p.localidad_id, p.Nombre, p.Apellido, p.Dni, p.Telefono, p.Email, p.Direccion, p.Fecha_Nacimiento

	--Clientes: cada persona que figura como cliente en la Maestra
	INSERT MEGA_DB.Cliente
		select
			p.persona_id
		from gd_esquema.Maestra
		join MEGA_DB.Persona p on Maestra.Cliente_Dni_Cliente = p.dni
			and Maestra.Cliente_Nombre_Cliente = p.nombre
			and Maestra.Cliente_Apellido_Cliente = p.apellido
			and Maestra.Cliente_Fecha_Nacimiento_Cliente = p.fecha_nacimiento --Clave completa: hay DNIs repetidos entre personas distintas
		 where Cliente_Dni_Cliente is not null
		group by p.persona_id

	--Empleados: cada persona que figura como empleado, con el local donde trabaja.
	--El local se toma de sus ventas, reparaciones y compras (los alquileres se
	--excluyen porque ahi el local de la fila es el de la bicicleta)
	INSERT MEGA_DB.Empleado
		select
            p.persona_id,
			l.local_id,
			Empleado_Puesto_Empleado,
			Empleado_Fecha_Ingreso_Empleado
		from gd_esquema.Maestra
		join MEGA_DB.Persona p on Maestra.Empleado_Dni_Empleado = p.dni
			and Maestra.Empleado_Nombre_Empleado = p.nombre
			and Maestra.Empleado_Apellido_Empleado = p.apellido
			and Maestra.Empleado_Fecha_Nac_Empleado = p.fecha_nacimiento --Clave completa: hay DNIs repetidos entre personas distintas
		join MEGA_DB.[provincia] prov on prov.nombre = Local_Provincia
		join MEGA_DB.[Localidad] ld on ld.nombre = Local_Localidad and ld.provincia_id = prov.provincia_id
		join MEGA_DB.[Local] l on l.nombre = Local_Nombre_Local and l.localidad_id = ld.localidad_id
		where Empleado_Dni_Empleado is not null
            and Alquiler_Nro_Alquiler is null --Se descartan los alquileres para poder relacionar 1 a 1 Empleado con Local
		group by
			p.persona_id,
			l.local_id,
			Empleado_Puesto_Empleado,
			Empleado_Fecha_Ingreso_Empleado
END
GO

--Migra modelos de bicicleta, productos (y sus subtipos) y repuestos
CREATE PROCEDURE MEGA_DB.sp_Migrar_Productos
AS
BEGIN
    --Evita los mensajes de "filas afectadas"
    SET NOCOUNT ON;

    --Modelos de bicicleta distintos, con su marca y categoria
    INSERT MEGA_DB.Modelo_Bicicleta
		(marca_id, categoria_bicicleta_id, modelo, rodado, cuadro, color)
	SELECT DISTINCT ma.marca_id, cb.categoria_bicicleta_id, m.Modelo_Bicicleta_Modelo_Bicicleta,
        m.Modelo_Bicicleta_Rodado_Modelo_Bicicleta, m.Modelo_Bicicleta_Cuadro_Modelo_Bicicleta,
        m.Modelo_Bicicleta_Color_Modelo_Bicicleta
    FROM gd_esquema.Maestra m
    JOIN MEGA_DB.Marca ma ON ma.nombre = m.Marca_Marca
    JOIN MEGA_DB.Categoria_Bicicleta cb ON cb.descripcion = m.Categoria_Bicicleta_Categoria_Bicicleta
    WHERE m.Modelo_Bicicleta_Modelo_Bicicleta IS NOT NULL;

    --Productos distintos (supertipo) con su tipo de producto
    INSERT MEGA_DB.Producto
		(cod_producto, tipo_producto_id, nombre, descripcion, precio_venta)
    SELECT DISTINCT m.Producto_Cod_Producto, tp.tipo_producto_id, m.Producto_Nombre_Producto,
                    m.Producto_Descripcion_Producto, m.Producto_Precio_Venta_Producto
    FROM gd_esquema.Maestra m
    JOIN MEGA_DB.Tipo_Producto tp ON tp.descripcion = m.Tipo_Producto_Tipo_Producto
    WHERE m.Producto_Cod_Producto IS NOT NULL;

	--Bicicletas de venta: productos que tienen meses de garantia, asociados a su modelo
	INSERT MEGA_DB.Bicicleta_Venta
		(producto_id, modelo_bicicleta_id, meses_garantia)
    SELECT DISTINCT pr.producto_id, mb.modelo_bicicleta_id, m.Bicicleta_Venta_Meses_Garantia_Bici_Venta
    FROM gd_esquema.Maestra m
    JOIN MEGA_DB.Producto pr ON pr.cod_producto = m.Producto_Cod_Producto
    JOIN MEGA_DB.Modelo_Bicicleta mb ON mb.modelo = m.Modelo_Bicicleta_Modelo_Bicicleta
                                    AND mb.rodado = m.Modelo_Bicicleta_Rodado_Modelo_Bicicleta
                                    AND mb.cuadro = m.Modelo_Bicicleta_Cuadro_Modelo_Bicicleta
                                    AND mb.color = m.Modelo_Bicicleta_Color_Modelo_Bicicleta
    WHERE m.Bicicleta_Venta_Meses_Garantia_Bici_Venta IS NOT NULL;

    --Accesorios: productos que tienen categoria de accesorio, con su marca
    INSERT MEGA_DB.Accesorio
		(producto_id, marca_id, categoria_accesorio_id, talle, color)
    SELECT DISTINCT pr.producto_id, ma.marca_id, ca.categoria_accesorio_id,
                    m.Accesorio_Talle_Accesorio, m.Accesorio_Color_Accesorio
    FROM gd_esquema.Maestra m
    JOIN MEGA_DB.Producto pr ON pr.cod_producto = m.Producto_Cod_Producto
    JOIN MEGA_DB.Marca ma ON ma.nombre = m.Marca_Marca
    JOIN MEGA_DB.Categoria_Accesorio ca ON ca.descripcion = m.Categoria_Accesorios_Categoria_Accesorio
    WHERE m.Categoria_Accesorios_Categoria_Accesorio IS NOT NULL;

    --Repuestos distintos con su categoria
    INSERT MEGA_DB.Repuesto
		(cod_repuesto, categoria_repuesto_id, descripcion, compatibilidad, precio)
    SELECT DISTINCT m.Repuesto_Cod_Repuesto, cr.categoria_repuesto_id, m.Repuesto_Desc_Repuesto,
                    m.Repuesto_Compatibilidad_Repuesto, m.Repuesto_Precio_Repuesto
    FROM gd_esquema.Maestra m
    JOIN MEGA_DB.Categoria_Repuesto cr ON cr.descripcion = m.Categoria_Repuestos_Categoria_Respuesto
    WHERE m.Repuesto_Cod_Repuesto IS NOT NULL;
END
GO

--Migra la flota de bicicletas de alquiler y los alquileres
CREATE PROCEDURE MEGA_DB.sp_Migrar_Alquileres
AS
BEGIN
    --Evita los mensajes de "filas afectadas"
    SET NOCOUNT ON;

    --Bicicletas de alquiler distintas con su modelo, local, estado y precios
    INSERT MEGA_DB.Bicicleta_Alquiler
		(nro_serie, modelo_bicicleta_id, local_id, estado_bicicleta_alquiler_id, precio_hora, precio_dia)
    SELECT DISTINCT m.Bicicleta_Alquiler_Nro_Serie_Bici_Alquiler, mbic.modelo_bicicleta_id, lo.local_id,
                    eb.estado_bicicleta_alquiler_id, m.Bicicleta_Alquiler_Precio_Bici_Alquiler_Hora,
                    m.Bicicleta_Alquiler_Precio_Bici_Alquiler_Dia
    FROM gd_esquema.Maestra m
    JOIN MEGA_DB.Modelo_Bicicleta mbic ON mbic.modelo = m.Modelo_Bicicleta_Modelo_Bicicleta
                                    AND mbic.rodado = m.Modelo_Bicicleta_Rodado_Modelo_Bicicleta
                                    AND mbic.cuadro = m.Modelo_Bicicleta_Cuadro_Modelo_Bicicleta
                                    AND mbic.color = m.Modelo_Bicicleta_Color_Modelo_Bicicleta
    JOIN MEGA_DB.[Local] lo ON lo.nombre = m.Local_Nombre_Local
    JOIN MEGA_DB.Estado_Bicicleta_Alquiler eb ON eb.descripcion = m.Estado_Bici_Alquiler_Estado_Bici_Alquiler
    WHERE m.Bicicleta_Alquiler_Nro_Serie_Bici_Alquiler IS NOT NULL;

    --Alquileres: el cliente y el empleado se buscan en Persona por la clave completa
    --(dni + nombre + apellido + fecha de nacimiento) y la bici por su nro de serie
    INSERT INTO MEGA_DB.Alquiler (nro_alquiler, cliente_id, empleado_id, bicicleta_alquiler_id, estado_alquiler_id,
                                  forma_pago_id, fecha_inicio, fecha_devolucion_pactada, fecha_devolucion_real,
                                  importe_total)
    SELECT DISTINCT m.Alquiler_Nro_Alquiler, pc.persona_id, pe.persona_id, ba.bicicleta_alquiler_id,
                    ea.estado_alquiler_id, fp.forma_pago_id, m.Alquiler_Fecha_Inicio_Alquiler,
                    m.Alquiler_Fecha_Fin_Pactada_Alquiler, m.Alquiler_Fecha_Devolucion_Real_Alquiler,
                    m.Alquiler_Importe_Total_Alquiler
    FROM gd_esquema.Maestra m
    JOIN MEGA_DB.Persona pc ON pc.dni = m.Cliente_Dni_Cliente
                           AND pc.nombre = m.Cliente_Nombre_Cliente
                           AND pc.apellido = m.Cliente_Apellido_Cliente
                           AND pc.fecha_nacimiento = Cliente_Fecha_Nacimiento_Cliente
    JOIN MEGA_DB.Persona pe ON pe.dni = m.Empleado_Dni_Empleado
                           AND pe.nombre = m.Empleado_Nombre_Empleado
                           AND pe.apellido = m.Empleado_Apellido_Empleado
                           AND pe.fecha_nacimiento = Empleado_Fecha_Nac_Empleado
    JOIN MEGA_DB.Bicicleta_Alquiler ba ON ba.nro_serie = m.Bicicleta_Alquiler_Nro_Serie_Bici_Alquiler
    JOIN MEGA_DB.Estado_Alquiler ea ON ea.descripcion = m.Estado_Alquiler_Estado_Alquiler
    JOIN MEGA_DB.Forma_Pago fp ON fp.descripcion = m.Forma_Pago_Forma_Pago
    WHERE m.Alquiler_Nro_Alquiler IS NOT NULL;
END
GO

--Migra las ventas y sus renglones
CREATE PROCEDURE MEGA_DB.sp_Migrar_Ventas
AS
BEGIN
    --Evita los mensajes de "filas afectadas"
    SET NOCOUNT ON;

    --Cabeceras de venta: una por nro de venta, con cliente y empleado buscados
    --por la clave completa de Persona
    INSERT MEGA_DB.Venta (nro_venta, cliente_id, empleado_id, local_id, forma_pago_id, fecha_venta, total)
    SELECT DISTINCT m.Venta_Nro_Venta, pc.persona_id, pe.persona_id, lo.local_id, fp.forma_pago_id,
                    m.Venta_Fecha_Hora_Venta, m.Venta_Total_Venta
    FROM gd_esquema.Maestra m
    JOIN MEGA_DB.Persona pc ON pc.dni = m.Cliente_Dni_Cliente
                           AND pc.nombre = m.Cliente_Nombre_Cliente
                           AND pc.apellido = m.Cliente_Apellido_Cliente
                           AND pc.fecha_nacimiento = Cliente_Fecha_Nacimiento_Cliente
    JOIN MEGA_DB.Persona pe ON pe.dni = m.Empleado_Dni_Empleado
                           AND pe.nombre = m.Empleado_Nombre_Empleado
                           AND pe.apellido = m.Empleado_Apellido_Empleado
                           AND pe.fecha_nacimiento = Empleado_Fecha_Nac_Empleado
    JOIN MEGA_DB.[Local] lo ON lo.nombre = m.Local_Nombre_Local
    JOIN MEGA_DB.Forma_Pago fp ON fp.descripcion = m.Forma_Pago_Forma_Pago
    WHERE m.Venta_Nro_Venta IS NOT NULL;

    --Cada fila de la Maestra con venta es un renglon del detalle. Un mismo producto puede aparecer
    --en varios renglones de una venta: se migran todos porque forman parte del total de la venta
    INSERT INTO MEGA_DB.Venta_Detalle (venta_id, producto_id, cantidad, precio_unitario, subtotal)
    SELECT v.venta_id, pr.producto_id, m.Detalle_Venta_Cantidad_Prod_Venta,
           m.Detalle_Venta_Precio_Unitario_Prod_Venta, m.Detalle_Venta_Subtotal_Prod_Venta
    FROM gd_esquema.Maestra m
    JOIN MEGA_DB.Venta v ON v.nro_venta = m.Venta_Nro_Venta
    JOIN MEGA_DB.Producto pr ON pr.cod_producto = m.Producto_Cod_Producto
    WHERE m.Venta_Nro_Venta IS NOT NULL;
END
GO

--Migra proveedores, compras y sus renglones
CREATE PROCEDURE MEGA_DB.sp_Migrar_Compras
AS
BEGIN
    --Evita los mensajes de "filas afectadas"
    SET NOCOUNT ON;

    --Proveedores distintos (por CUIT) con su localidad
    INSERT INTO MEGA_DB.Proveedor (localidad_id, razon_social, cuit, telefono, email, direccion)
    SELECT DISTINCT l.localidad_id, m.Proveedor_Razon_Social_Proveedor, m.Proveedor_Cuit_Proveedor,
                    m.Proveedor_Telefono_Proveedor, m.Proveedor_Email_Proveedor, m.Proveedor_Direccion_Proveedor
    FROM gd_esquema.Maestra m
    JOIN MEGA_DB.Provincia p ON p.nombre = m.Proveedor_Provincia
    JOIN MEGA_DB.Localidad l ON l.nombre = m.Proveedor_Localidad AND l.provincia_id = p.provincia_id
    WHERE m.Proveedor_Cuit_Proveedor IS NOT NULL;

    --Cabeceras de compra: una por nro de compra, con proveedor, empleado y local
    INSERT INTO MEGA_DB.Compra (nro_compra, proveedor_id, empleado_id, local_id, fecha_compra, total)
    SELECT DISTINCT m.Compra_Nro_Compra, pv.proveedor_id, pe.persona_id, lo.local_id,
                    m.Compra_Fecha_Compra, m.Compra_Total_Compra
    FROM gd_esquema.Maestra m
    JOIN MEGA_DB.Proveedor pv ON pv.cuit = m.Proveedor_Cuit_Proveedor
    JOIN MEGA_DB.Persona pe ON pe.dni = m.Empleado_Dni_Empleado
                           AND pe.nombre = m.Empleado_Nombre_Empleado
                           AND pe.apellido = m.Empleado_Apellido_Empleado
                           AND pe.fecha_nacimiento = m.Empleado_Fecha_Nac_Empleado
    JOIN MEGA_DB.[Local] lo ON lo.nombre = m.Local_Nombre_Local
    WHERE m.Compra_Nro_Compra IS NOT NULL;

    --Cada fila de la Maestra con compra es un renglon del detalle. La Maestra no trae subtotal
    --de compra, por eso no se guarda (se obtiene como cantidad * precio_unitario)
    INSERT INTO MEGA_DB.Compra_Detalle (compra_id, producto_id, cantidad, precio_unitario)
    SELECT c.compra_id, pr.producto_id, m.Detalle_Compra_Cantidad_Prod_Compra,
           m.Detalle_Compra_Precio_Unitario_Prod_Compra
    FROM gd_esquema.Maestra m
    JOIN MEGA_DB.Compra c ON c.nro_compra = m.Compra_Nro_Compra
    JOIN MEGA_DB.Producto pr ON pr.cod_producto = m.Producto_Cod_Producto
    WHERE m.Compra_Nro_Compra IS NOT NULL;
END
GO

--Migra las reparaciones y los repuestos usados en cada una
CREATE PROCEDURE MEGA_DB.sp_Migrar_Reparaciones
AS
BEGIN
    --Evita los mensajes de "filas afectadas"
    SET NOCOUNT ON;
    --Reparaciones: una por nro de reparacion, con cliente, empleado, local,
    --modelo de la bici y estado
    INSERT INTO MEGA_DB.Reparacion (nro_reparacion, cliente_id, empleado_id, local_id, modelo_bicicleta_id,
                                    estado_reparacion_id, numero_serie_bici, fecha_ingreso, fecha_entrega_estimada,
                                    fecha_entrega_real, diagnostico, precio_mano_obra, precio_repuestos, precio_total)
    SELECT DISTINCT m.Reparacion_Nro_Reparacion, pc.persona_id, pe.persona_id, lo.local_id, mb.modelo_bicicleta_id,
                    er.estado_reparacion_id, m.Reparacion_Numero_Serie_Bici_Reparacion,
                    m.Reparacion_Fecha_Ingreso_Reparacion, m.Reparacion_Fecha_Entrega_Estimada_Reparacion,
                    m.Reparacion_Fecha_Entrega_Real_Reparacion, m.Reparacion_Diagnostico_Reparacion,
                    m.Reparacion_Precio_Mano_Obra_Reparacion, m.Reparacion_Precio_Repuestos_Reparacion,
                    m.Reparacion_Precio_Total_Reparacion
    FROM gd_esquema.Maestra m
    JOIN MEGA_DB.Persona pc ON pc.dni = m.Cliente_Dni_Cliente
                           AND pc.nombre = m.Cliente_Nombre_Cliente
                           AND pc.apellido = m.Cliente_Apellido_Cliente
                           AND pc.fecha_nacimiento = m.Cliente_Fecha_Nacimiento_Cliente
    JOIN MEGA_DB.Persona pe ON pe.dni = m.Empleado_Dni_Empleado
                           AND pe.nombre = m.Empleado_Nombre_Empleado
                           AND pe.apellido = m.Empleado_Apellido_Empleado
                           AND pe.fecha_nacimiento = m.Empleado_Fecha_Nac_Empleado
    JOIN MEGA_DB.[Local] lo ON lo.nombre = m.Local_Nombre_Local
    JOIN MEGA_DB.Modelo_Bicicleta mb ON mb.modelo = m.Modelo_Bicicleta_Modelo_Bicicleta
                                    AND mb.rodado = m.Modelo_Bicicleta_Rodado_Modelo_Bicicleta
                                    AND mb.cuadro = m.Modelo_Bicicleta_Cuadro_Modelo_Bicicleta
                                    AND mb.color = m.Modelo_Bicicleta_Color_Modelo_Bicicleta
    JOIN MEGA_DB.Estado_Reparacion er ON er.descripcion = m.Estado_Reparacion_Estado_Reparacion
    WHERE m.Reparacion_Nro_Reparacion IS NOT NULL;

    --Repuestos de cada reparacion: cada fila de la Maestra con reparacion y repuesto
    --es un renglon (se migran todos porque suman al precio de repuestos)
    INSERT INTO MEGA_DB.Reparacion_Repuesto (reparacion_id, repuesto_id, cantidad, precio_unitario, subtotal)
    SELECT r.reparacion_id, rp.repuesto_id, m.Detalle_Reparacion_Cantidad_Repuesto,
           m.Detalle_Reparacion_Precio_Unitario_Repuesto, m.Detalle_Reparacion_Subtotal_Repuesto
    FROM gd_esquema.Maestra m
    JOIN MEGA_DB.Reparacion r ON r.nro_reparacion = m.Reparacion_Nro_Reparacion
    JOIN MEGA_DB.Repuesto rp ON rp.cod_repuesto = m.Repuesto_Cod_Repuesto
    WHERE m.Reparacion_Nro_Reparacion IS NOT NULL;
END
GO

/* =====================================================================
   3. VISTA DE CONTROL DE LA MIGRACION
   ===================================================================== */

--Compara, para cada tabla principal, la cantidad esperada segun la Maestra
--con la cantidad realmente migrada. estado = 'OK' si coinciden
CREATE VIEW MEGA_DB.vw_Estado_Migracion
AS
SELECT entidad, esperado, actual,
        CASE WHEN esperado = actual THEN 'OK' ELSE 'REVISAR' END AS estado
FROM (
    --Personas distintas entre clientes y empleados (clave completa)
    SELECT 'Persona' AS entidad,
            (SELECT COUNT(*) FROM (
                SELECT Cliente_Dni_Cliente, Cliente_Nombre_Cliente, Cliente_Apellido_Cliente, Cliente_Fecha_Nacimiento_Cliente
                FROM gd_esquema.Maestra WHERE Cliente_Dni_Cliente IS NOT NULL
                UNION
                SELECT Empleado_Dni_Empleado, Empleado_Nombre_Empleado, Empleado_Apellido_Empleado, Empleado_Fecha_Nac_Empleado
                FROM gd_esquema.Maestra WHERE Empleado_Dni_Empleado IS NOT NULL) x) AS esperado,
            (SELECT COUNT(*) FROM MEGA_DB.Persona) AS actual
    UNION ALL
    --Clientes distintos
    SELECT 'Cliente',
            (SELECT COUNT(*) FROM (
                SELECT Cliente_Dni_Cliente, Cliente_Nombre_Cliente, Cliente_Apellido_Cliente, Cliente_Fecha_Nacimiento_Cliente
                FROM gd_esquema.Maestra WHERE Cliente_Dni_Cliente IS NOT NULL
                GROUP BY Cliente_Dni_Cliente, Cliente_Nombre_Cliente, Cliente_Apellido_Cliente, Cliente_Fecha_Nacimiento_Cliente) x),
            (SELECT COUNT(*) FROM MEGA_DB.Cliente)
    UNION ALL
    --Empleados distintos
    SELECT 'Empleado',
            (SELECT COUNT(*) FROM (
                SELECT Empleado_Dni_Empleado
                FROM gd_esquema.Maestra WHERE Empleado_Dni_Empleado IS NOT NULL
                GROUP BY Empleado_Dni_Empleado) x),
            (SELECT COUNT(*) FROM MEGA_DB.Empleado)
    UNION ALL
    --Ventas distintas
    SELECT 'Venta',
            (SELECT COUNT(DISTINCT Venta_Nro_Venta) FROM gd_esquema.Maestra WHERE Venta_Nro_Venta IS NOT NULL),
            (SELECT COUNT(*) FROM MEGA_DB.Venta)
    UNION ALL
    --Renglones de venta: una fila de la Maestra por renglon
    SELECT 'Venta_Detalle',
            (SELECT COUNT(*) FROM gd_esquema.Maestra WHERE Venta_Nro_Venta IS NOT NULL),
            (SELECT COUNT(*) FROM MEGA_DB.Venta_Detalle)
    UNION ALL
    --Alquileres distintos
    SELECT 'Alquiler',
            (SELECT COUNT(DISTINCT Alquiler_Nro_Alquiler) FROM gd_esquema.Maestra WHERE Alquiler_Nro_Alquiler IS NOT NULL),
            (SELECT COUNT(*) FROM MEGA_DB.Alquiler)
    UNION ALL
    --Bicicletas de alquiler distintas
    SELECT 'Bicicleta_Alquiler',
            (SELECT COUNT(DISTINCT Bicicleta_Alquiler_Nro_Serie_Bici_Alquiler) FROM gd_esquema.Maestra
            WHERE Bicicleta_Alquiler_Nro_Serie_Bici_Alquiler IS NOT NULL),
            (SELECT COUNT(*) FROM MEGA_DB.Bicicleta_Alquiler)
    UNION ALL
    --Reparaciones distintas
    SELECT 'Reparacion',
            (SELECT COUNT(DISTINCT Reparacion_Nro_Reparacion) FROM gd_esquema.Maestra WHERE Reparacion_Nro_Reparacion IS NOT NULL),
            (SELECT COUNT(*) FROM MEGA_DB.Reparacion)
    UNION ALL
    --Repuestos usados: una fila de la Maestra por renglon
    SELECT 'Reparacion_Repuesto',
            (SELECT COUNT(*) FROM gd_esquema.Maestra
            WHERE Reparacion_Nro_Reparacion IS NOT NULL AND Repuesto_Cod_Repuesto IS NOT NULL),
            (SELECT COUNT(*) FROM MEGA_DB.Reparacion_Repuesto)
    UNION ALL
    --Compras distintas
    SELECT 'Compra',
            (SELECT COUNT(DISTINCT Compra_Nro_Compra) FROM gd_esquema.Maestra WHERE Compra_Nro_Compra IS NOT NULL),
            (SELECT COUNT(*) FROM MEGA_DB.Compra)
    UNION ALL
    --Renglones de compra: una fila de la Maestra por renglon
    SELECT 'Compra_Detalle',
            (SELECT COUNT(*) FROM gd_esquema.Maestra
            WHERE Compra_Nro_Compra IS NOT NULL AND Producto_Cod_Producto IS NOT NULL),
            (SELECT COUNT(*) FROM MEGA_DB.Compra_Detalle)
    UNION ALL
    --Productos distintos
    SELECT 'Producto',
            (SELECT COUNT(DISTINCT Producto_Cod_Producto) FROM gd_esquema.Maestra WHERE Producto_Cod_Producto IS NOT NULL),
            (SELECT COUNT(*) FROM MEGA_DB.Producto)
    UNION ALL
    --Repuestos distintos
    SELECT 'Repuesto',
            (SELECT COUNT(DISTINCT Repuesto_Cod_Repuesto) FROM gd_esquema.Maestra WHERE Repuesto_Cod_Repuesto IS NOT NULL),
            (SELECT COUNT(*) FROM MEGA_DB.Repuesto)
    UNION ALL
    --Proveedores distintos
    SELECT 'Proveedor',
            (SELECT COUNT(DISTINCT Proveedor_Cuit_Proveedor) FROM gd_esquema.Maestra WHERE Proveedor_Cuit_Proveedor IS NOT NULL),
            (SELECT COUNT(*) FROM MEGA_DB.Proveedor)
    UNION ALL
    --Locales distintos
    SELECT 'Local',
            (SELECT COUNT(DISTINCT Local_Nombre_Local) FROM gd_esquema.Maestra WHERE Local_Nombre_Local IS NOT NULL),
            (SELECT COUNT(*) FROM MEGA_DB.[Local])
) v
GO

--Mensaje de control
PRINT 'Stored Procedures creados correctamente';
GO

/* =====================================================================
   4. EJECUCION DE LA MIGRACION
   ===================================================================== */

--Se ejecuta toda la migracion en una unica transaccion: si algun SP falla, se deshace todo
--y se muestra el error original, para no dejar la base cargada a medias
BEGIN TRY
    --Inicio de la transaccion
    BEGIN TRAN
        --Los SPs se ejecutan en orden de dependencias
        EXEC MEGA_DB.sp_Migrar_Ubicaciones
        EXEC MEGA_DB.sp_Migrar_Locales
        EXEC MEGA_DB.sp_Migrar_Enums
        EXEC MEGA_DB.sp_Migrar_Personas
        EXEC MEGA_DB.sp_Migrar_Productos
        EXEC MEGA_DB.sp_Migrar_Alquileres
        EXEC MEGA_DB.sp_Migrar_Ventas
        EXEC MEGA_DB.sp_Migrar_Compras
        EXEC MEGA_DB.sp_Migrar_Reparaciones
    --Si todos los SPs terminaron bien se confirman los cambios
    COMMIT TRAN

    --Muestra el control de cantidades de la migracion
    SELECT * FROM MEGA_DB.vw_Estado_Migracion
END TRY
BEGIN CATCH
    --Si quedo una transaccion abierta se deshace
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;
    --Se relanza el error original para que se vea en la ejecucion
    THROW;
END CATCH
GO

/* =====================================================================
   5. INDICES
   Se crean despues de la migracion para que la carga sea mas rapida.
   Apuntan a las FKs y columnas de fecha por las que se filtra y agrupa
   en las consultas por local, periodo, producto y bicicleta.
   ===================================================================== */

--Ventas por local y fecha (incluye total y cliente para no ir a la tabla)
CREATE NONCLUSTERED INDEX IX_Venta_Local_Fecha
ON MEGA_DB.Venta (local_id, fecha_venta)
INCLUDE (total, cliente_id)
GO

--Ventas de un cliente
CREATE NONCLUSTERED INDEX IX_Venta_Cliente
ON MEGA_DB.Venta (cliente_id)
GO

--Renglones de una venta
CREATE NONCLUSTERED INDEX IX_Venta_Detalle_Venta
ON MEGA_DB.Venta_Detalle (venta_id)
INCLUDE (producto_id, cantidad, subtotal)
GO

--Ventas de un producto
CREATE NONCLUSTERED INDEX IX_Venta_Detalle_Producto
ON MEGA_DB.Venta_Detalle (producto_id)
GO

--Alquileres de una bici por fecha (tambien lo usa el trigger de superposicion)
CREATE NONCLUSTERED INDEX IX_Alquiler_Bicicleta_Fecha
ON MEGA_DB.Alquiler (bicicleta_alquiler_id, fecha_inicio)
INCLUDE (fecha_devolucion_real, importe_total)
GO

--Bicicletas de alquiler de un local
CREATE NONCLUSTERED INDEX IX_Bicicleta_Alquiler_Local
ON MEGA_DB.Bicicleta_Alquiler (local_id)
GO

--Bicicletas de alquiler de un modelo
CREATE NONCLUSTERED INDEX IX_Bicicleta_Alquiler_Modelo
ON MEGA_DB.Bicicleta_Alquiler (modelo_bicicleta_id)
GO

--Reparaciones por local y fecha de ingreso (incluye fechas y precios)
CREATE NONCLUSTERED INDEX IX_Reparacion_Local_Ingreso
ON MEGA_DB.Reparacion (local_id, fecha_ingreso)
INCLUDE (fecha_entrega_estimada,
         fecha_entrega_real,
         precio_mano_obra,
         precio_repuestos,
         precio_total)
GO

--Repuestos de una reparacion
CREATE NONCLUSTERED INDEX IX_Reparacion_Repuesto_Reparacion
ON MEGA_DB.Reparacion_Repuesto (reparacion_id)
INCLUDE (repuesto_id, cantidad, subtotal)
GO

--Reparaciones en las que se uso un repuesto
CREATE NONCLUSTERED INDEX IX_Reparacion_Repuesto_Repuesto
ON MEGA_DB.Reparacion_Repuesto (repuesto_id)
GO

--Compras por local y fecha (incluye el total)
CREATE NONCLUSTERED INDEX IX_Compra_Local_Fecha
ON MEGA_DB.Compra (local_id, fecha_compra)
INCLUDE (total)
GO

--Renglones de una compra
CREATE NONCLUSTERED INDEX IX_Compra_Detalle_Compra
ON MEGA_DB.Compra_Detalle (compra_id)
INCLUDE (producto_id, cantidad)
GO

--Compras de un producto
CREATE NONCLUSTERED INDEX IX_Compra_Detalle_Producto
ON MEGA_DB.Compra_Detalle (producto_id)
GO

--Productos de un tipo
CREATE NONCLUSTERED INDEX IX_Producto_Tipo
ON MEGA_DB.Producto (tipo_producto_id)
GO

--Modelos de una categoria de bicicleta
CREATE NONCLUSTERED INDEX IX_Modelo_Bicicleta_Categoria
ON MEGA_DB.Modelo_Bicicleta (categoria_bicicleta_id)
GO

--Repuestos de una categoria
CREATE NONCLUSTERED INDEX IX_Repuesto_Categoria
ON MEGA_DB.Repuesto (categoria_repuesto_id)
GO

--Mensaje de control
PRINT 'Indices creados correctamente';
GO

/* =====================================================================
   6. TRIGGERS
   ===================================================================== */

--Una misma bicicleta nunca puede estar alquilada a dos clientes al mismo tiempo.
--Se crea despues de la migracion porque la Maestra ya trae alquileres superpuestos
--(inconsistencia de origen documentada): el trigger controla los alquileres nuevos.
--Si no hay devolucion real, se toma como fin del alquiler la devolucion pactada.
CREATE TRIGGER MEGA_DB.tr_Alquiler_Sin_Superposicion
ON MEGA_DB.Alquiler
AFTER INSERT
AS
BEGIN
    --Evita los mensajes de "filas afectadas"
    SET NOCOUNT ON;

    --Busca otro alquiler de la misma bici cuyo rango de fechas se pise con el insertado
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN MEGA_DB.Alquiler a ON a.bicicleta_alquiler_id = i.bicicleta_alquiler_id
                               AND a.alquiler_id <> i.alquiler_id
        WHERE i.fecha_inicio < ISNULL(a.fecha_devolucion_real, a.fecha_devolucion_pactada)
          AND a.fecha_inicio < ISNULL(i.fecha_devolucion_real, i.fecha_devolucion_pactada)
    )
        --Si hay superposicion se cancela el insert (el error deshace la sentencia)
        THROW 50001, 'La bicicleta ya tiene un alquiler en ese rango de fechas', 1;
END
GO

--Mensaje de control
PRINT 'Triggers creados correctamente';
GO
