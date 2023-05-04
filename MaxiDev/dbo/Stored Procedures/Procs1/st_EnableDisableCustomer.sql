CREATE procedure [dbo].[st_EnableDisableCustomer]
    @IdCustomer int,    
    @EnterByIdUser int,    
    @IdGenericStatus int,
    @IdLenguage int,
    @HasError bit out,
    @ResultMessage nvarchar(max) out,
	@IdElasticCustomer varchar(max) output /*Optimizacion Agente*/
as
/********************************************************************
<Author>Unknow</Author>
<app>Agent</app>
<Description></Description>

<ChangeLog>
<log Date="18/01/2018" Author="azavala">Optimizacion Agente : Se agregaron parametros de Salida necesarios para actualizacion en ElasticSearch</log>
</ChangeLog>

*********************************************************************/
Begin try

if @IdLenguage is null 
    set @IdLenguage=2

    exec st_SaveCustomerMirror @IdCustomer

	UPDATE [dbo].[CardVIP] SET [IdGenericStatus] = @IdGenericStatus WHERE IdCustomer = @IdCustomer

    UPDATE [dbo].[Customer]
					   SET 
						   [IdGenericStatus] = @IdGenericStatus						  
                          ,[DateOfLastChange] = getdate()
					      ,[EnterByIdUser] = @EnterByIdUser
					 WHERE IdCustomer = @IdCustomer
    set @HasError =0
	set @IdElasticCustomer = (select idElasticCustomer from Customer with (nolock) where IdCustomer = @IdCustomer) /*Optimizacion Agente*/
    SELECT @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE10')

End try
Begin Catch
		 Declare @ErrorMessage nvarchar(max)         
		 Select @ErrorMessage=ERROR_MESSAGE()        
		 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[st_EnableDisableCustomer]',Getdate(),@ErrorMessage) 
		 set @HasError =1		
		 set @IdElasticCustomer = '' /*Optimizacion Agente*/
         SELECT @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE11')		
End catch
