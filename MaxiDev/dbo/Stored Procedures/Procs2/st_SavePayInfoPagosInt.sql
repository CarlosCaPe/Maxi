
CREATE procedure [dbo].[st_SavePayInfoPagosInt]   
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
                            substring(dbo.GetValueFromGatewayResponse(@XmlValue,'Field2'),1,4) + '/' + substring(dbo.GetValueFromGatewayResponse(@XmlValue,'Field2'),5,2) +'/'+substring(dbo.GetValueFromGatewayResponse(@XmlValue,'Field2'),7,2)+
                            + ' ' +
                            substring(dbo.GetValueFromGatewayResponse(@XmlValue,'Field3'),1,2) + ':' + substring(dbo.GetValueFromGatewayResponse(@XmlValue,'Field3'),3,2) + ':' + substring(dbo.GetValueFromGatewayResponse(@XmlValue,'Field3'),5,2) 
                           ),
        @BranchCode = '',
        @BenIdNumber = '',
        @BenIdType = ''

    /*
    select @idTransfer idTransfer,
           @Claimcode Claimcode,
           @IdGateway IdGateway,
           @dateofpayment dateofpayment,
           @BranchCode BranchCode,
           @BenIdNumber BenIdNumber,
           @BenIdType BenIdType
    */

    insert into TransferPayInfo 
        (IdTransfer,ClaimCode,IdGateway,DateOfPayment,BranchCode,BeneficiaryIdNumber,BeneficiaryIdType,IdBranch)
    values
        (@IdTransfer,@ClaimCode,@IdGateway,@DateOfPayment,@BranchCode,@BenIdNumber,@BenIdType,null)

end try

begin catch

    Declare @ErrorMessage nvarchar(max)
    Select  @ErrorMessage=ERROR_MESSAGE()
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SavePayInfoPagosInt: @XmlValue: ' + CONVERT(varchar,@XmlValue),Getdate(),@ErrorMessage)

end catch

end