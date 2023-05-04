
CREATE FUNCTION [dbo].[FnSplitTable]
(@Array varchar(1000),@separator char(1))
RETURNS @table_variable TABLE (
		id int identity(1,1),
		part nvarchar(1000))
AS
BEGIN
	set @Array =RTRIM(LTRIM(@Array))
	declare @separator_position int
	-- almacena el valor de cada vuelta
	declare @array_value varchar(1000)
	set @array = @array + @separator
	-- recorre mientras haya un caracter separador
	while patindex('%' + @separator + '%' , @array) <> 0
	begin
		-- se ubica el separador
		set @separator_position = patindex('%' + @separator + '%' , @array)
		-- se extrae el valor
		set @array_value = substring(@array, 0, @separator_position)
		-- se acorta la cadena de caracteres de busqueda
		set @array = stuff(@array, 1, @separator_position, '')
		-- se almacena en la tabla de respuesta
		insert into @table_variable select @array_value as col1
	end
	RETURN
END






