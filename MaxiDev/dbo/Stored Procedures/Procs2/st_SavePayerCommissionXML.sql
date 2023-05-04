--<PayerCommissions>
--   <PayerCommission>
--        <IdPayer>1</IdPayer>
--        <IdPaymentType>1</IdPaymentType>
--        <Date>01/01/2014</Date>        
--        <OldValue>0.14</OldValue>
--        <NewValue>1</NewValue>
--   </PayerCommission>
--</PayerCommissions>

create procedure st_SavePayerCommissionXML
(
    @PayerCommission xml,
    @IdUser int,
    @IsSpanishLanguage bit, 
    @HasError bit out,
    @MessageOUT varchar(max) out    
)
as
--declaracion de variables
DECLARE  @DocHandle INT 
declare  @i int
declare  @IdPayer int
declare  @IdPaymentType int
declare  @Date datetime 
declare  @OldValue money
declare  @NewValue money

Create Table #PayerCommission
(
    Id int identity(1,1),
	IdPayer int,
	IdPaymentType int,
	Date datetime,    
	OldValue money,
	NewValue money
)

begin try

--Inicializar Variables
Set @HasError=0
Select @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,79)   

EXEC sp_xml_preparedocument @DocHandle OUTPUT,@PayerCommission   

INSERT INTO #PayerCommission (IdPayer, IdPaymentType,Date,OldValue,NewValue)
SELECT IdPayer, IdPaymentType,dbo.RemoveTimeFromDatetime(Date),OldValue,NewValue 
FROM OPENXML (@DocHandle, '/PayerCommissions/PayerCommission',2)
With (
		IdPayer int,
	    IdPaymentType int,
	    Date datetime,    
	    OldValue money,
	    NewValue money
	)

EXEC sp_xml_removedocument @DocHandle 

--select * from #PayerCommission

while exists (select top 1 1 from #PayerCommission)
	Begin

    select top 1 @i= Id, @IdPayer = IdPayer, @IdPaymentType=IdPaymentType, @Date=date, @OldValue=OldValue, @NewValue=NewValue
    from #PayerCommission

    exec st_SavePayerCommission @Idpayer,@IdPaymentType,@Date,@IdUser,@OldValue,@NewValue

    delete from #PayerCommission  where id=@i

    end    

End Try
Begin Catch
 Set @HasError=1                                                                                   
 Select @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,80)  
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SavePayerCommissionXML',Getdate(),ERROR_MESSAGE())    
End Catch