
CREATE procedure [dbo].[st_SavePayInfoGirosLatinos]   
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
        @dateofpayment =  convert(datetime,dbo.GetValueFromGatewayResponse(@XmlValue,'Date')),
        @BranchCode = upper(dbo.GetValueFromGatewayResponse(@XmlValue,'OfficeCode')),
        @BenIdNumber = upper(dbo.GetValueFromGatewayResponse(@XmlValue,'ReceiverIdentification')),
        @BenIdType = upper(dbo.GetValueFromGatewayResponse(@XmlValue,'ReceiverIdentificationType'))

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
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SavePayInfoGirosLatinos: @XmlValue: ' + CONVERT(varchar,@XmlValue),Getdate(),@ErrorMessage)

end catch

end