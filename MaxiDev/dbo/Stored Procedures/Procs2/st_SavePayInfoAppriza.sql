CREATE procedure [dbo].[st_SavePayInfoAppriza]   
(
    @IdGateway  int,
    @idTransfer int,
    @Claimcode  nvarchar(max),    
    @XmlValue xml
)
as
begin


BEGIN TRY 
    --Declaracion de variables
    Declare @dateofpayment datetime
    Declare @BranchCode nvarchar(max)
    Declare @BenIdNumber nvarchar(max)
    Declare @BenIdType nvarchar(max)

    /*Obtener Informacion de Pago*/
    select   
        @dateofpayment =  convert(datetime,
                            substring(dbo.GetValueFromGatewayResponse(@XmlValue,'MovementDate'),1,4) + '/' + substring(dbo.GetValueFromGatewayResponse(@XmlValue,'MovementDate'),5,2) +'/'+substring(dbo.GetValueFromGatewayResponse(@XmlValue,'MovementDate'),7,2)+
                            + ' ' +
                            substring(dbo.GetValueFromGatewayResponse(@XmlValue,'MovementTime'),1,2) + ':' + substring(dbo.GetValueFromGatewayResponse(@XmlValue,'MovementTime'),3,2) + ':' + substring(dbo.GetValueFromGatewayResponse(@XmlValue,'MovementTime'),5,2) 
                           ),
        @BranchCode = upper(dbo.GetValueFromGatewayResponse(@XmlValue,'BranchNumber')),
        @BenIdNumber = upper(dbo.GetValueFromGatewayResponse(@XmlValue,'Number')),
        @BenIdType = upper(dbo.GetValueFromGatewayResponse(@XmlValue,'TypeCode'))

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
	
	IF @IdBranch =0 BEGIN
	select @IdBranch=[dbo].[funGetIdBranch] (Convert(VARCHAR,Convert(INT,@BranchCode)),@IdGateway,@IdPayer)
	END 

    insert into TransferPayInfo 
        (IdTransfer,ClaimCode,IdGateway,DateOfPayment,BranchCode,BeneficiaryIdNumber,BeneficiaryIdType,IdBranch)
    values
        (@IdTransfer,@ClaimCode,@IdGateway,@DateOfPayment,@BranchCode,@BenIdNumber,@BenIdType,@IdBranch)

end try

begin catch

    Declare @ErrorMessage nvarchar(max)
    Select  @ErrorMessage=ERROR_MESSAGE()
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SavePayInfoAppriza: @XmlValue: ' + CONVERT(varchar,@XmlValue),Getdate(),@ErrorMessage)

end catch

end


