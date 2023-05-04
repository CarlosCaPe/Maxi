
CREATE procedure [dbo].[st_SavePayInfoUniteller]
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
        @dateofpayment =  convert(datetime,dbo.GetValueFromGatewayResponseUniteller(@XmlValue,'PAYMENTLOCALTIME')),
        @BranchCode = upper(dbo.GetValueFromGatewayResponseUniteller(@XmlValue,'PAYINGAGENTBRANCHCODE')),
        @BenIdNumber = upper(dbo.GetValueFromGatewayResponseUniteller(@XmlValue,'BENEIDENTIFICATIONNUMBER')),
        @BenIdType = upper(dbo.GetValueFromGatewayResponseUniteller(@XmlValue,'BENEIDENTIFICATIONTYPE'))

    /*
    select @idTransfer idTransfer,
           @Claimcode Claimcode,
           @IdGateway IdGateway,
           @dateofpayment dateofpayment,
           @BranchCode BranchCode,
           @BenIdNumber BenIdNumber,
           @BenIdType BenIdType
    */

    set @BenIdType = case 
                        when @BenIdType='001' then '001-PASAPORTE'
                        when @BenIdType='002' then '002-LICENCIA'
                        when @BenIdType='003' then '003-CREDENCIAL ELECTOR'
                        when @BenIdType='004' then '004-CEDULA DE IDENTIDAD'
                        when @BenIdType='005' then '005-NUMERO ID FISCAL'
                        when @BenIdType='006' then '006-ID CONSULAR'
                        when @BenIdType='007' then '007-ID MILITAR'
                        when @BenIdType='099' then '099-OTRO'
                        else ''
                     end

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
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SavePayInfoUniteller',Getdate(),@ErrorMessage + ', Parameters: @XmlValue: ' + CONVERT(varchar(max),@XmlValue) + ', ErrorLine: ' + CONVERT(VARCHAR,ERROR_LINE()))

end catch

end