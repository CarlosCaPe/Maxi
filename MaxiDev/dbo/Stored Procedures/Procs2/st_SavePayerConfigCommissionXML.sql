
CREATE PROCEDURE [dbo].[st_SavePayerConfigCommissionXML]
(
    @PayerConfigCommission xml,
    @IdUser int,
    @IsSpanishLanguage bit, 
    @HasError bit out,
    @MessageOUT varchar(max) out    
)
as
--declaracion de variables
DECLARE  @DocHandle INT 
declare  @i int
declare  @IdPayerConfig int
declare  @Date datetime 
declare  @OldValue money
declare  @NewValue money

Create Table #PayerConfigCommission
(
    Id int identity(1,1),
	IdPayerConfig int,	
	Date datetime,    
	OldValue money,
	NewValue money
)

begin try

--Inicializar Variables
Set @HasError=0
Select @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,79)   

EXEC sp_xml_preparedocument @DocHandle OUTPUT,@PayerConfigCommission   

INSERT INTO #PayerConfigCommission (IdPayerConfig, Date,OldValue,NewValue)
SELECT IdPayerConfig, dbo.RemoveTimeFromDatetime(Date),OldValue,NewValue 
FROM OPENXML (@DocHandle, '/PayerConfigCommissions/PayerConfigCommission',2)
With (
		IdPayerConfig int,	    
	    Date datetime,    
	    OldValue money,
	    NewValue money
	)

EXEC sp_xml_removedocument @DocHandle 

--select * from #PayerConfigCommission

while exists (select top 1 1 from #PayerConfigCommission)
	Begin

    select top 1 @i= Id, @IdPayerConfig = IdPayerConfig, @Date=date, @OldValue=OldValue, @NewValue=NewValue
    from #PayerConfigCommission

    exec st_SavePayerConfigCommission @IdPayerConfig,@Date,@IdUser,@OldValue,@NewValue

    delete from #PayerConfigCommission  where id=@i

    end    

End Try
Begin Catch
 Set @HasError=1                                                                                   
 Select @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,80)  
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SavePayerConfigCommissionXML',Getdate(),ERROR_MESSAGE())    
End Catch
