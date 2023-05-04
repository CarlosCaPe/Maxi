CREATE PROCEDURE [Corp].[st_AddNoteToCallHistory]
(
     @IdAgent [int],
     @IdUser int,
     @IdCallStatus int,     
     @Note nvarchar(max),
     @IsSpanishLanguage INT,
     @HasError BIT OUT,
     @MessageOut NVARCHAR(max) OUT,
     @IsDirectMessage bit = null
)
as

/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="24/01/2018" Author="jmolina">Add with(nolock) And Schema</log>
</ChangeLog>
********************************************************************/

--Inicializacion de variables
SET @HasError=0
SET @MessageOut='Operation Successfull'

set @IsDirectMessage=isnull(@IsDirectMessage,0)

begin try
    insert into [dbo].callhistory 
        ([IdAgent],[IdUser],[IdCallStatus],[DateOfLastChange],[Note],IsDirectMessage)
    values
        (@IdAgent,@IdUser,@IdCallStatus,getdate(),@Note,@IsDirectMessage)
end try
BEGIN CATCH
  Set @HasError=1                                                                                   
 Select @MessageOut = 'Error in Note for Call History'
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_AddNoteToCallHistory]',Getdate(),@ErrorMessage)    
END CATCH

