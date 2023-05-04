CREATE PROCEDURE [Corp].[st_SaveCommission]
(
    @IdCommission int,
    @CommissionName nvarchar(max), 
    @EnterByIdUser int, 
    @CommissionDetails XML, 
    @IsSpanishLanguage INT,
    @IdCommissionOutput int output,
    @HasError BIT OUT,
    @MessageOut varchar(max) OUT
)
as

--declaracion de variables
declare @IdCommissionDetail int,
        @FromAmount money,
        @ToAmount money,
        @AgentCommissionInPercentage money,
        @CorporateCommissionInPercentage money,
        @ExtraAmount money
DECLARE @DocHandle INT 

create table #commissiondetail
(
    IdCommissionDetail int identity(1,1),
    FromAmount money,
    ToAmount money,
    AgentCommissionInPercentage money,
    CorporateCommissionInPercentage money,
    ExtraAmount money
)

--Inicializar Variables
Set @HasError=0
Select @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,78)  

BEGIN TRY
EXEC sp_xml_preparedocument @DocHandle OUTPUT,@CommissionDetails 

insert into #commissiondetail
SELECT FromAmount,ToAmount,AgentCommissionInPercentage,CorporateCommissionInPercentage,ExtraAmount From OPENXML (@DocHandle, '/Commission/Detail',2) 
    WITH (      
        FromAmount money,
        ToAmount money,
        AgentCommissionInPercentage money,
        CorporateCommissionInPercentage money,
        ExtraAmount money
    )

EXEC sp_xml_removedocument @DocHandle

if isnull(@IdCommission,0)=0
begin
    --insertar commission    
    insert into commission
        (CommissionName,DateOfLastChange,EnterByIdUser)
    values
        (@CommissionName,getdate(),@EnterByIdUser)

    set @IdCommissionOutput=scope_identity()
end
else
begin
    --actualizar fee
    update commission set 
        CommissionName=@CommissionName,
        EnterByIdUser=@EnterByIdUser,
        DateOfLastChange= getdate()
    where IdCommission=@IdCommission

    set @IdCommissionOutput=@IdCommission

    --depurar detalles
    delete from commissiondetail where IdCommission=@IdCommission

    -- buscar agencias afectadas por el cambio de schema
    update pretransfer set isvalid=1, DateOfLastChange=GETDATE() 
	where idagentschema in(
        select idagentschema from agentschemadetail where IdCommission=@IdCommissionOutput)    

end

WHILE exists (select top 1 1 from #commissiondetail)
BEGIN
    select top 1 
        @IdCommissionDetail = IdCommissionDetail,
        @FromAmount = FromAmount,
        @ToAmount = ToAmount,
        @AgentCommissionInPercentage = AgentCommissionInPercentage,
        @CorporateCommissionInPercentage = CorporateCommissionInPercentage,
        @ExtraAmount = ExtraAmount from  #commissiondetail
    
    --select * from commissiondetail
    insert into commissiondetail
        (IdCommission,FromAmount,ToAmount,AgentCommissionInPercentage,CorporateCommissionInPercentage,DateOfLastChange,EnterByIdUser,ExtraAmount)
    values
        (@IdCommissionOutput,@FromAmount,@ToAmount,@AgentCommissionInPercentage,@CorporateCommissionInPercentage,getdate(),@EnterByIdUser,@ExtraAmount)

    delete  #commissiondetail where IdCommissionDetail = @IdCommissionDetail
end

end try

BEGIN CATCH
 Set @HasError=1                                                                                   
 Select @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,33)                                                                               
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_SaveCommission]',Getdate(),@ErrorMessage)    
END CATCH

