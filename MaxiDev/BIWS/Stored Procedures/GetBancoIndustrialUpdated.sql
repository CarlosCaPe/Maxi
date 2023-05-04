
-- =============================================
-- Author:		Jorge Gomez 
-- Create date: 25/09/2019
-- Description:	Trae informacion de remesas que se encuentran pendiente para la notificacion de pago
-- M00103 - CR Banco Industrial, Notificación Pago
-- =============================================

CREATE PROCEDURE [BIWS].[GetBancoIndustrialUpdated]
(
@NumeroDeRemesa varchar(50),
@AgenciaPago varchar(50),
@MontoPagado varchar(50),
@FechaPago varchar(20),
@HoraPago varchar(6),
@DocumentoCobro nvarchar(50) = NULL
)
as


if (@MontoPagado is not null)
begin 

set @MontoPagado = cast(@MontoPagado as int)
set @MontoPagado = (select SUBSTRING(cast(@MontoPagado as varchar),0,len(@MontoPagado)-1) + '.' + SUBSTRING(cast(@MontoPagado as varchar),len(@MontoPagado)-1,len(@MontoPagado)-1))

end

--if (@DocumentoCobro != '' and @DocumentoCobro is not NULL)
--	BEGIN 
--		IF NOT EXISTS (SELECT 1 FROM [Transfer] WITH (NOLOCK) 
--		where ClaimCode = @NumeroDeRemesa AND BeneficiaryIdentificationNumber = @DocumentoCobro)
--			BEGIN
--				SELECT @DocumentoCobro FROM [Transfer] WITH (NOLOCK) 
--				where ClaimCode = @NumeroDeRemesa;
--				if(@DocumentoCobro is NULL)
--				begin
--					UPDATE [Transfer]
--					SET BeneficiaryIdentificationNumber = ''
--					WHERE ClaimCode = @NumeroDeRemesa
--				END
--			END
--	END
--ELSE
--	BEGIN
--	    If((SELECT BeneficiaryIdentificationNumber FROM [Transfer] WITH (NOLOCK) 
--			where ClaimCode = @NumeroDeRemesa) IS NULL)
--			UPDATE [Transfer]
--			SET BeneficiaryIdentificationNumber = ''
--			WHERE ClaimCode = @NumeroDeRemesa
--	END

declare @IdTransfer int
select @IdTransfer = IdTransfer from Transfer WITH(NOLOCK) WHERE ClaimCode = @NumeroDeRemesa
declare @DateOfPayment varchar (25)

set @DateOfPayment = SUBSTRING(@FechaPago, 5, 4) + '-' +SUBSTRING(@FechaPago, 3, 2)+  '-' + SUBSTRING(@FechaPago, 1, 2)+' '+SUBSTRING(@HoraPago, 1, 2) +':'+ SUBSTRING(@HoraPago, 3, 2) + ':'+ SUBSTRING(@HoraPago, 5, 4);
Select @DateOfPayment = convert(datetime, @DateOfPayment, 120) 

if exists (select 1 from Transfer with(nolock) where ClaimCode = @NumeroDeRemesa and IdStatus = 23)
begin
INSERT INTO [dbo].[TransferPayInfo] (IdTransfer,ClaimCode,IdGateway,DateOfPayment,BranchCode,BeneficiaryIdNumber,BeneficiaryIdType,IdBranch)
    VALUES (@IdTransfer,@NumeroDeRemesa,16,@DateOfPayment,@AgenciaPago,@DocumentoCobro,'',null)
end
else
begin 
INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('[BIWS].[GetBancoIndustrialUpdated]', GETDATE(), 'No se encontro la remesa en el status indicado')
end


SELECT
	REPLACE(CONVERT(VARCHAR(10), T.[DateOfTransfer], 103),'/','')           [FechaPago],
	REPLACE(CONVERT(VARCHAR(8), T.[DateOfTransfer], 108),':','')            [HoraPago],
	G.ReturnCode [CodigoRetorno],
	G.[Description] [Description]					
	FROM [dbo].[Transfer] T WITH (NOLOCK) 
	INNER JOIN Agent A WITH (NOLOCK) on A.IdAgent = T.IdAgent
	INNER JOIN GatewayReturnCode G WITH (NOLOCK) on G.IdStatusAction = T.IdStatus
	WHERE T.ClaimCode = @NumeroDeRemesa
	--AND REPLACE(CONVERT(VARCHAR(10), T.[DateOfTransfer], 103),'/','') = @FechaPago
	--AND REPLACE(CONVERT(VARCHAR(8), T.[DateOfTransfer], 108),':','') = @HoraPago
	--AND T.GatewayBranchCode = @AgenciaPago
	AND T.AmountInMN = @MontoPagado
--	AND T.BeneficiaryIdentificationNumber = @DocumentoCobro
	AND G.IdGatewayReturnCodeType = 3
	AND G.IdGateway = T.IdGateway 
	AND T.[IdGateway] = 16 AND [IdStatus] IN (23)

