use [Commercial bank]
declare @inRutaXML NVARCHAR(500)
Set @inRutaXML = N'C:\Users\Oscar Campos Argueda\Documents\2023\Bases\proyecto 3/Ruta.xml';
DECLARE @Datos xml/*Declaramos la variable Datos como un tipo XML*/

-- Para cargar el archivo con una variable, CHAR(39) son comillas simples
DECLARE @Comando NVARCHAR(500)= 'SELECT @Datos = D FROM OPENROWSET (BULK '  + CHAR(39) + @inRutaXML + CHAR(39) + ', SINGLE_BLOB) AS Datos(D)' -- comando que va a ejecutar el sql dinamico
--10
DECLARE @Parametros NVARCHAR(500)
SET @Parametros = N'@Datos xml OUTPUT' --parametros del sql dinamico
EXECUTE sp_executesql @Comando, @Parametros, @Datos OUTPUT -- ejecutamos el comando que hicimos dinamicamente
DECLARE @hdoc int /*Creamos hdoc que va a ser un identificador*/

/*
SELECT
	T.A.query('.') as Today
FROM   @Datos.nodes('root/fechaOperacion') T(A)
	where '2023-05-14' in (T.A.value('@Fecha','varchar(50)'))
*/


EXEC sp_xml_preparedocument @hdoc OUTPUT, @Datos/*Toma el identificador y a la variable con el documento y las asocia*/


--Crear la tabla que contendra las fechas de
-- las operaciones
DECLARE @Fechas table (Fecha Date);

declare @FechaItera Date
	, @FechaFinal Date


declare @Mov Table (Nombre varchar(50)
				, TF varchar(50)
				, FechaMovimiento date
				, Monto money 
				, Descripcion varchar(50)
				, Referencia varchar(50)
				)
--ExtraerFechas
INSERT @Fechas (Fecha)
	Select Fecha
	FROM OPENXML (@hdoc, '/root/fechaOperacion' , 1)/*Lee los contenidos del XML y para eso necesita un identificador,el 
	PATH del nodo y el 1 que sirve para retornar solo atributos*/
	WITH( 
		Fecha date '@Fecha'
		)

Select @FechaItera = MIN(F.Fecha), 
		@FechaFinal = MAX(F.Fecha) 
	from @Fechas F

EXEC sp_xml_removedocument @hdoc;

declare @Hd int;

While (@FechaItera <= @FechaFinal)
	Begin

		if EXISTS (select Fecha from @Fechas Fs
					where Fs.Fecha = @FechaItera)
		Begin --Extraer Datos para cada nodo

			declare @XmlOp xml;
			set @XmlOp = (select T.A.query('.') as Today
				FROM   @Datos.nodes('root/fechaOperacion') T(A)
				where @FechaItera 
					in (T.A.value('@Fecha','varchar(50)')));

			EXEC sp_xml_preparedocument @Hd OUTPUT, @XmlOp

			begin transaction ActualizarPlantilla
				
				
			commit transaction ActualizarPlantilla
			
			begin transaction 

							
			commit transaction
			--
			--Pasa las tablas temporales a las tablas
			--
			begin transaction 
			
			commit transaction

			EXEC sp_xml_removedocument @Hd;
		End

		Set @FechaItera = DATEADD(DAY, 1, @FechaItera)
	End

/*
delete 
DBCC CHECKIDENT('',reseed,0)
delete 
DBCC CHECKIDENT('',reseed,0)
delete 
DBCC CHECKIDENT('',reseed,0)
*/