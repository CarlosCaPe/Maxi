
CREATE procedure [dbo].[st_SavePayInfoIntermex]
(
    @IdGateway  int,
    @idTransfer int,
    @Claimcode  nvarchar(max),    
    @XmlValue xml
)
as
begin
/********************************************************************
<Author>--</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="09/07/2019" Author="jgsoto" Name="#1">Se modifica el campo de donde se obtiene la fecha de Pago/Cancelación</log>
</ChangeLog>
*********************************************************************/
begin try
    --Declaracion de variables
    Declare @dateofpayment datetime
    Declare @BranchCode nvarchar(max)
    Declare @BenIdNumber nvarchar(max)
    Declare @BenIdType nvarchar(max)

    /*Obtener Informacion de Pago*/
    select   
        @dateofpayment =  convert(datetime,dbo.GetValueFromGatewayResponse(@XmlValue,'dtFechaPagoCancel')), --#1
		--@dateofpayment =  convert(datetime,dbo.GetValueFromGatewayResponse(@XmlValue,'dtFechaRecepcion')),
        @BranchCode = upper(dbo.GetValueFromGatewayResponse(@XmlValue,'iIdDestinoPago')),
        @BenIdNumber = upper(dbo.GetValueFromGatewayResponse(@XmlValue,'vIdentificacion')),
        @BenIdType = upper(dbo.GetValueFromGatewayResponse(@XmlValue,'vTipoIdentif'))

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
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SavePayInfoIntermex: @XmlValue: ' + CONVERT(varchar,@XmlValue),Getdate(),@ErrorMessage)

end catch

end