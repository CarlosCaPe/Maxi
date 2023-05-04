create procedure [dbo].[st_UpdateServiceAttributes]  
  @Code nvarchar(128),
    @Key nvarchar(128),
    @Value nvarchar(max),
    @HasError bit out,      
    @Message varchar(max) out     
as  
/********************************************************************
<Author></Author>
<app>MaxiCorp/FidelityEXpress Api</app>
<Description>Insert/Update attributes of Service </Description>
<ChangeLog>

<log Date="07/09/2018" Author="snevarez">Creation</log>
</ChangeLog>
*********************************************************************/
BEGIN

    SET NOCOUNT ON;

    SET @HasError = 0;
    SET @Message =  '';

    Begin try

    
	   IF EXISTS(SELECT 1 FROM Services.ServiceAttributes WHERE UPPER([Code]) = UPPER(@Code) AND UPPER([Key]) = UPPER((@Key)))
	   BEGIN

		  UPDATE Services.ServiceAttributes
			 SET [Value] = @Value
		  WHERE UPPER([Code]) = UPPER(@Code) AND UPPER([Key]) = UPPER((@Key));

	   END
	   ELSE
	   BEGIN

		  INSERT INTO Services.ServiceAttributes ([Code],[Key],[Value]) VALUES (@Code, @Key, @Value);

	   END



    End Try
    begin catch
	   	  
	   Declare @ErrorMessage nvarchar(max);
	   Select @ErrorMessage=ERROR_MESSAGE();

	    SET @HasError = 1;
	   SET @Message = @ErrorMessage;

	   Insert into Soporte.InfoLogForStoreProcedure (StoreProcedure,InfoDate,InfoMessage)Values('st_UpdateServiceAttributes',Getdate(),'Code:' + Convert(VARCHAR(128),@Code) 	   
																											 + ',Key:' + Convert(VARCHAR(128),@Key) 
																											 + ',Value:' + Convert(VARCHAR(max),@Value) 
																											 + ',Error:' + @ErrorMessage);
    End Catch
    
END