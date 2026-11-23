/* =====================================================================
   PRUEBAS INTEGRALES DE INSERTS - MEGA_DB
   TP GDD 2C 2026

   Objetivo:
   - Probar las 29 tablas del modelo.
   - Verificar INSERTs válidos.
   - Verificar UNIQUE, FK, NOT NULL, CHECK y el trigger de Alquiler.
   - No dejar datos de prueba al terminar.

   Lectura del resultado:
   - OK - INSERTADO  : el caso debía insertar y lo hizo.
   - OK - RECHAZADO  : el caso debía fallar y fue rechazado.
   - FALLO - ...     : el comportamiento real no coincide con lo esperado.

   IMPORTANTE:
   Los datos de prueba usan prefijos ZZ_TEST / ZZ_PROD / ZZ_REP y números
   cercanos a 2147000000 para minimizar cualquier colisión con datos reales.
   ===================================================================== */

USE GD2C_2026;
GO

SET NOCOUNT ON;
SET XACT_ABORT OFF;

IF OBJECT_ID('tempdb..#Pruebas') IS NOT NULL DROP TABLE #Pruebas;
IF OBJECT_ID('tempdb..#Resultados') IS NOT NULL DROP TABLE #Resultados;

CREATE TABLE #Pruebas (
    caso INT IDENTITY(1,1) PRIMARY KEY,
    tabla SYSNAME NOT NULL,
    descripcion VARCHAR(300) NOT NULL,
    esperado VARCHAR(10) NOT NULL,
    sql_prueba NVARCHAR(MAX) NOT NULL,
    sql_cleanup NVARCHAR(MAX) NULL
);

CREATE TABLE #Resultados (
    caso INT NOT NULL,
    tabla SYSNAME NOT NULL,
    descripcion VARCHAR(300) NOT NULL,
    esperado VARCHAR(10) NOT NULL,
    resultado VARCHAR(30) NOT NULL,
    detalle NVARCHAR(4000) NULL
);

PRINT 'Limpiando restos de una ejecucion anterior...';
BEGIN TRY

    -- Detalles dependientes

    DELETE cd

    FROM MEGA_DB.Compra_Detalle cd

    JOIN MEGA_DB.Compra c ON c.compra_id = cd.compra_id

    WHERE c.nro_compra BETWEEN 2147000400 AND 2147000499;

    

    DELETE rr

    FROM MEGA_DB.Reparacion_Repuesto rr

    JOIN MEGA_DB.Reparacion r ON r.reparacion_id = rr.reparacion_id

    WHERE r.nro_reparacion BETWEEN 2147000300 AND 2147000399;

    

    DELETE vd

    FROM MEGA_DB.Venta_Detalle vd

    JOIN MEGA_DB.Venta v ON v.venta_id = vd.venta_id

    WHERE v.nro_venta BETWEEN 2147000100 AND 2147000199;

    

    -- Cabeceras

    DELETE FROM MEGA_DB.Compra

    WHERE nro_compra BETWEEN 2147000400 AND 2147000499;

    

    DELETE FROM MEGA_DB.Reparacion

    WHERE nro_reparacion BETWEEN 2147000300 AND 2147000399;

    

    DELETE FROM MEGA_DB.Alquiler

    WHERE nro_alquiler BETWEEN 2147000200 AND 2147000299;

    

    DELETE FROM MEGA_DB.Venta

    WHERE nro_venta BETWEEN 2147000100 AND 2147000199;

    

    -- Proveedores / repuestos / flota

    DELETE FROM MEGA_DB.Proveedor WHERE cuit LIKE 'ZZ-CUIT-%';

    

    DELETE FROM MEGA_DB.Repuesto WHERE cod_repuesto LIKE 'ZZ_REP_%';

    DELETE FROM MEGA_DB.Categoria_Repuesto WHERE descripcion LIKE 'ZZ_TEST_CAT_REP%';

    DELETE FROM MEGA_DB.Estado_Reparacion WHERE descripcion LIKE 'ZZ_TEST_ESTADO_REP%';

    

    DELETE FROM MEGA_DB.Bicicleta_Alquiler WHERE nro_serie LIKE 'ZZ_BICI_ALQ_%';

    DELETE FROM MEGA_DB.Estado_Alquiler WHERE descripcion LIKE 'ZZ_TEST_ESTADO_ALQ%';

    DELETE FROM MEGA_DB.Estado_Bicicleta_Alquiler WHERE descripcion LIKE 'ZZ_TEST_ESTADO_BICI%';

    

    -- Productos y subtipos

    DELETE a

    FROM MEGA_DB.Accesorio a

    JOIN MEGA_DB.Producto p ON p.producto_id = a.producto_id

    WHERE p.cod_producto LIKE 'ZZ_PROD_%';

    

    DELETE bv

    FROM MEGA_DB.Bicicleta_Venta bv

    JOIN MEGA_DB.Producto p ON p.producto_id = bv.producto_id

    WHERE p.cod_producto LIKE 'ZZ_PROD_%';

    

    DELETE FROM MEGA_DB.Producto WHERE cod_producto LIKE 'ZZ_PROD_%';

    DELETE FROM MEGA_DB.Categoria_Accesorio WHERE descripcion LIKE 'ZZ_TEST_CAT_ACC%';

    DELETE FROM MEGA_DB.Tipo_Producto WHERE descripcion LIKE 'ZZ_TEST_TIPO_%';

    

    DELETE FROM MEGA_DB.Modelo_Bicicleta WHERE modelo LIKE 'ZZ_TEST_MODELO%';

    DELETE FROM MEGA_DB.Categoria_Bicicleta WHERE descripcion LIKE 'ZZ_TEST_CAT_BICI%';

    DELETE FROM MEGA_DB.Marca WHERE nombre LIKE 'ZZ_TEST_MARCA%';

    

    DELETE FROM MEGA_DB.Forma_Pago WHERE descripcion LIKE 'ZZ_TEST_FORMA_PAGO%';

    

    -- Personas / locales / ubicaciones

    DELETE e

    FROM MEGA_DB.Empleado e

    JOIN MEGA_DB.Persona p ON p.persona_id = e.persona_id

    WHERE p.dni LIKE 'ZZTEST-DNI-%';

    

    DELETE c

    FROM MEGA_DB.Cliente c

    JOIN MEGA_DB.Persona p ON p.persona_id = c.persona_id

    WHERE p.dni LIKE 'ZZTEST-DNI-%';

    

    DELETE FROM MEGA_DB.Persona WHERE dni LIKE 'ZZTEST-DNI-%';

    DELETE FROM MEGA_DB.[Local] WHERE nombre LIKE 'ZZ_TEST_LOCAL%';

    

    DELETE l

    FROM MEGA_DB.Localidad l

    JOIN MEGA_DB.Provincia p ON p.provincia_id = l.provincia_id

    WHERE l.nombre LIKE 'ZZ_TEST_LOCALIDAD%' OR p.nombre LIKE 'ZZ_TEST_PROV_%';

    

    DELETE FROM MEGA_DB.Provincia WHERE nombre LIKE 'ZZ_TEST_PROV_%';

END TRY
BEGIN CATCH
    PRINT 'Aviso: no se pudo completar la limpieza inicial: ' + ERROR_MESSAGE();
END CATCH;

PRINT 'Cargando casos de prueba...';

INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Provincia',
    N'Provincia de prueba A',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Provincia(nombre) VALUES (''ZZ_TEST_PROV_A'');',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Provincia',
    N'Provincia de prueba B',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Provincia(nombre) VALUES (''ZZ_TEST_PROV_B'');',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Provincia',
    N'Provincia duplicada',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Provincia(nombre) VALUES (''ZZ_TEST_PROV_A'');',
    N'DELETE FROM MEGA_DB.Provincia WHERE nombre = ''ZZ_TEST_PROV_A'' AND provincia_id <> (SELECT MIN(provincia_id) FROM MEGA_DB.Provincia WHERE nombre = ''ZZ_TEST_PROV_A'');'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Localidad',
    N'Mismo nombre de localidad en provincia A',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Localidad(provincia_id,nombre)
       VALUES ((SELECT provincia_id FROM MEGA_DB.Provincia WHERE nombre=''ZZ_TEST_PROV_A''),''ZZ_TEST_LOCALIDAD'');',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Localidad',
    N'Mismo nombre de localidad en provincia B',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Localidad(provincia_id,nombre)
       VALUES ((SELECT provincia_id FROM MEGA_DB.Provincia WHERE nombre=''ZZ_TEST_PROV_B''),''ZZ_TEST_LOCALIDAD'');',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Localidad',
    N'Localidad duplicada dentro de la misma provincia',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Localidad(provincia_id,nombre)
       VALUES ((SELECT provincia_id FROM MEGA_DB.Provincia WHERE nombre=''ZZ_TEST_PROV_A''),''ZZ_TEST_LOCALIDAD'');',
    N'DELETE l FROM MEGA_DB.Localidad l
JOIN MEGA_DB.Provincia p ON p.provincia_id=l.provincia_id
WHERE l.nombre=''ZZ_TEST_LOCALIDAD'' AND p.nombre=''ZZ_TEST_PROV_A''
  AND l.localidad_id<>(SELECT MIN(l2.localidad_id) FROM MEGA_DB.Localidad l2 WHERE l2.provincia_id=l.provincia_id AND l2.nombre=l.nombre);'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Localidad',
    N'FK a provincia inexistente',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Localidad(provincia_id,nombre) VALUES (-999999,''ZZ_TEST_LOCALIDAD_FK'');',
    N'DELETE FROM MEGA_DB.Localidad WHERE nombre=''ZZ_TEST_LOCALIDAD_FK'';'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Persona',
    N'Persona cliente válida',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Persona(localidad_id,nombre,apellido,dni,telefono,email,direccion,fecha_nacimiento)
       VALUES ((SELECT l.localidad_id FROM MEGA_DB.Localidad l JOIN MEGA_DB.Provincia p ON p.provincia_id=l.provincia_id
                WHERE l.nombre=''ZZ_TEST_LOCALIDAD'' AND p.nombre=''ZZ_TEST_PROV_A''),
               ''Cliente'',''Prueba'',''ZZTEST-DNI-1'',''1111'',''cliente@test.local'',''Calle Test 1'',''1990-01-01'');',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Persona',
    N'Persona empleado válida',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Persona(localidad_id,nombre,apellido,dni,telefono,email,direccion,fecha_nacimiento)
       VALUES ((SELECT l.localidad_id FROM MEGA_DB.Localidad l JOIN MEGA_DB.Provincia p ON p.provincia_id=l.provincia_id
                WHERE l.nombre=''ZZ_TEST_LOCALIDAD'' AND p.nombre=''ZZ_TEST_PROV_A''),
               ''Empleado'',''Prueba'',''ZZTEST-DNI-2'',''2222'',''empleado@test.local'',''Calle Test 2'',''1991-02-02'');',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Persona',
    N'Mismo DNI pero distinta identidad',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Persona(localidad_id,nombre,apellido,dni,telefono,email,direccion,fecha_nacimiento)
       VALUES ((SELECT l.localidad_id FROM MEGA_DB.Localidad l JOIN MEGA_DB.Provincia p ON p.provincia_id=l.provincia_id
                WHERE l.nombre=''ZZ_TEST_LOCALIDAD'' AND p.nombre=''ZZ_TEST_PROV_A''),
               ''Otra'',''Persona'',''ZZTEST-DNI-1'',NULL,NULL,''Calle Test 3'',''1992-03-03'');',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Persona',
    N'Duplicado exacto de la clave de negocio',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Persona(localidad_id,nombre,apellido,dni,telefono,email,direccion,fecha_nacimiento)
       VALUES ((SELECT l.localidad_id FROM MEGA_DB.Localidad l JOIN MEGA_DB.Provincia p ON p.provincia_id=l.provincia_id
                WHERE l.nombre=''ZZ_TEST_LOCALIDAD'' AND p.nombre=''ZZ_TEST_PROV_A''),
               ''Cliente'',''Prueba'',''ZZTEST-DNI-1'',NULL,NULL,''Otra direccion'',''1990-01-01'');',
    N'DELETE FROM MEGA_DB.Persona
WHERE dni=''ZZTEST-DNI-1'' AND nombre=''Cliente'' AND apellido=''Prueba'' AND fecha_nacimiento=''1990-01-01''
  AND persona_id<>(SELECT MIN(persona_id) FROM MEGA_DB.Persona
                  WHERE dni=''ZZTEST-DNI-1'' AND nombre=''Cliente'' AND apellido=''Prueba'' AND fecha_nacimiento=''1990-01-01'');'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Persona',
    N'Campo obligatorio direccion en NULL',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Persona(localidad_id,nombre,apellido,dni,direccion,fecha_nacimiento)
       VALUES ((SELECT l.localidad_id FROM MEGA_DB.Localidad l JOIN MEGA_DB.Provincia p ON p.provincia_id=l.provincia_id
                WHERE l.nombre=''ZZ_TEST_LOCALIDAD'' AND p.nombre=''ZZ_TEST_PROV_A''),
               ''Null'',''Direccion'',''ZZTEST-DNI-NULL'',NULL,''1993-01-01'');',
    N'DELETE FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-NULL'';'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Local',
    N'Local válido',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.[Local](localidad_id,nombre,telefono,email,direccion)
       VALUES ((SELECT l.localidad_id FROM MEGA_DB.Localidad l JOIN MEGA_DB.Provincia p ON p.provincia_id=l.provincia_id
                WHERE l.nombre=''ZZ_TEST_LOCALIDAD'' AND p.nombre=''ZZ_TEST_PROV_A''),
               ''ZZ_TEST_LOCAL'',''3333'',''local@test.local'',''Av Test 100'');',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Local',
    N'Nombre de local duplicado',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.[Local](localidad_id,nombre,direccion)
       VALUES ((SELECT l.localidad_id FROM MEGA_DB.Localidad l JOIN MEGA_DB.Provincia p ON p.provincia_id=l.provincia_id
                WHERE l.nombre=''ZZ_TEST_LOCALIDAD'' AND p.nombre=''ZZ_TEST_PROV_B''),
               ''ZZ_TEST_LOCAL'',''Otra direccion'');',
    N'DELETE FROM MEGA_DB.[Local]
WHERE nombre=''ZZ_TEST_LOCAL''
  AND local_id<>(SELECT MIN(local_id) FROM MEGA_DB.[Local] WHERE nombre=''ZZ_TEST_LOCAL'');'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Cliente',
    N'Alta de Cliente desde Persona',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Cliente(persona_id) VALUES ((SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-1'' AND nombre=''Cliente''));',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Cliente',
    N'Cliente con Persona inexistente',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Cliente(persona_id) VALUES (-999999);',
    N'DELETE FROM MEGA_DB.Cliente WHERE persona_id=-999999;'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Empleado',
    N'Alta de Empleado desde Persona',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Empleado(persona_id,local_id,puesto,fecha_ingreso)
       VALUES ((SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-2''),
               (SELECT local_id FROM MEGA_DB.[Local] WHERE nombre=''ZZ_TEST_LOCAL''),
               ''Vendedor'',''2026-01-01'');',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Empleado',
    N'Empleado con local inexistente',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Empleado(persona_id,local_id,puesto,fecha_ingreso)
       VALUES ((SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-1'' AND nombre=''Otra''),
               -999999,''Prueba'',''2026-01-01'');',
    N'DELETE FROM MEGA_DB.Empleado
       WHERE persona_id=(SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-1'' AND nombre=''Otra'');'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Marca',
    N'Marca válida',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Marca(nombre) VALUES (''ZZ_TEST_MARCA'');',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Marca',
    N'Marca duplicada',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Marca(nombre) VALUES (''ZZ_TEST_MARCA'');',
    N'DELETE FROM MEGA_DB.Marca WHERE nombre=''ZZ_TEST_MARCA''
AND marca_id<>(SELECT MIN(marca_id) FROM MEGA_DB.Marca WHERE nombre=''ZZ_TEST_MARCA'');'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Categoria_Bicicleta',
    N'Categoría de bicicleta válida',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Categoria_Bicicleta(descripcion) VALUES (''ZZ_TEST_CAT_BICI'');',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Categoria_Bicicleta',
    N'Categoría de bicicleta duplicada',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Categoria_Bicicleta(descripcion) VALUES (''ZZ_TEST_CAT_BICI'');',
    N'DELETE FROM MEGA_DB.Categoria_Bicicleta WHERE descripcion=''ZZ_TEST_CAT_BICI''
AND categoria_bicicleta_id<>(SELECT MIN(categoria_bicicleta_id) FROM MEGA_DB.Categoria_Bicicleta WHERE descripcion=''ZZ_TEST_CAT_BICI'');'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Modelo_Bicicleta',
    N'Modelo de bicicleta válido',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Modelo_Bicicleta(marca_id,categoria_bicicleta_id,modelo,rodado,cuadro,color)
       VALUES ((SELECT marca_id FROM MEGA_DB.Marca WHERE nombre=''ZZ_TEST_MARCA''),
               (SELECT categoria_bicicleta_id FROM MEGA_DB.Categoria_Bicicleta WHERE descripcion=''ZZ_TEST_CAT_BICI''),
               ''ZZ_TEST_MODELO'',''29'',''M'',''Azul'');',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Modelo_Bicicleta',
    N'Modelo duplicado por modelo+rodado+cuadro+color',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Modelo_Bicicleta(marca_id,categoria_bicicleta_id,modelo,rodado,cuadro,color)
       VALUES ((SELECT marca_id FROM MEGA_DB.Marca WHERE nombre=''ZZ_TEST_MARCA''),
               (SELECT categoria_bicicleta_id FROM MEGA_DB.Categoria_Bicicleta WHERE descripcion=''ZZ_TEST_CAT_BICI''),
               ''ZZ_TEST_MODELO'',''29'',''M'',''Azul'');',
    N'DELETE FROM MEGA_DB.Modelo_Bicicleta WHERE modelo=''ZZ_TEST_MODELO'' AND rodado=''29'' AND cuadro=''M'' AND color=''Azul''
AND modelo_bicicleta_id<>(SELECT MIN(modelo_bicicleta_id) FROM MEGA_DB.Modelo_Bicicleta
                          WHERE modelo=''ZZ_TEST_MODELO'' AND rodado=''29'' AND cuadro=''M'' AND color=''Azul'');'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Tipo_Producto',
    N'Tipo bicicleta válido',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Tipo_Producto(descripcion) VALUES (''ZZ_TEST_TIPO_BICI'');',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Tipo_Producto',
    N'Tipo accesorio válido',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Tipo_Producto(descripcion) VALUES (''ZZ_TEST_TIPO_ACC'');',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Tipo_Producto',
    N'Tipo de producto duplicado',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Tipo_Producto(descripcion) VALUES (''ZZ_TEST_TIPO_BICI'');',
    N'DELETE FROM MEGA_DB.Tipo_Producto WHERE descripcion=''ZZ_TEST_TIPO_BICI''
AND tipo_producto_id<>(SELECT MIN(tipo_producto_id) FROM MEGA_DB.Tipo_Producto WHERE descripcion=''ZZ_TEST_TIPO_BICI'');'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Producto',
    N'Producto bicicleta válido',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Producto(cod_producto,tipo_producto_id,nombre,descripcion,precio_venta)
       VALUES (''ZZ_PROD_BICI_1'',(SELECT tipo_producto_id FROM MEGA_DB.Tipo_Producto WHERE descripcion=''ZZ_TEST_TIPO_BICI''),
               ''Bicicleta Test'',''Producto para pruebas'',1000);',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Producto',
    N'Segundo producto bicicleta válido',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Producto(cod_producto,tipo_producto_id,nombre,descripcion,precio_venta)
       VALUES (''ZZ_PROD_BICI_2'',(SELECT tipo_producto_id FROM MEGA_DB.Tipo_Producto WHERE descripcion=''ZZ_TEST_TIPO_BICI''),
               ''Bicicleta Test 2'',NULL,1200);',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Producto',
    N'Producto accesorio válido',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Producto(cod_producto,tipo_producto_id,nombre,descripcion,precio_venta)
       VALUES (''ZZ_PROD_ACC_1'',(SELECT tipo_producto_id FROM MEGA_DB.Tipo_Producto WHERE descripcion=''ZZ_TEST_TIPO_ACC''),
               ''Accesorio Test'',''Accesorio para pruebas'',50);',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Producto',
    N'Precio de venta negativo',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Producto(cod_producto,tipo_producto_id,nombre,precio_venta)
       VALUES (''ZZ_PROD_NEG'',(SELECT tipo_producto_id FROM MEGA_DB.Tipo_Producto WHERE descripcion=''ZZ_TEST_TIPO_BICI''),
               ''Producto Negativo'',-1);',
    N'DELETE FROM MEGA_DB.Producto WHERE cod_producto=''ZZ_PROD_NEG'';'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Producto',
    N'Código de producto duplicado',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Producto(cod_producto,tipo_producto_id,nombre,precio_venta)
       VALUES (''ZZ_PROD_BICI_1'',(SELECT tipo_producto_id FROM MEGA_DB.Tipo_Producto WHERE descripcion=''ZZ_TEST_TIPO_BICI''),
               ''Duplicado'',1);',
    N'DELETE FROM MEGA_DB.Producto WHERE cod_producto=''ZZ_PROD_BICI_1''
AND producto_id<>(SELECT MIN(producto_id) FROM MEGA_DB.Producto WHERE cod_producto=''ZZ_PROD_BICI_1'');'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Bicicleta_Venta',
    N'Bicicleta de venta válida',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Bicicleta_Venta(producto_id,modelo_bicicleta_id,meses_garantia)
       VALUES ((SELECT producto_id FROM MEGA_DB.Producto WHERE cod_producto=''ZZ_PROD_BICI_1''),
               (SELECT modelo_bicicleta_id FROM MEGA_DB.Modelo_Bicicleta WHERE modelo=''ZZ_TEST_MODELO''),
               12);',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Bicicleta_Venta',
    N'Garantía negativa',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Bicicleta_Venta(producto_id,modelo_bicicleta_id,meses_garantia)
       VALUES ((SELECT producto_id FROM MEGA_DB.Producto WHERE cod_producto=''ZZ_PROD_BICI_2''),
               (SELECT modelo_bicicleta_id FROM MEGA_DB.Modelo_Bicicleta WHERE modelo=''ZZ_TEST_MODELO''),
               -1);',
    N'DELETE FROM MEGA_DB.Bicicleta_Venta
       WHERE producto_id=(SELECT producto_id FROM MEGA_DB.Producto WHERE cod_producto=''ZZ_PROD_BICI_2'');'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Categoria_Accesorio',
    N'Categoría de accesorio válida',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Categoria_Accesorio(descripcion) VALUES (''ZZ_TEST_CAT_ACC'');',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Categoria_Accesorio',
    N'Categoría de accesorio duplicada',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Categoria_Accesorio(descripcion) VALUES (''ZZ_TEST_CAT_ACC'');',
    N'DELETE FROM MEGA_DB.Categoria_Accesorio WHERE descripcion=''ZZ_TEST_CAT_ACC''
AND categoria_accesorio_id<>(SELECT MIN(categoria_accesorio_id) FROM MEGA_DB.Categoria_Accesorio WHERE descripcion=''ZZ_TEST_CAT_ACC'');'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Accesorio',
    N'Accesorio válido con talle NULL',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Accesorio(producto_id,marca_id,categoria_accesorio_id,talle,color)
       VALUES ((SELECT producto_id FROM MEGA_DB.Producto WHERE cod_producto=''ZZ_PROD_ACC_1''),
               (SELECT marca_id FROM MEGA_DB.Marca WHERE nombre=''ZZ_TEST_MARCA''),
               (SELECT categoria_accesorio_id FROM MEGA_DB.Categoria_Accesorio WHERE descripcion=''ZZ_TEST_CAT_ACC''),
               NULL,''Negro'');',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Accesorio',
    N'Accesorio con marca inexistente',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Accesorio(producto_id,marca_id,categoria_accesorio_id,talle,color)
       VALUES ((SELECT producto_id FROM MEGA_DB.Producto WHERE cod_producto=''ZZ_PROD_BICI_2''),
               -999999,
               (SELECT categoria_accesorio_id FROM MEGA_DB.Categoria_Accesorio WHERE descripcion=''ZZ_TEST_CAT_ACC''),
               ''M'',''Rojo'');',
    N'DELETE FROM MEGA_DB.Accesorio
       WHERE producto_id=(SELECT producto_id FROM MEGA_DB.Producto WHERE cod_producto=''ZZ_PROD_BICI_2'');'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Forma_Pago',
    N'Forma de pago válida',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Forma_Pago(descripcion) VALUES (''ZZ_TEST_FORMA_PAGO'');',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Forma_Pago',
    N'Forma de pago duplicada',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Forma_Pago(descripcion) VALUES (''ZZ_TEST_FORMA_PAGO'');',
    N'DELETE FROM MEGA_DB.Forma_Pago WHERE descripcion=''ZZ_TEST_FORMA_PAGO''
AND forma_pago_id<>(SELECT MIN(forma_pago_id) FROM MEGA_DB.Forma_Pago WHERE descripcion=''ZZ_TEST_FORMA_PAGO'');'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Venta',
    N'Venta válida',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Venta(nro_venta,local_id,cliente_id,empleado_id,forma_pago_id,fecha_venta,total)
       VALUES (2147000101,
               (SELECT local_id FROM MEGA_DB.[Local] WHERE nombre=''ZZ_TEST_LOCAL''),
               (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-1'' AND nombre=''Cliente''),
               (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-2''),
               (SELECT forma_pago_id FROM MEGA_DB.Forma_Pago WHERE descripcion=''ZZ_TEST_FORMA_PAGO''),
               ''2035-01-01T10:00:00'',1000);',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Venta',
    N'Número de venta duplicado',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Venta(nro_venta,local_id,cliente_id,empleado_id,forma_pago_id,fecha_venta,total)
       SELECT 2147000101,local_id,
              (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-1'' AND nombre=''Cliente''),
              (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-2''),
              (SELECT forma_pago_id FROM MEGA_DB.Forma_Pago WHERE descripcion=''ZZ_TEST_FORMA_PAGO''),
              ''2035-01-02'',1
       FROM MEGA_DB.[Local] WHERE nombre=''ZZ_TEST_LOCAL'';',
    N'DELETE FROM MEGA_DB.Venta WHERE nro_venta=2147000101
AND venta_id<>(SELECT MIN(venta_id) FROM MEGA_DB.Venta WHERE nro_venta=2147000101);'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Venta',
    N'Venta con cliente inexistente',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Venta(nro_venta,local_id,cliente_id,empleado_id,forma_pago_id,fecha_venta,total)
       VALUES (2147000199,
               (SELECT local_id FROM MEGA_DB.[Local] WHERE nombre=''ZZ_TEST_LOCAL''),
               -999999,
               (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-2''),
               (SELECT forma_pago_id FROM MEGA_DB.Forma_Pago WHERE descripcion=''ZZ_TEST_FORMA_PAGO''),
               ''2035-01-02'',1);',
    N'DELETE FROM MEGA_DB.Venta WHERE nro_venta=2147000199;'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Venta_Detalle',
    N'Detalle de venta válido',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Venta_Detalle(venta_id,producto_id,cantidad,precio_unitario,subtotal)
       VALUES ((SELECT venta_id FROM MEGA_DB.Venta WHERE nro_venta=2147000101),
               (SELECT producto_id FROM MEGA_DB.Producto WHERE cod_producto=''ZZ_PROD_BICI_1''),
               1,1000,1000);',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Venta_Detalle',
    N'Cantidad 0',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Venta_Detalle(venta_id,producto_id,cantidad,precio_unitario,subtotal)
       VALUES ((SELECT venta_id FROM MEGA_DB.Venta WHERE nro_venta=2147000101),
               (SELECT producto_id FROM MEGA_DB.Producto WHERE cod_producto=''ZZ_PROD_ACC_1''),
               0,50,0);',
    N'DELETE FROM MEGA_DB.Venta_Detalle
       WHERE venta_id=(SELECT venta_id FROM MEGA_DB.Venta WHERE nro_venta=2147000101)
         AND producto_id=(SELECT producto_id FROM MEGA_DB.Producto WHERE cod_producto=''ZZ_PROD_ACC_1'') AND cantidad=0;'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Venta_Detalle',
    N'Precio unitario negativo',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Venta_Detalle(venta_id,producto_id,cantidad,precio_unitario,subtotal)
       VALUES ((SELECT venta_id FROM MEGA_DB.Venta WHERE nro_venta=2147000101),
               (SELECT producto_id FROM MEGA_DB.Producto WHERE cod_producto=''ZZ_PROD_ACC_1''),
               1,-1,-1);',
    N'DELETE FROM MEGA_DB.Venta_Detalle
       WHERE venta_id=(SELECT venta_id FROM MEGA_DB.Venta WHERE nro_venta=2147000101)
         AND producto_id=(SELECT producto_id FROM MEGA_DB.Producto WHERE cod_producto=''ZZ_PROD_ACC_1'') AND precio_unitario=-1;'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Estado_Bicicleta_Alquiler',
    N'Estado de bicicleta válido',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Estado_Bicicleta_Alquiler(descripcion) VALUES (''ZZ_TEST_ESTADO_BICI'');',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Estado_Bicicleta_Alquiler',
    N'Estado de bicicleta duplicado',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Estado_Bicicleta_Alquiler(descripcion) VALUES (''ZZ_TEST_ESTADO_BICI'');',
    N'DELETE FROM MEGA_DB.Estado_Bicicleta_Alquiler WHERE descripcion=''ZZ_TEST_ESTADO_BICI''
AND estado_bicicleta_alquiler_id<>(SELECT MIN(estado_bicicleta_alquiler_id) FROM MEGA_DB.Estado_Bicicleta_Alquiler WHERE descripcion=''ZZ_TEST_ESTADO_BICI'');'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Bicicleta_Alquiler',
    N'Bicicleta de alquiler 1 válida',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Bicicleta_Alquiler(nro_serie,modelo_bicicleta_id,local_id,estado_bicicleta_alquiler_id,precio_hora,precio_dia)
       VALUES (''ZZ_BICI_ALQ_1'',
               (SELECT modelo_bicicleta_id FROM MEGA_DB.Modelo_Bicicleta WHERE modelo=''ZZ_TEST_MODELO''),
               (SELECT local_id FROM MEGA_DB.[Local] WHERE nombre=''ZZ_TEST_LOCAL''),
               (SELECT estado_bicicleta_alquiler_id FROM MEGA_DB.Estado_Bicicleta_Alquiler WHERE descripcion=''ZZ_TEST_ESTADO_BICI''),
               10,50);',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Bicicleta_Alquiler',
    N'Bicicleta de alquiler 2 válida',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Bicicleta_Alquiler(nro_serie,modelo_bicicleta_id,local_id,estado_bicicleta_alquiler_id,precio_hora,precio_dia)
       VALUES (''ZZ_BICI_ALQ_2'',
               (SELECT modelo_bicicleta_id FROM MEGA_DB.Modelo_Bicicleta WHERE modelo=''ZZ_TEST_MODELO''),
               (SELECT local_id FROM MEGA_DB.[Local] WHERE nombre=''ZZ_TEST_LOCAL''),
               (SELECT estado_bicicleta_alquiler_id FROM MEGA_DB.Estado_Bicicleta_Alquiler WHERE descripcion=''ZZ_TEST_ESTADO_BICI''),
               10,50);',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Bicicleta_Alquiler',
    N'Número de serie duplicado',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Bicicleta_Alquiler(nro_serie,modelo_bicicleta_id,local_id,estado_bicicleta_alquiler_id,precio_hora,precio_dia)
       VALUES (''ZZ_BICI_ALQ_1'',
               (SELECT modelo_bicicleta_id FROM MEGA_DB.Modelo_Bicicleta WHERE modelo=''ZZ_TEST_MODELO''),
               (SELECT local_id FROM MEGA_DB.[Local] WHERE nombre=''ZZ_TEST_LOCAL''),
               (SELECT estado_bicicleta_alquiler_id FROM MEGA_DB.Estado_Bicicleta_Alquiler WHERE descripcion=''ZZ_TEST_ESTADO_BICI''),
               10,50);',
    N'DELETE FROM MEGA_DB.Bicicleta_Alquiler WHERE nro_serie=''ZZ_BICI_ALQ_1''
AND bicicleta_alquiler_id<>(SELECT MIN(bicicleta_alquiler_id) FROM MEGA_DB.Bicicleta_Alquiler WHERE nro_serie=''ZZ_BICI_ALQ_1'');'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Estado_Alquiler',
    N'Estado de alquiler válido',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Estado_Alquiler(descripcion) VALUES (''ZZ_TEST_ESTADO_ALQ'');',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Estado_Alquiler',
    N'Estado de alquiler duplicado',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Estado_Alquiler(descripcion) VALUES (''ZZ_TEST_ESTADO_ALQ'');',
    N'DELETE FROM MEGA_DB.Estado_Alquiler WHERE descripcion=''ZZ_TEST_ESTADO_ALQ''
AND estado_alquiler_id<>(SELECT MIN(estado_alquiler_id) FROM MEGA_DB.Estado_Alquiler WHERE descripcion=''ZZ_TEST_ESTADO_ALQ'');'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Alquiler',
    N'Alquiler cerrado válido',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Alquiler(nro_alquiler,cliente_id,empleado_id,bicicleta_alquiler_id,estado_alquiler_id,forma_pago_id,
                                    fecha_inicio,fecha_devolucion_pactada,fecha_devolucion_real,importe_total)
       VALUES (2147000201,
               (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-1'' AND nombre=''Cliente''),
               (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-2''),
               (SELECT bicicleta_alquiler_id FROM MEGA_DB.Bicicleta_Alquiler WHERE nro_serie=''ZZ_BICI_ALQ_1''),
               (SELECT estado_alquiler_id FROM MEGA_DB.Estado_Alquiler WHERE descripcion=''ZZ_TEST_ESTADO_ALQ''),
               (SELECT forma_pago_id FROM MEGA_DB.Forma_Pago WHERE descripcion=''ZZ_TEST_FORMA_PAGO''),
               ''2035-02-01T10:00:00'',''2035-02-01T12:00:00'',''2035-02-01T12:00:00'',20);',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Alquiler',
    N'Rango contiguo al alquiler anterior',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Alquiler(nro_alquiler,cliente_id,empleado_id,bicicleta_alquiler_id,estado_alquiler_id,forma_pago_id,
                                    fecha_inicio,fecha_devolucion_pactada,fecha_devolucion_real,importe_total)
       VALUES (2147000202,
               (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-1'' AND nombre=''Cliente''),
               (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-2''),
               (SELECT bicicleta_alquiler_id FROM MEGA_DB.Bicicleta_Alquiler WHERE nro_serie=''ZZ_BICI_ALQ_1''),
               (SELECT estado_alquiler_id FROM MEGA_DB.Estado_Alquiler WHERE descripcion=''ZZ_TEST_ESTADO_ALQ''),
               (SELECT forma_pago_id FROM MEGA_DB.Forma_Pago WHERE descripcion=''ZZ_TEST_FORMA_PAGO''),
               ''2035-02-01T12:00:00'',''2035-02-01T14:00:00'',''2035-02-01T14:00:00'',20);',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Alquiler',
    N'Superposición parcial con alquiler existente',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Alquiler(nro_alquiler,cliente_id,empleado_id,bicicleta_alquiler_id,estado_alquiler_id,forma_pago_id,
                                    fecha_inicio,fecha_devolucion_pactada,fecha_devolucion_real,importe_total)
       VALUES (2147000291,
               (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-1'' AND nombre=''Cliente''),
               (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-2''),
               (SELECT bicicleta_alquiler_id FROM MEGA_DB.Bicicleta_Alquiler WHERE nro_serie=''ZZ_BICI_ALQ_1''),
               (SELECT estado_alquiler_id FROM MEGA_DB.Estado_Alquiler WHERE descripcion=''ZZ_TEST_ESTADO_ALQ''),
               (SELECT forma_pago_id FROM MEGA_DB.Forma_Pago WHERE descripcion=''ZZ_TEST_FORMA_PAGO''),
               ''2035-02-01T11:00:00'',''2035-02-01T13:00:00'',''2035-02-01T13:00:00'',20);',
    N'DELETE FROM MEGA_DB.Alquiler WHERE nro_alquiler=2147000291;'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Alquiler',
    N'Alquiler abierto sin devolución real',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Alquiler(nro_alquiler,cliente_id,empleado_id,bicicleta_alquiler_id,estado_alquiler_id,forma_pago_id,
                                    fecha_inicio,fecha_devolucion_pactada,fecha_devolucion_real,importe_total)
       VALUES (2147000203,
               (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-1'' AND nombre=''Cliente''),
               (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-2''),
               (SELECT bicicleta_alquiler_id FROM MEGA_DB.Bicicleta_Alquiler WHERE nro_serie=''ZZ_BICI_ALQ_2''),
               (SELECT estado_alquiler_id FROM MEGA_DB.Estado_Alquiler WHERE descripcion=''ZZ_TEST_ESTADO_ALQ''),
               (SELECT forma_pago_id FROM MEGA_DB.Forma_Pago WHERE descripcion=''ZZ_TEST_FORMA_PAGO''),
               ''2035-02-02T10:00:00'',''2035-02-02T12:00:00'',NULL,20);',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Alquiler',
    N'Nuevo alquiler posterior a uno abierto',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Alquiler(nro_alquiler,cliente_id,empleado_id,bicicleta_alquiler_id,estado_alquiler_id,forma_pago_id,
                                    fecha_inicio,fecha_devolucion_pactada,fecha_devolucion_real,importe_total)
       VALUES (2147000292,
               (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-1'' AND nombre=''Cliente''),
               (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-2''),
               (SELECT bicicleta_alquiler_id FROM MEGA_DB.Bicicleta_Alquiler WHERE nro_serie=''ZZ_BICI_ALQ_2''),
               (SELECT estado_alquiler_id FROM MEGA_DB.Estado_Alquiler WHERE descripcion=''ZZ_TEST_ESTADO_ALQ''),
               (SELECT forma_pago_id FROM MEGA_DB.Forma_Pago WHERE descripcion=''ZZ_TEST_FORMA_PAGO''),
               ''2035-02-03T10:00:00'',''2035-02-03T12:00:00'',''2035-02-03T12:00:00'',20);',
    N'DELETE FROM MEGA_DB.Alquiler WHERE nro_alquiler=2147000292;'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Alquiler',
    N'Fecha pactada anterior al inicio',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Alquiler(nro_alquiler,cliente_id,empleado_id,bicicleta_alquiler_id,estado_alquiler_id,forma_pago_id,
                                    fecha_inicio,fecha_devolucion_pactada,fecha_devolucion_real,importe_total)
       VALUES (2147000293,
               (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-1'' AND nombre=''Cliente''),
               (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-2''),
               (SELECT bicicleta_alquiler_id FROM MEGA_DB.Bicicleta_Alquiler WHERE nro_serie=''ZZ_BICI_ALQ_1''),
               (SELECT estado_alquiler_id FROM MEGA_DB.Estado_Alquiler WHERE descripcion=''ZZ_TEST_ESTADO_ALQ''),
               (SELECT forma_pago_id FROM MEGA_DB.Forma_Pago WHERE descripcion=''ZZ_TEST_FORMA_PAGO''),
               ''2035-02-10T10:00:00'',''2035-02-09T10:00:00'',NULL,20);',
    N'DELETE FROM MEGA_DB.Alquiler WHERE nro_alquiler=2147000293;'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Alquiler',
    N'Número de alquiler duplicado',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Alquiler(nro_alquiler,cliente_id,empleado_id,bicicleta_alquiler_id,estado_alquiler_id,forma_pago_id,
                                    fecha_inicio,fecha_devolucion_pactada,fecha_devolucion_real,importe_total)
       VALUES (2147000201,
               (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-1'' AND nombre=''Cliente''),
               (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-2''),
               (SELECT bicicleta_alquiler_id FROM MEGA_DB.Bicicleta_Alquiler WHERE nro_serie=''ZZ_BICI_ALQ_1''),
               (SELECT estado_alquiler_id FROM MEGA_DB.Estado_Alquiler WHERE descripcion=''ZZ_TEST_ESTADO_ALQ''),
               (SELECT forma_pago_id FROM MEGA_DB.Forma_Pago WHERE descripcion=''ZZ_TEST_FORMA_PAGO''),
               ''2035-03-01'',''2035-03-01T12:00:00'',''2035-03-01T12:00:00'',20);',
    N'DELETE FROM MEGA_DB.Alquiler WHERE nro_alquiler=2147000201
AND alquiler_id<>(SELECT MIN(alquiler_id) FROM MEGA_DB.Alquiler WHERE nro_alquiler=2147000201);'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Categoria_Repuesto',
    N'Categoría de repuesto válida',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Categoria_Repuesto(descripcion) VALUES (''ZZ_TEST_CAT_REP'');',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Categoria_Repuesto',
    N'Categoría de repuesto duplicada',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Categoria_Repuesto(descripcion) VALUES (''ZZ_TEST_CAT_REP'');',
    N'DELETE FROM MEGA_DB.Categoria_Repuesto WHERE descripcion=''ZZ_TEST_CAT_REP''
AND categoria_repuesto_id<>(SELECT MIN(categoria_repuesto_id) FROM MEGA_DB.Categoria_Repuesto WHERE descripcion=''ZZ_TEST_CAT_REP'');'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Repuesto',
    N'Repuesto válido',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Repuesto(cod_repuesto,categoria_repuesto_id,descripcion,compatibilidad,precio)
       VALUES (''ZZ_REP_1'',(SELECT categoria_repuesto_id FROM MEGA_DB.Categoria_Repuesto WHERE descripcion=''ZZ_TEST_CAT_REP''),
               ''Repuesto Test'',''Universal'',100);',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Repuesto',
    N'Código de repuesto duplicado',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Repuesto(cod_repuesto,categoria_repuesto_id,descripcion,precio)
       VALUES (''ZZ_REP_1'',(SELECT categoria_repuesto_id FROM MEGA_DB.Categoria_Repuesto WHERE descripcion=''ZZ_TEST_CAT_REP''),
               ''Duplicado'',100);',
    N'DELETE FROM MEGA_DB.Repuesto WHERE cod_repuesto=''ZZ_REP_1''
AND repuesto_id<>(SELECT MIN(repuesto_id) FROM MEGA_DB.Repuesto WHERE cod_repuesto=''ZZ_REP_1'');'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Estado_Reparacion',
    N'Estado de reparación válido',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Estado_Reparacion(descripcion) VALUES (''ZZ_TEST_ESTADO_REP'');',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Estado_Reparacion',
    N'Estado de reparación duplicado',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Estado_Reparacion(descripcion) VALUES (''ZZ_TEST_ESTADO_REP'');',
    N'DELETE FROM MEGA_DB.Estado_Reparacion WHERE descripcion=''ZZ_TEST_ESTADO_REP''
AND estado_reparacion_id<>(SELECT MIN(estado_reparacion_id) FROM MEGA_DB.Estado_Reparacion WHERE descripcion=''ZZ_TEST_ESTADO_REP'');'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Reparacion',
    N'Reparación válida',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Reparacion(nro_reparacion,local_id,cliente_id,empleado_id,modelo_bicicleta_id,estado_reparacion_id,
                                      numero_serie_bici,fecha_ingreso,fecha_entrega_estimada,fecha_entrega_real,diagnostico,
                                      precio_mano_obra,precio_repuestos,precio_total)
       VALUES (2147000301,
               (SELECT local_id FROM MEGA_DB.[Local] WHERE nombre=''ZZ_TEST_LOCAL''),
               (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-1'' AND nombre=''Cliente''),
               (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-2''),
               (SELECT modelo_bicicleta_id FROM MEGA_DB.Modelo_Bicicleta WHERE modelo=''ZZ_TEST_MODELO''),
               (SELECT estado_reparacion_id FROM MEGA_DB.Estado_Reparacion WHERE descripcion=''ZZ_TEST_ESTADO_REP''),
               ''ZZ_SERIE_CLIENTE'',''2035-04-01'',''2035-04-05'',''2035-04-04'',''Cambio de cadena'',200,100,300);',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Reparacion',
    N'Entrega estimada anterior al ingreso',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Reparacion(nro_reparacion,local_id,cliente_id,empleado_id,modelo_bicicleta_id,estado_reparacion_id,
                                      fecha_ingreso,fecha_entrega_estimada,diagnostico,precio_mano_obra,precio_repuestos,precio_total)
       VALUES (2147000391,
               (SELECT local_id FROM MEGA_DB.[Local] WHERE nombre=''ZZ_TEST_LOCAL''),
               (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-1'' AND nombre=''Cliente''),
               (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-2''),
               (SELECT modelo_bicicleta_id FROM MEGA_DB.Modelo_Bicicleta WHERE modelo=''ZZ_TEST_MODELO''),
               (SELECT estado_reparacion_id FROM MEGA_DB.Estado_Reparacion WHERE descripcion=''ZZ_TEST_ESTADO_REP''),
               ''2035-04-05'',''2035-04-04'',''Inválida'',1,1,2);',
    N'DELETE FROM MEGA_DB.Reparacion WHERE nro_reparacion=2147000391;'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Reparacion',
    N'Entrega real anterior al ingreso',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Reparacion(nro_reparacion,local_id,cliente_id,empleado_id,modelo_bicicleta_id,estado_reparacion_id,
                                      fecha_ingreso,fecha_entrega_estimada,fecha_entrega_real,diagnostico,precio_mano_obra,precio_repuestos,precio_total)
       VALUES (2147000392,
               (SELECT local_id FROM MEGA_DB.[Local] WHERE nombre=''ZZ_TEST_LOCAL''),
               (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-1'' AND nombre=''Cliente''),
               (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-2''),
               (SELECT modelo_bicicleta_id FROM MEGA_DB.Modelo_Bicicleta WHERE modelo=''ZZ_TEST_MODELO''),
               (SELECT estado_reparacion_id FROM MEGA_DB.Estado_Reparacion WHERE descripcion=''ZZ_TEST_ESTADO_REP''),
               ''2035-04-05'',''2035-04-06'',''2035-04-04'',''Inválida'',1,1,2);',
    N'DELETE FROM MEGA_DB.Reparacion WHERE nro_reparacion=2147000392;'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Reparacion',
    N'Número de reparación duplicado',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Reparacion(nro_reparacion,local_id,cliente_id,empleado_id,modelo_bicicleta_id,estado_reparacion_id,
                                      fecha_ingreso,fecha_entrega_estimada,diagnostico,precio_mano_obra,precio_repuestos,precio_total)
       VALUES (2147000301,
               (SELECT local_id FROM MEGA_DB.[Local] WHERE nombre=''ZZ_TEST_LOCAL''),
               (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-1'' AND nombre=''Cliente''),
               (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-2''),
               (SELECT modelo_bicicleta_id FROM MEGA_DB.Modelo_Bicicleta WHERE modelo=''ZZ_TEST_MODELO''),
               (SELECT estado_reparacion_id FROM MEGA_DB.Estado_Reparacion WHERE descripcion=''ZZ_TEST_ESTADO_REP''),
               ''2035-04-10'',''2035-04-11'',''Duplicada'',1,1,2);',
    N'DELETE FROM MEGA_DB.Reparacion WHERE nro_reparacion=2147000301
AND reparacion_id<>(SELECT MIN(reparacion_id) FROM MEGA_DB.Reparacion WHERE nro_reparacion=2147000301);'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Reparacion_Repuesto',
    N'Detalle de repuesto válido',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Reparacion_Repuesto(reparacion_id,repuesto_id,cantidad,precio_unitario,subtotal)
       VALUES ((SELECT reparacion_id FROM MEGA_DB.Reparacion WHERE nro_reparacion=2147000301),
               (SELECT repuesto_id FROM MEGA_DB.Repuesto WHERE cod_repuesto=''ZZ_REP_1''),
               1,100,100);',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Reparacion_Repuesto',
    N'Cantidad 0',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Reparacion_Repuesto(reparacion_id,repuesto_id,cantidad,precio_unitario,subtotal)
       VALUES ((SELECT reparacion_id FROM MEGA_DB.Reparacion WHERE nro_reparacion=2147000301),
               (SELECT repuesto_id FROM MEGA_DB.Repuesto WHERE cod_repuesto=''ZZ_REP_1''),
               0,100,0);',
    N'DELETE FROM MEGA_DB.Reparacion_Repuesto
       WHERE reparacion_id=(SELECT reparacion_id FROM MEGA_DB.Reparacion WHERE nro_reparacion=2147000301) AND cantidad=0;'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Reparacion_Repuesto',
    N'Precio unitario negativo',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Reparacion_Repuesto(reparacion_id,repuesto_id,cantidad,precio_unitario,subtotal)
       VALUES ((SELECT reparacion_id FROM MEGA_DB.Reparacion WHERE nro_reparacion=2147000301),
               (SELECT repuesto_id FROM MEGA_DB.Repuesto WHERE cod_repuesto=''ZZ_REP_1''),
               1,-1,-1);',
    N'DELETE FROM MEGA_DB.Reparacion_Repuesto
       WHERE reparacion_id=(SELECT reparacion_id FROM MEGA_DB.Reparacion WHERE nro_reparacion=2147000301) AND precio_unitario=-1;'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Proveedor',
    N'Proveedor válido',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Proveedor(localidad_id,razon_social,cuit,telefono,email,direccion)
       VALUES ((SELECT l.localidad_id FROM MEGA_DB.Localidad l JOIN MEGA_DB.Provincia p ON p.provincia_id=l.provincia_id
                WHERE l.nombre=''ZZ_TEST_LOCALIDAD'' AND p.nombre=''ZZ_TEST_PROV_A''),
               ''Proveedor Test'',''ZZ-CUIT-1'',''4444'',''proveedor@test.local'',''Calle Proveedor 1'');',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Proveedor',
    N'CUIT de proveedor duplicado',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Proveedor(localidad_id,razon_social,cuit,direccion)
       VALUES ((SELECT l.localidad_id FROM MEGA_DB.Localidad l JOIN MEGA_DB.Provincia p ON p.provincia_id=l.provincia_id
                WHERE l.nombre=''ZZ_TEST_LOCALIDAD'' AND p.nombre=''ZZ_TEST_PROV_A''),
               ''Proveedor Duplicado'',''ZZ-CUIT-1'',''Otra'');',
    N'DELETE FROM MEGA_DB.Proveedor WHERE cuit=''ZZ-CUIT-1''
AND proveedor_id<>(SELECT MIN(proveedor_id) FROM MEGA_DB.Proveedor WHERE cuit=''ZZ-CUIT-1'');'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Compra',
    N'Compra válida',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Compra(nro_compra,proveedor_id,local_id,empleado_id,fecha_compra,total)
       VALUES (2147000401,
               (SELECT proveedor_id FROM MEGA_DB.Proveedor WHERE cuit=''ZZ-CUIT-1''),
               (SELECT local_id FROM MEGA_DB.[Local] WHERE nombre=''ZZ_TEST_LOCAL''),
               (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-2''),
               ''2035-05-01'',500);',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Compra',
    N'Número de compra duplicado',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Compra(nro_compra,proveedor_id,local_id,empleado_id,fecha_compra,total)
       VALUES (2147000401,
               (SELECT proveedor_id FROM MEGA_DB.Proveedor WHERE cuit=''ZZ-CUIT-1''),
               (SELECT local_id FROM MEGA_DB.[Local] WHERE nombre=''ZZ_TEST_LOCAL''),
               (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-2''),
               ''2035-05-02'',1);',
    N'DELETE FROM MEGA_DB.Compra WHERE nro_compra=2147000401
AND compra_id<>(SELECT MIN(compra_id) FROM MEGA_DB.Compra WHERE nro_compra=2147000401);'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Compra',
    N'Compra con proveedor inexistente',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Compra(nro_compra,proveedor_id,local_id,empleado_id,fecha_compra,total)
       VALUES (2147000499,-999999,
               (SELECT local_id FROM MEGA_DB.[Local] WHERE nombre=''ZZ_TEST_LOCAL''),
               (SELECT persona_id FROM MEGA_DB.Persona WHERE dni=''ZZTEST-DNI-2''),
               ''2035-05-02'',1);',
    N'DELETE FROM MEGA_DB.Compra WHERE nro_compra=2147000499;'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Compra_Detalle',
    N'Detalle de compra válido',
    N'INSERTA',
    N'INSERT INTO MEGA_DB.Compra_Detalle(compra_id,producto_id,cantidad,precio_unitario)
       VALUES ((SELECT compra_id FROM MEGA_DB.Compra WHERE nro_compra=2147000401),
               (SELECT producto_id FROM MEGA_DB.Producto WHERE cod_producto=''ZZ_PROD_ACC_1''),
               10,25);',
    NULL
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Compra_Detalle',
    N'Cantidad 0',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Compra_Detalle(compra_id,producto_id,cantidad,precio_unitario)
       VALUES ((SELECT compra_id FROM MEGA_DB.Compra WHERE nro_compra=2147000401),
               (SELECT producto_id FROM MEGA_DB.Producto WHERE cod_producto=''ZZ_PROD_BICI_2''),
               0,25);',
    N'DELETE FROM MEGA_DB.Compra_Detalle
       WHERE compra_id=(SELECT compra_id FROM MEGA_DB.Compra WHERE nro_compra=2147000401)
         AND producto_id=(SELECT producto_id FROM MEGA_DB.Producto WHERE cod_producto=''ZZ_PROD_BICI_2'') AND cantidad=0;'
);


INSERT INTO #Pruebas(tabla,descripcion,esperado,sql_prueba,sql_cleanup)
VALUES (
    N'Compra_Detalle',
    N'Precio unitario negativo',
    N'RECHAZA',
    N'INSERT INTO MEGA_DB.Compra_Detalle(compra_id,producto_id,cantidad,precio_unitario)
       VALUES ((SELECT compra_id FROM MEGA_DB.Compra WHERE nro_compra=2147000401),
               (SELECT producto_id FROM MEGA_DB.Producto WHERE cod_producto=''ZZ_PROD_BICI_2''),
               1,-1);',
    N'DELETE FROM MEGA_DB.Compra_Detalle
       WHERE compra_id=(SELECT compra_id FROM MEGA_DB.Compra WHERE nro_compra=2147000401)
         AND producto_id=(SELECT producto_id FROM MEGA_DB.Producto WHERE cod_producto=''ZZ_PROD_BICI_2'') AND precio_unitario=-1;'
);


PRINT 'Ejecutando pruebas...';

DECLARE
    @caso INT,
    @tabla SYSNAME,
    @descripcion VARCHAR(300),
    @esperado VARCHAR(10),
    @sql NVARCHAR(MAX),
    @cleanup NVARCHAR(MAX);

DECLARE cur_pruebas CURSOR LOCAL FAST_FORWARD FOR
    SELECT caso, tabla, descripcion, esperado, sql_prueba, sql_cleanup
    FROM #Pruebas
    ORDER BY caso;

OPEN cur_pruebas;

FETCH NEXT FROM cur_pruebas
INTO @caso, @tabla, @descripcion, @esperado, @sql, @cleanup;

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN TRY
        EXEC sys.sp_executesql @sql;

        IF @esperado = 'INSERTA'
        BEGIN
            INSERT INTO #Resultados(caso,tabla,descripcion,esperado,resultado,detalle)
            VALUES (@caso,@tabla,@descripcion,@esperado,'OK - INSERTADO',NULL);
        END
        ELSE
        BEGIN
            INSERT INTO #Resultados(caso,tabla,descripcion,esperado,resultado,detalle)
            VALUES (@caso,@tabla,@descripcion,@esperado,'FALLO - INSERTADO',
                    N'El INSERT se acepto pero se esperaba que una restriccion lo rechazara.');

            -- Si un caso que debia fallar se inserto, se lo elimina para no
            -- contaminar los casos siguientes.
            IF @cleanup IS NOT NULL
            BEGIN
                BEGIN TRY
                    EXEC sys.sp_executesql @cleanup;
                END TRY
                BEGIN CATCH
                    UPDATE #Resultados
                    SET detalle = CONCAT(detalle, N' No se pudo limpiar el registro inesperado: ', ERROR_MESSAGE())
                    WHERE caso = @caso;
                END CATCH;
            END
        END
    END TRY
    BEGIN CATCH
        IF @esperado = 'RECHAZA'
        BEGIN
            INSERT INTO #Resultados(caso,tabla,descripcion,esperado,resultado,detalle)
            VALUES (@caso,@tabla,@descripcion,@esperado,'OK - RECHAZADO',ERROR_MESSAGE());
        END
        ELSE
        BEGIN
            INSERT INTO #Resultados(caso,tabla,descripcion,esperado,resultado,detalle)
            VALUES (@caso,@tabla,@descripcion,@esperado,'FALLO - RECHAZADO',ERROR_MESSAGE());
        END
    END CATCH;

    FETCH NEXT FROM cur_pruebas
    INTO @caso, @tabla, @descripcion, @esperado, @sql, @cleanup;
END

CLOSE cur_pruebas;
DEALLOCATE cur_pruebas;

PRINT 'Limpiando datos de prueba...';
BEGIN TRY

    -- Detalles dependientes

    DELETE cd

    FROM MEGA_DB.Compra_Detalle cd

    JOIN MEGA_DB.Compra c ON c.compra_id = cd.compra_id

    WHERE c.nro_compra BETWEEN 2147000400 AND 2147000499;

    

    DELETE rr

    FROM MEGA_DB.Reparacion_Repuesto rr

    JOIN MEGA_DB.Reparacion r ON r.reparacion_id = rr.reparacion_id

    WHERE r.nro_reparacion BETWEEN 2147000300 AND 2147000399;

    

    DELETE vd

    FROM MEGA_DB.Venta_Detalle vd

    JOIN MEGA_DB.Venta v ON v.venta_id = vd.venta_id

    WHERE v.nro_venta BETWEEN 2147000100 AND 2147000199;

    

    -- Cabeceras

    DELETE FROM MEGA_DB.Compra

    WHERE nro_compra BETWEEN 2147000400 AND 2147000499;

    

    DELETE FROM MEGA_DB.Reparacion

    WHERE nro_reparacion BETWEEN 2147000300 AND 2147000399;

    

    DELETE FROM MEGA_DB.Alquiler

    WHERE nro_alquiler BETWEEN 2147000200 AND 2147000299;

    

    DELETE FROM MEGA_DB.Venta

    WHERE nro_venta BETWEEN 2147000100 AND 2147000199;

    

    -- Proveedores / repuestos / flota

    DELETE FROM MEGA_DB.Proveedor WHERE cuit LIKE 'ZZ-CUIT-%';

    

    DELETE FROM MEGA_DB.Repuesto WHERE cod_repuesto LIKE 'ZZ_REP_%';

    DELETE FROM MEGA_DB.Categoria_Repuesto WHERE descripcion LIKE 'ZZ_TEST_CAT_REP%';

    DELETE FROM MEGA_DB.Estado_Reparacion WHERE descripcion LIKE 'ZZ_TEST_ESTADO_REP%';

    

    DELETE FROM MEGA_DB.Bicicleta_Alquiler WHERE nro_serie LIKE 'ZZ_BICI_ALQ_%';

    DELETE FROM MEGA_DB.Estado_Alquiler WHERE descripcion LIKE 'ZZ_TEST_ESTADO_ALQ%';

    DELETE FROM MEGA_DB.Estado_Bicicleta_Alquiler WHERE descripcion LIKE 'ZZ_TEST_ESTADO_BICI%';

    

    -- Productos y subtipos

    DELETE a

    FROM MEGA_DB.Accesorio a

    JOIN MEGA_DB.Producto p ON p.producto_id = a.producto_id

    WHERE p.cod_producto LIKE 'ZZ_PROD_%';

    

    DELETE bv

    FROM MEGA_DB.Bicicleta_Venta bv

    JOIN MEGA_DB.Producto p ON p.producto_id = bv.producto_id

    WHERE p.cod_producto LIKE 'ZZ_PROD_%';

    

    DELETE FROM MEGA_DB.Producto WHERE cod_producto LIKE 'ZZ_PROD_%';

    DELETE FROM MEGA_DB.Categoria_Accesorio WHERE descripcion LIKE 'ZZ_TEST_CAT_ACC%';

    DELETE FROM MEGA_DB.Tipo_Producto WHERE descripcion LIKE 'ZZ_TEST_TIPO_%';

    

    DELETE FROM MEGA_DB.Modelo_Bicicleta WHERE modelo LIKE 'ZZ_TEST_MODELO%';

    DELETE FROM MEGA_DB.Categoria_Bicicleta WHERE descripcion LIKE 'ZZ_TEST_CAT_BICI%';

    DELETE FROM MEGA_DB.Marca WHERE nombre LIKE 'ZZ_TEST_MARCA%';

    

    DELETE FROM MEGA_DB.Forma_Pago WHERE descripcion LIKE 'ZZ_TEST_FORMA_PAGO%';

    

    -- Personas / locales / ubicaciones

    DELETE e

    FROM MEGA_DB.Empleado e

    JOIN MEGA_DB.Persona p ON p.persona_id = e.persona_id

    WHERE p.dni LIKE 'ZZTEST-DNI-%';

    

    DELETE c

    FROM MEGA_DB.Cliente c

    JOIN MEGA_DB.Persona p ON p.persona_id = c.persona_id

    WHERE p.dni LIKE 'ZZTEST-DNI-%';

    

    DELETE FROM MEGA_DB.Persona WHERE dni LIKE 'ZZTEST-DNI-%';

    DELETE FROM MEGA_DB.[Local] WHERE nombre LIKE 'ZZ_TEST_LOCAL%';

    

    DELETE l

    FROM MEGA_DB.Localidad l

    JOIN MEGA_DB.Provincia p ON p.provincia_id = l.provincia_id

    WHERE l.nombre LIKE 'ZZ_TEST_LOCALIDAD%' OR p.nombre LIKE 'ZZ_TEST_PROV_%';

    

    DELETE FROM MEGA_DB.Provincia WHERE nombre LIKE 'ZZ_TEST_PROV_%';

END TRY
BEGIN CATCH
    INSERT INTO #Resultados(caso,tabla,descripcion,esperado,resultado,detalle)
    VALUES (2147483647,'LIMPIEZA','Limpieza final de datos de prueba','INSERTA','FALLO - LIMPIEZA',ERROR_MESSAGE());
END CATCH;

-- Resultado detallado
SELECT caso, tabla, descripcion, esperado, resultado, detalle
FROM #Resultados
ORDER BY caso;

-- Resumen por tabla
SELECT
    tabla,
    COUNT(*) AS pruebas,
    SUM(CASE WHEN resultado LIKE 'OK - %' THEN 1 ELSE 0 END) AS correctas,
    SUM(CASE WHEN resultado LIKE 'FALLO - %' THEN 1 ELSE 0 END) AS fallidas
FROM #Resultados
WHERE tabla <> 'LIMPIEZA'
GROUP BY tabla
ORDER BY tabla;

-- Resumen general
SELECT
    COUNT(*) AS pruebas_totales,
    SUM(CASE WHEN resultado LIKE 'OK - %' THEN 1 ELSE 0 END) AS correctas,
    SUM(CASE WHEN resultado LIKE 'FALLO - %' THEN 1 ELSE 0 END) AS fallidas
FROM #Resultados
WHERE tabla <> 'LIMPIEZA';
GO