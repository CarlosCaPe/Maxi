create procedure [dbo].[st_AssignMaxiCollection]
(
    @IdUser INT,
    @IdAgents XML,
    @IsSpanishLanguage INT,    
    @HasError BIT OUT,
    @MessageOut varchar(max) OUT
)
AS
if @IdUser=0 
    begin
        set @IdUser=null
    end


declare @CurrentDate datetime
DECLARE @DocHandle INT 
Declare @IdAssign int
Declare @IdAssignTop int
declare @IdAgent int


create table #Assign
(
    IdAssign int identity (1,1),
    IdAgent int,
)

set @CurrentDate=[dbo].[RemoveTimeFromDatetime](getdate())

--Inicializar Variables
Set @HasError=0
--maxi merge
Select @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,79)   
--Select @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,72)   

BEGIN TRY
EXEC sp_xml_preparedocument @DocHandle OUTPUT,@IdAgents 

insert into #Assign
SELECT value From OPENXML (@DocHandle, '/root/value',2) 
    WITH (      
        value INT 'text()'
    )

EXEC sp_xml_removedocument @DocHandle 

--SELECT @IdAssign = 1,@IdAssignTop=MAX(IdAssign) FROM #Assign

WHILE exists (select top 1 1 from #Assign)
BEGIN
    
    select top 1 @IdAgent=IdAgent from  #Assign
    
    
    if exists(select top 1 1 from MaxiCollectionAssign where IdAgent=@IdAgent and DateOfAssign=@CurrentDate)    
        update MaxiCollectionAssign set iduser=@IdUser where IdAgent=@IdAgent and DateOfAssign=@CurrentDate            
    else    
        insert into MaxiCollectionAssign (Idagent,Iduser,DateOfAssign) values (@IdAgent,@IdUser,@CurrentDate)    
    
    --select @IdAssign,@IdAgent agent,@IdUser users
	delete  #Assign where IdAgent = @IdAgent
end

end try

BEGIN CATCH
 Set @HasError=1                                                                                   
 Select @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,33)                                                                               
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_AssignMaxiCollection',Getdate(),@ErrorMessage)    
END CATCH