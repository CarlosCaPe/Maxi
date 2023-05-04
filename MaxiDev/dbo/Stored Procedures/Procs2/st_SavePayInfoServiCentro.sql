
CREATE procedure [dbo].[st_SavePayInfoServiCentro]   
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
        @dateofpayment =  convert(datetime,dbo.GetValueFromGatewayResponse(@XmlValue,'Fecha'))+' '+convert(datetime,dbo.GetValueFromGatewayResponse(@XmlValue,'Hora')),
        @BranchCode = '',
        @BenIdNumber = upper(dbo.GetValueFromGatewayResponse(@XmlValue,'Identificacion')),
        @BenIdType = upper(dbo.GetValueFromGatewayResponse(@XmlValue,'TipoIdentificacion'))

        set @BenIdType = case (@BenIdType)
                            when 'CC' THEN 'CEDULA CIUDADANA'
                            when 'CD' THEN 'CEDULA CIUDADANA'
                            when 'CED' THEN 'CEDULA CIUDADANA'
                            when 'CR' THEN 'CEDULA DE RESIDENTE'
                            when 'DI' THEN 'DOCUMENTO DE IDENTIDAD'
                            when 'LC' THEN 'DOCUMENTO DE IDENTIDAD'
                            when 'PA' THEN 'PASAPORTE'
                            when 'TI' THEN 'OTRO DOCUMENTO'
                            ELSE
                                @BenIdType
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
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SavePayInfoServiCentro: @XmlValue: ' + CONVERT(varchar,@XmlValue),Getdate(),@ErrorMessage)

end catch

end