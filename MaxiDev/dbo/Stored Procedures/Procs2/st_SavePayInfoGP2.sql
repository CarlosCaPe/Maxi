
CREATE procedure [dbo].[st_SavePayInfoGP2]   
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
     /*Obtener Informacion de Pago*/
    select   
        @dateofpayment = dbo.GetValueFromGatewayResponse(@XmlValue,'PaymentDate')+' '+SUBSTRING ( dbo.GetValueFromGatewayResponse(@XmlValue,'PaymentTime') ,1 , 2 )  +':'+SUBSTRING ( dbo.GetValueFromGatewayResponse(@XmlValue,'PaymentTime') ,3 , 2 )+':'+SUBSTRING ( dbo.GetValueFromGatewayResponse(@XmlValue,'PaymentTime') ,5 , 2 ),
        @BranchCode = upper(dbo.GetValueFromGatewayResponse(@XmlValue,'PayingAgentNumber')),
        @BenIdNumber = upper(dbo.GetValueFromGatewayResponse(@XmlValue,'IDNumber')),
        @BenIdType = upper((dbo.GetValueFromGatewayResponse(@XmlValue,'IDTypeCode')))

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

    select @idpayer=idpayer from transferclosed with(nolock) where idtransferclosed=@idTransfer

    select @IdBranch=[dbo].[funGetIdBranch] (@BranchCode,@IdGateway,@IdPayer)

    insert into TransferPayInfo 
        (IdTransfer,ClaimCode,IdGateway,DateOfPayment,BranchCode,BeneficiaryIdNumber,BeneficiaryIdType,IdBranch)
    values
        (@IdTransfer,@ClaimCode,@IdGateway,@DateOfPayment,@BranchCode,@BenIdNumber,@BenIdType,@IdBranch)

end try

begin catch

    Declare @ErrorMessage nvarchar(max)
    Select  @ErrorMessage=ERROR_MESSAGE()
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SavePayInfoGP: @XmlValue: ' + CONVERT(varchar,@XmlValue),Getdate(),@ErrorMessage)

end catch

end