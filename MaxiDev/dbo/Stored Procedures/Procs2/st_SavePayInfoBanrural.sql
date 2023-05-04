
CREATE procedure [dbo].[st_SavePayInfoBanrural]   
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
        @dateofpayment =  CONVERT(DATETIME, dbo.GetValueFromGatewayResponse(@XmlValue,'fechaCobro') +' '+dbo.GetValueFromGatewayResponse(@XmlValue,'horacobro') ),
        @BranchCode = '',
        @BenIdNumber = upper(
                        case len(dbo.GetValueFromGatewayResponse(@XmlValue,'idBeneficiary'))
                            when 0 then ''
                            when 1 then ''
                            when 2 then ''
                            when 3 then ''
                            else
                                case (isnumeric(dbo.GetValueFromGatewayResponse(@XmlValue,'idBeneficiary')))
                                    when 1 then dbo.GetValueFromGatewayResponse(@XmlValue,'idBeneficiary')
                                    else
                                        substring(dbo.GetValueFromGatewayResponse(@XmlValue,'idBeneficiary'),5,len(dbo.GetValueFromGatewayResponse(@XmlValue,'idBeneficiary'))-4)
                                end
                        end
                        ),
        @BenIdType = upper(
                        case (isnumeric(dbo.GetValueFromGatewayResponse(@XmlValue,'idBeneficiary')))
                            when 1 then ''
                            else
                                substring(dbo.GetValueFromGatewayResponse(@XmlValue,'idBeneficiary'),1,3)
                            end
                        )

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
	declare @ErrorLine varchar(500)
    Select  @ErrorMessage=ERROR_MESSAGE()
	select @ErrorLine = CONVERT(varchar(500), ERROR_LINE())
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SavePayInfoBanrural: @XmlValue: ' + CONVERT(varchar(max),@XmlValue),Getdate(),@ErrorMessage + ', ErrorLine: ' + @ErrorLine)

end catch

end