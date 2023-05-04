
CREATE procedure [dbo].[st_SavePayInfoBancoUnion]   
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
                            substring(dbo.GetValueFromGatewayResponse(@XmlValue,'FechaActualizacionTransaccion'),7,4) + '/' + substring(dbo.GetValueFromGatewayResponse(@XmlValue,'FechaActualizacionTransaccion'),4,2) +'/'+substring(dbo.GetValueFromGatewayResponse(@XmlValue,'FechaActualizacionTransaccion'),1,2)+
                            + ' ' +
                            substring(dbo.GetValueFromGatewayResponse(@XmlValue,'HoraActualizacionRemesa'),1,2) + ':' + substring(dbo.GetValueFromGatewayResponse(@XmlValue,'HoraActualizacionRemesa'),4,2) + ':' + substring(dbo.GetValueFromGatewayResponse(@XmlValue,'HoraActualizacionRemesa'),7,2) 
                           ),
        
        @BranchCode = '',
        @BenIdNumber = '',
        @BenIdType = ''

    
   


    insert into TransferPayInfo 
        (IdTransfer,ClaimCode,IdGateway,DateOfPayment,BranchCode,BeneficiaryIdNumber,BeneficiaryIdType,IdBranch)
    values
        (@IdTransfer,@ClaimCode,@IdGateway,@DateOfPayment,@BranchCode,@BenIdNumber,@BenIdType,null)

end try
begin catch

    Declare @ErrorMessage nvarchar(max)
    Select  @ErrorMessage=ERROR_MESSAGE()
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SavePayInfoBancoUnion: @XmlValue: '+CONVERT(varchar,@XmlValue),Getdate(),@ErrorMessage)

end catch

end