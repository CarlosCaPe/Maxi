create procedure st_ReIngresarSB
(
    @IdTransfer int
)
as  
    declare @IdCountryCurrency int
    declare @EnterByIdUser int
    declare @IdAgent int
    declare @IdPayer int
    declare @CustomerName nvarchar(max)
    declare @CustomerFirstLastName nvarchar(max)
    declare @CustomerSecondLastName nvarchar(max)
    declare @BeneficiaryName nvarchar(max)
    declare @BeneficiaryFirstLastName nvarchar(max)
    declare @BeneficiarySecondLastName nvarchar(max)
    declare @IdPaymentType int
    declare @TotalAmountToCorporate money
    declare @Folio int
    declare @AgentCommissionExtra money
    declare @AgentCommissionOriginal money
    declare @AgentCommissionEditedByCommissionSlider money
    declare @AgentCommissionEditedByExchangeRateSlider money

select 
    @EnterByIdUser = EnterByIdUser,
    @IdAgent = IdAgent, 
    @IdPayer = IdPayer,
    @CustomerName = CustomerName,
    @CustomerFirstLastName = CustomerFirstLastName,
    @CustomerSecondLastName = CustomerSecondLastName,
    @BeneficiaryName = BeneficiaryName,
    @BeneficiaryFirstLastName = BeneficiaryFirstLastName,
    @BeneficiarySecondLastName = BeneficiarySecondLastName,    
    @IdPaymentType = IdPaymentType,
    @TotalAmountToCorporate = TotalAmountToCorporate,
    @Folio = Folio,    
    @IdCountryCurrency = IdCountryCurrency,
    @AgentCommissionExtra = AgentCommissionExtra,
    @AgentCommissionOriginal = AgentCommissionOriginal,
    @AgentCommissionEditedByCommissionSlider =  ModifierCommissionSlider,
    @AgentCommissionEditedByExchangeRateSlider = ModifierExchangeRateSlider
from transfer where IdStatus=1 and idtransfer=@IdTransfer


 --service broker
 -----------------------------------------------------------------------------------------------------------------
 declare @Country nvarchar(max)

 select @Country=c.CountryCode from countrycurrency  cc
 join country c on cc.IdCountry=c.IdCountry
 where idcountrycurrency=@IdCountryCurrency

 DECLARE
    @conversation uniqueidentifier,
    @msg xml

set @msg =(
SELECT 
    @IdTransfer IdTransfer,
    1 IdTransferStatus,
    @EnterByIdUser EnterByIdUser,
    @IdAgent IdAgent, 
    @IdPayer IdPayer,
    @CustomerName CustomerName,
    @CustomerFirstLastName CustomerFirstLastName,
    @CustomerSecondLastName CustomerSecondLastName,
    @BeneficiaryName BeneficiaryName,
    @BeneficiaryFirstLastName BeneficiaryFirstLastName,
    @BeneficiarySecondLastName BeneficiarySecondLastName,    
    @IdPaymentType IdPaymentType,
    @TotalAmountToCorporate Amount,
    @Folio Reference,    
    @Country Country,
    @AgentCommissionExtra AgentCommissionExtra,
    @AgentCommissionOriginal AgentCommissionOriginal,
    @AgentCommissionEditedByCommissionSlider ModifierCommissionSlider,
    @AgentCommissionEditedByExchangeRateSlider ModifierExchangeRateSlider
FOR XML PATH ('Transfer'),ROOT ('OriginDataType'))

select @msg

--- Start a conversation:
BEGIN DIALOG @conversation
    FROM SERVICE [//Maxi/Transfer/OriginSenderService]
    TO SERVICE N'//Maxi/Transfer/OriginRecipService'
    ON CONTRACT [//Maxi/Transfer/OriginContract]
    WITH ENCRYPTION=OFF;

--- Send the message
SEND ON CONVERSATION @conversation
    MESSAGE TYPE [//Maxi/Transfer/OriginDataType]
    (@msg);

insert into dbo.SBSendOriginMessageLog (ConversationID,MessageXML) values (@conversation,@msg)

--select idtransfer,ClaimCode,IdStatus from transfer where IdTransfer=@IdTransfer