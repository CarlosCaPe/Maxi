CREATE PROCEDURE [Corp].[st_SaveBankCommissionXML]
(
    @BankCommission xml,
    @IdUser int,
    @IsSpanishLanguage bit, 
    @HasError bit out,
    @MessageOUT varchar(max) out    
)
as
--declaracion de variables
DECLARE  @DocHandle INT 
declare  @i int
declare  @DateOfBankCommission datetime
declare  @OldValue float
declare  @NewValue float

Create Table #BankCommission
(
    Id int identity(1,1),	
	[DateOfBankCommission] [datetime],
	FactorOld float,
    FactorNew float
)

begin try

--Inicializar Variables
Set @HasError=0
Select @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,79)   

EXEC sp_xml_preparedocument @DocHandle OUTPUT,@BankCommission   

INSERT INTO #BankCommission ([DateOfBankCommission],FactorOld,FactorNew)
SELECT Date,OldValue,NewValue 
FROM OPENXML (@DocHandle, '/BankCommissions/BankCommission',2)
With (
		Date datetime,	    
	    OldValue float,
	    NewValue float
	)

EXEC sp_xml_removedocument @DocHandle 

while exists (select top 1 1 from #BankCommission)
	Begin

    select top 1 @i= Id, @DateOfBankCommission = dbo.[RemoveTimeFromDatetime]([DateOfBankCommission]), @OldValue=FactorOld, @NewValue=FactorNew
    from #BankCommission  

    --agregar configuracion actual

    exec [Corp].[st_SaveBankCommission] @DateOfBankCommission,@IdUser,@OldValue,@NewValue

    delete from #BankCommission  where id=@i

    end    

End Try
Begin Catch
 Set @HasError=1                                                                                   
 Select @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,80)  
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_SaveBankCommissionXML]',Getdate(),ERROR_MESSAGE())    
End Catch
