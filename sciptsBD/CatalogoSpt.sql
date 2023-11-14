DECLARE @Datos xml/*Declaramos la variable Datos como un tipo XML*/
declare @rutaCata NVARCHAR(500)
set @rutaCata = 'C:\XML archivos\Catalogos1.xml'

declare @rutaOpe NVARCHAR(500)
set @rutaOpe = 'C:\XML archivos\OperacionesV2.xml'
declare @articulosXml table(
	Id varchar(32)
	,Nombre varchar(128)
)


 -- Para cargar el archivo con una variable, CHAR(39) son comillas simples
DECLARE @ComandoCata NVARCHAR(500)= 'SELECT @Datos = D FROM OPENROWSET (BULK '  + CHAR(39) + @rutaCata + CHAR(39) + ', SINGLE_BLOB) AS Datos(D)' -- comando que va a ejecutar el sql dinamico
--10

DECLARE @ComandoOpe NVARCHAR(500)= 'SELECT @Datos = D FROM OPENROWSET (BULK '  + CHAR(39) + @rutaOpe + CHAR(39) + ', SINGLE_BLOB) AS Datos(D)' 

DECLARE @Parametros NVARCHAR(500)
SET @Parametros = N'@Datos xml OUTPUT' --parametros del sql dinamico

EXECUTE sp_executesql @ComandoCata, @Parametros, @Datos OUTPUT -- ejecutamos el comando que hicimos dinamicamente
    
DECLARE @hdoc int /*Creamos hdoc que va a ser un identificador*/
    
EXEC sp_xml_preparedocument @hdoc OUTPUT, @Datos/*Toma el identificador y a la variable con el documento y las asocia*/

--insert into @articulosXml(
--				Id,
--				Nombre
--			)
Select Id, Nombre
from openxml (@hdoc, '/Catalogos/TiposdeDocumentodeIdentidad/TipoDocuIdentidad ' , 1)/*Lee los contenidos del XML y para eso necesita un identificador,el 
PATH del nodo y el 1 que sirve para retornar solo atributos*/
WITH(/*Dentro del WITH se pone el nombre y el tipo de los atributos a retornar*/
    Id Int '@Id',
	Nombre VARCHAR(100) '@Nombre'
	)

Select Id, Nombre, HoraInicio, HoraFin
from openxml (@hdoc, '/Catalogos/TiposDeJornadas/TipoDeJornada  ' , 1)/*Lee los contenidos del XML y para eso necesita un identificador,el 
PATH del nodo y el 1 que sirve para retornar solo atributos*/
WITH(/*Dentro del WITH se pone el nombre y el tipo de los atributos a retornar*/
    Id Int '@Id',
	Nombre VARCHAR(100) '@Nombre',
	HoraInicio VARCHAR(100) '@HoraInicio',
	HoraFin VARCHAR(100) '@HoraFin'
	)

Select Id, Nombre, SalarioXHora
from openxml (@hdoc, '/Catalogos/Puestos/Puesto' , 1)/*Lee los contenidos del XML y para eso necesita un identificador,el 
PATH del nodo y el 1 que sirve para retornar solo atributos*/
WITH(/*Dentro del WITH se pone el nombre y el tipo de los atributos a retornar*/
    Id Int '@Id',
	Nombre VARCHAR(100) '@Nombre',
	SalarioXHora VARCHAR(100) '@SalarioXHora'
	)

Select Id, Nombre
from openxml (@hdoc, '/Catalogos/Departamentos/Departamento' , 1)/*Lee los contenidos del XML y para eso necesita un identificador,el 
PATH del nodo y el 1 que sirve para retornar solo atributos*/
WITH(/*Dentro del WITH se pone el nombre y el tipo de los atributos a retornar*/
    Id Int '@Id',
	Nombre VARCHAR(100) '@Nombre'
	)

Select Id, Nombre, Fecha
from openxml (@hdoc, '/Catalogos/Feriados/Feriado' , 1)/*Lee los contenidos del XML y para eso necesita un identificador,el 
PATH del nodo y el 1 que sirve para retornar solo atributos*/
WITH(/*Dentro del WITH se pone el nombre y el tipo de los atributos a retornar*/
    Id Int '@Id',
	Nombre VARCHAR(100) '@Nombre',
	Fecha VARCHAR(100) '@Nombre'
	)

Select Id, Nombre
from openxml (@hdoc, '/Catalogos/TiposDeMovimiento/TipoDeMovimiento' , 1)/*Lee los contenidos del XML y para eso necesita un identificador,el 
PATH del nodo y el 1 que sirve para retornar solo atributos*/
WITH(/*Dentro del WITH se pone el nombre y el tipo de los atributos a retornar*/
    Id Int '@Id',
	Nombre VARCHAR(100) '@Nombre'
	)

Select Id, Nombre, Obligatorio, Porcentual, Valor
from openxml (@hdoc, '/Catalogos/TiposDeDeduccion/TipoDeDeduccion' , 1)/*Lee los contenidos del XML y para eso necesita un identificador,el 
PATH del nodo y el 1 que sirve para retornar solo atributos*/
WITH(/*Dentro del WITH se pone el nombre y el tipo de los atributos a retornar*/
    Id Int '@Id',
	Nombre VARCHAR(100) '@Nombre',
	Obligatorio VARCHAR(100) '@Obligatorio' ,
	Porcentual VARCHAR(100) '@Porcentual',
	Valor Real '@Valor'
	)

Select Pwd, tipo, Username
from openxml (@hdoc, '/Catalogos/UsuariosAdministradores/Usuario' , 1)/*Lee los contenidos del XML y para eso necesita un identificador,el 
PATH del nodo y el 1 que sirve para retornar solo atributos*/
WITH(/*Dentro del WITH se pone el nombre y el tipo de los atributos a retornar*/
    Pwd VARCHAR(100) '@Pwd',
	tipo VARCHAR(100) '@tipo',
	Username VARCHAR(100) '@Username'
	)


Select Id, Nombre
from openxml (@hdoc, '/Catalogos/TiposdeEvento/TipoEvento' , 1)/*Lee los contenidos del XML y para eso necesita un identificador,el 
PATH del nodo y el 1 que sirve para retornar solo atributos*/
WITH(/*Dentro del WITH se pone el nombre y el tipo de los atributos a retornar*/
    Id Int '@Id',
	Nombre VARCHAR(100) '@Nombre'
	)

Select Id, Nombre
from openxml (@hdoc, '/Catalogos/TiposdeEvento/TipoEvento' , 1)/*Lee los contenidos del XML y para eso necesita un identificador,el 
PATH del nodo y el 1 que sirve para retornar solo atributos*/
WITH(/*Dentro del WITH se pone el nombre y el tipo de los atributos a retornar*/
    Id Int '@Id',
	Nombre VARCHAR(100) '@Nombre'
	)

Exec sp_xml_removedocument @hdoc;

EXECUTE sp_executesql @ComandoOpe, @Parametros, @Datos OUTPUT -- ejecutamos el comando que hicimos dinamicamente

EXEC sp_xml_preparedocument @hdoc OUTPUT, @Datos/*Toma el identificador y a la variable con el documento y las asocia*/

declare @XmlOpe xml;
set @XmlOpe = (select T.A.query('.') as Today
				FROM   @Datos.nodes('Operacion/FechaOperacion') T(A)
				where '2023-07-06'
					in (T.A.value('@Fecha','varchar(50)')));

select Fecha
from openxml (@hdoc, '/Operacion/FechaOperacion' , 1)/*Lee los contenidos del XML y para eso necesita un identificador,el 
PATH del nodo y el 1 que sirve para retornar solo atributos*/
WITH(/*Dentro del WITH se pone el nombre y el tipo de los atributos a retornar*/

		Fecha Date '@Fecha' 
	)

Select Nombre
	, IdTipoDocumento, ValorTipoDocumento
	, IdDepartamento, IdPuesto
	, Usuario, Pass
from openxml (@hdoc, '/Operacion/FechaOperacion/NuevosEmpleados/NuevoEmpleado' , 1)
WITH(
    Nombre varchar(128) '@Nombre'
	, IdTipoDocumento int '@IdTipoDocumento'
	, ValorTipoDocumento varchar(128) '@ValorTipoDocumento'
	, IdDepartamento int '@IdDepartamento'
	, IdPuesto int '@IdPuesto'
	, Usuario varchar(128) '@Usuario'
	, Pass varchar(128) '@Password'
	)
Exec sp_xml_removedocument @hdoc;

EXEC sp_xml_preparedocument @hdoc OUTPUT, @XmlOpe

insert into Empleado(
		Nombre
		, Usuario
		, Password
		, IdDepartamento
		, IdPuesto
		, IdTipoDocumento
	)
Select Nombre
	, Usuario
	, Pass
	, IdDepartamento
	, IdPuesto
	, IdTipoDocumento
from openxml (@hdoc, '/FechaOperacion/NuevosEmpleados/NuevoEmpleado' , 1)
WITH(
    Nombre varchar(128) '@Nombre'
	, IdTipoDocumento int '@IdTipoDocumento'
	, ValorTipoDocumento varchar(128) '@ValorTipoDocumento'
	, IdDepartamento int '@IdDepartamento'
	, IdPuesto int '@IdPuesto'
	, Usuario varchar(128) '@Usuario'
	, Pass varchar(128) '@Password'
	)

Exec sp_xml_removedocument @hdoc;