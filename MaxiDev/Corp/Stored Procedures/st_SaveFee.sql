CREATE PROCEDURE [Corp].[st_SaveFee]
(
    @IdFee int, 
    @FeeName nvarchar(max), 
    @EnterByIdUser int, 
    @FeeDetails XML, 
    @IsSpanishLanguage INT,
    @IdFeeOut int output,        
    @HasError BIT OUT,
    @MessageOut varchar(max) OUT
)
as

--declaracion de variables
declare @IdFeeDetail int,
        @FromAmount money,
        @ToAmount money,
        @Fee money,
        @IsFeePercentage bit
DECLARE @DocHandle INT 
    
create table #FeeDetail
(
    IdFeeDetail int identity (1,1),
    FromAmount money,
    ToAmount money,
    Fee money,
    IsFeePercentage bit
)

--Inicializar Variables
Set @HasError=0
Select @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,77)   

BEGIN TRY
EXEC sp_xml_preparedocument @DocHandle OUTPUT,@FeeDetails 

insert into #FeeDetail
SELECT FromAmount,ToAmount,Fee,IsFeePercentage From OPENXML (@DocHandle, '/Fee/Detail',2) 
    WITH (      
        FromAmount money,
        ToAmount money,
        Fee money,
        IsFeePercentage bit
    )

EXEC sp_xml_removedocument @DocHandle 

if isnull(@IdFee,0)=0
begin
    --insertar fee
    insert into fee
        (FeeName,DateOfLastChange,EnterByIdUser)
    values
        (@FeeName,getdate(),@EnterByIdUser)

    set @IdFeeOut=scope_identity()
end
else
begin
    --actualizar fee
    update fee set 
        feename=@FeeName,
        EnterByIdUser=@EnterByIdUser,
        DateOfLastChange= getdate()
    where idfee=@IdFee

    set @IdFeeOut=@IdFee

    --depurar detalles
    delete from feedetail where idfee=@IdFee

    -- buscar agencias afectadas por el cambio de schema
	update pretransfer set isvalid=1, DateOfLastChange=GETDATE() 
	where idagentschema in(
        select idagentschema from agentschemadetail where idfee=@IdFeeOut)

end

WHILE exists (select top 1 1 from #FeeDetail)
BEGIN
    select top 1 @IdFeeDetail=IdFeeDetail,@FromAmount=FromAmount,@ToAmount=ToAmount,@Fee=Fee,@IsFeePercentage=IsFeePercentage from  #FeeDetail
    
    insert into feedetail
        (IdFee,FromAmount,ToAmount,Fee,DateOfLastChange,EnterByIdUser,IsFeePercentage)
    values
        (@IdFeeOut,@FromAmount,@ToAmount,@Fee,getdate(),@EnterByIdUser,@IsFeePercentage)
	
    delete  #FeeDetail where IdFeeDetail = @IdFeeDetail
end

end try

BEGIN CATCH
 Set @HasError=1                                                                                   
 Select @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,33)                                                                               
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_SaveFee]',Getdate(),@ErrorMessage)    
END CATCH

