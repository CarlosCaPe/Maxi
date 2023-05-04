
CREATE PROCEDURE [Soporte].[sp_AddProductToLunex]
	@Product varchar(max),
	@SKU nvarchar(20),
	@Country nvarchar(max),
	@Margin money,
	@Confirm bit=0
AS 

/********************************************************************
<Author>Juan Diego Arellano</Author>
<app>---</app>
<Description>Procedimiento almacenado que permite agregar nuevos productos de Lunex</Description>

<ChangeLog>
<log Date="08/01/2019" Author="jdarellano">Creación</log>
</ChangeLog>
*********************************************************************/

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

Begin Try
	declare @IdCountry int

	if exists (select 1 from Operation.Country with (nolock) where CountryName=@Country)
	begin
		set @IdCountry=(select IdCountry from Operation.Country with (nolock) where CountryName=@Country)
		select @IdCountry as IdCountry
	end

	else
	begin
		select 'El país '+CAST(@Country as varchar)+' no existe, favor de validar'
		Return
	end
		

	begin transaction
		if exists (select 1 from Operation.Carrier with (nolock) where CarrierName=@Product)
		begin
			select * from Operation.Carrier with (nolock) where CarrierName=@Product
		end

		else
		begin
			select 'Carrier no existe, será agregado' as [Result]

			insert into Operation.Carrier
				select 1,37,3,@Product

			select * from Operation.Carrier with (nolock) where CarrierName=@Product
		end

		if not exists (select 1 from lunex.Product with (nolock) where SKU=@SKU and Product=@Product and IdCountry=@IdCountry)
		begin
			Insert into lunex.Product
				select @SKU,@Product,IdCarrier,@IdCountry,1,37,@Margin
				from Operation.Carrier with (nolock)
				where CarrierName=@Product

			select * from lunex.Product with (nolock) where SKU=@SKU and Product=@Product
		end

		else
		begin
			select 'El producto ya existe, favor de validar' as Result
			
			select * from lunex.Product with (nolock) where SKU=@SKU and Product=@Product
		end

	if (@Confirm=0)
		rollback
	else
		commit
End Try
Begin Catch
	DECLARE @ErrorMessage varchar(max)                                                                 
    Select @ErrorMessage=ERROR_MESSAGE()   
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Soporte.sp_AddProductToLunex',Getdate(),@ErrorMessage)
End Catch

