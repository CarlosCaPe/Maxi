
CREATE procedure [dbo].[st_SavePayInfoBancoIndustrial]   
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
                            substring(dbo.GetValueFromGatewayResponse(@XmlValue,'FechaPagoRemesa'),7,4) + '/' + substring(dbo.GetValueFromGatewayResponse(@XmlValue,'FechaPagoRemesa'),4,2) +'/'+substring(dbo.GetValueFromGatewayResponse(@XmlValue,'FechaPagoRemesa'),1,2)+
                            + ' ' +
                            substring(dbo.GetValueFromGatewayResponse(@XmlValue,'HoraPagoRemesa'),1,2) + ':' + substring(dbo.GetValueFromGatewayResponse(@XmlValue,'HoraPagoRemesa'),4,2) + ':' + substring(dbo.GetValueFromGatewayResponse(@XmlValue,'HoraPagoRemesa'),7,2) 
                           ),
        --@BranchCode = dbo.GetValueFromGatewayResponse(@XmlValue,'SucursaldePago'),
        @BranchCode = '',
        @BenIdNumber = dbo.GetValueFromGatewayResponse(@XmlValue,'IdentificacionBeneficiario'),
        @BenIdType = case (dbo.GetValueFromGatewayResponse(@XmlValue,'TipodeIdentificacion'))
                        when '1' then 'CEDULA'
                        when '2' then 'PASAPORTE'
                        when '3' then 'DPI'
                        end

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
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SavePayInfoBancoIndustrial: @XmlValue: ' + CONVERT(varchar,@XmlValue),Getdate(),@ErrorMessage)

end catch

end