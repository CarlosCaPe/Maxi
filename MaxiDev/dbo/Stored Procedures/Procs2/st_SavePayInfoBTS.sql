
CREATE procedure [dbo].[st_SavePayInfoBTS]   
(
    @IdGateway  int,
    @idTransfer int,
    @Claimcode  nvarchar(max),    
    @XmlValue xml
)
as
begin

begin try
    --Declaracion de variables
    Declare @dateofpayment datetime
    Declare @BranchCode nvarchar(max)
    Declare @BenIdNumber nvarchar(max)
    Declare @BenIdType nvarchar(max)

    /*Obtener Informacion de Pago*/
    select   
        @dateofpayment =  convert(datetime,
                            substring(dbo.GetValueFromGatewayResponse(@XmlValue,'MovementDt'),1,4) + '/' + substring(dbo.GetValueFromGatewayResponse(@XmlValue,'MovementDt'),5,2) +'/'+substring(dbo.GetValueFromGatewayResponse(@XmlValue,'MovementDt'),7,2)+
                            + ' ' +
                            substring(dbo.GetValueFromGatewayResponse(@XmlValue,'MovementTm'),1,2) + ':' + substring(dbo.GetValueFromGatewayResponse(@XmlValue,'MovementTm'),3,2) + ':' + substring(dbo.GetValueFromGatewayResponse(@XmlValue,'MovementTm'),5,2) 
                           ),
        @BranchCode = upper(dbo.GetValueFromGatewayResponse(@XmlValue,'AgentBranchSd')),
        @BenIdNumber = upper(dbo.GetValueFromGatewayResponse(@XmlValue,'IdentifNm')),
        @BenIdType = upper(dbo.GetValueFromGatewayResponse(@XmlValue,'IdentifTypeCd'))

    /*
    select @idTransfer idTransfer,
           @Claimcode Claimcode,
           @IdGateway IdGateway,
           @dateofpayment dateofpayment,
           @BranchCode BranchCode,
           @BenIdNumber BenIdNumber,
           @BenIdType BenIdType
    */

    declare @IdBranch int
    declare @IdPayer int

    select @idpayer=idpayer from transfer with(nolock) where idtransfer=@idTransfer

    select @IdBranch=[dbo].[funGetIdBranch] (@BranchCode,@IdGateway,@IdPayer)

    insert into TransferPayInfo 
        (IdTransfer,ClaimCode,IdGateway,DateOfPayment,BranchCode,BeneficiaryIdNumber,BeneficiaryIdType,IdBranch)
    values
        (@IdTransfer,@ClaimCode,@IdGateway,@DateOfPayment,@BranchCode,@BenIdNumber,@BenIdType,@IdBranch)

end try

begin catch

    Declare @ErrorMessage nvarchar(max)
    Select  @ErrorMessage=ERROR_MESSAGE()
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SavePayInfoBTS: @XmlValue: ' + CONVERT(varchar,@XmlValue),Getdate(),@ErrorMessage)

end catch

end