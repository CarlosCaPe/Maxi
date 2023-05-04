
CREATE FUNCTION [dbo].[fun_GetIfInsertKycBasedOnRequestId]
(
       @idTransfer int      
)
RETURNS @infoKyc TABLE(isHolded bit NOT NULL, infoMeesage NVARCHAR(255))
AS
BEGIN  
       --DECLARE @result as bit
       DECLARE @documentType as int, @idCustomer as int, @expiration as datetime, @numRules as int, @numRequestIdRules as int, @transferAmount as money, @identificationnumber as nvarchar(MAX), @dateofexpiration as datetime
       
       --SET @result = 1    

       -- Add the T-SQL statements to compute the return value here  
       SELECT	@documentType = t.CustomerIdCustomerIdentificationType,
				@expiration = t.CustomerExpirationIdentification, 
				@idCustomer = t.IdCustomer,
				@transferAmount = CONVERT(money, t.AmountInDollars), @identificationnumber = t.CustomerIdentificationNumber, @dateofexpiration = t.CustomerExpirationIdentification           
       FROM [Transfer] t (NOLOCK)
       WHERE IdTransfer = @idTransfer
       
       select @numRules = COUNT(*) 
       FROM BrokenRulesByTransfer (NOLOCK)
       WHERE IdTransfer = @idTransfer   
       AND IdKycAction != 6

       select @numRequestIdRules = COUNT(*)
       FROM BrokenRulesByTransfer (NOLOCK)
       WHERE IdTransfer = @idTransfer
       AND IdKycAction = 1 --Request Id       

       
       --1 si hay alguna regla rota diferente a RequestId entonces retornamos para que inserte el estatus kychold
       IF(@numRules > @numRequestIdRules) 
       BEGIN
              INSERT @infoKyc(isHolded, infoMeesage)VALUES(1, 'There are other rules that require further review by a Compliance user.')
              Return
       END

       --2 Validamos el monto maximo para validar el request id
       DECLARE @amount as money
       SET @amount = null

       SELECT @amount = CONVERT(money, Value)
       FROM GlobalAttributes (NOLOCK)
       WHERE Name = 'KycHoldValidAmount'

       if(@transferAmount >= @amount)
       BEGIN
              INSERT @infoKyc(isHolded, infoMeesage)VALUES(1, 'A Compliance user needs to review this transaction because amount exceeds automatic threshold.')
              Return
       END           

       --3 SI YA EXPIRO ENTONCES VOLVEMOS A PEDIR EL DOC
       IF(CONVERT(date,GETDATE()) > @expiration)
       BEGIN
              INSERT @infoKyc(isHolded, infoMeesage)VALUES(1, 'The identification''s date is expired')
              Return
       END                  
              
	if not exists (Select 1 from TransferModify with(nolock)  where NewIdTRansfer = @idTransfer)
	Begin
       --4 Si ya existe un documento del mismo tipo no dejamos que caiga en kyc hold
	  DECLARE @Parameters NVARCHAR(MAX) = 
	   'idTransfer'+ CONVERT(VARCHAR(20),@idTransfer) + 
			 ',idCustomer' + CONVERT(VARCHAR(20),@idCustomer) +
			 ',documentType'+ CONVERT(VARCHAR(20),@documentType) +
			 ',identificationnumber' + CONVERT(VARCHAR(20),@identificationnumber) + 
			 ',dateofexpiration' + CONVERT(VARCHAR(50),@dateofexpiration);

       BEGIN                
				
                     --verificar si previamente existe una transferencia con el mismo tipo de doc para ese cliente y que haya sido revisada, si es asi entonces no cae en kyc   
                     IF 
					 EXISTS(
					 SELECT * 
                     FROM [Transfer] t (NOLOCK)
                     WHERE t.IdCustomer = @idCustomer AND t.CustomerIdCustomerIdentificationType = @documentType AND LTRIM(RTRIM(UPPER(t.CustomerIdentificationNumber))) = LTRIM(RTRIM(UPPER(@identificationnumber))) AND t.CustomerExpirationIdentification = @dateofexpiration AND t.ReviewKYC = 1)
                     OR EXISTS(
					 SELECT * 
                     FROM [TransferClosed] t (NOLOCK)
                     WHERE t.IdCustomer = @idCustomer AND t.CustomerIdCustomerIdentificationType = @documentType AND LTRIM(RTRIM(UPPER(t.CustomerIdentificationNumber))) = LTRIM(RTRIM(UPPER(@identificationnumber))) AND t.CustomerExpirationIdentification = @dateofexpiration AND t.ReviewKYC = 1)
                     BEGIN
					   INSERT @infoKyc(isHolded, infoMeesage)VALUES(0, 'KYC reviewed by the system.:' + @Parameters)				    
                        RETURN
                     END
                     ELSE 
                     BEGIN						 
						INSERT @infoKyc(isHolded, infoMeesage)VALUES(1, 'A Compliance user needs to confirm KYC Review and Physical Copy of documents.:' + @Parameters)
                        RETURN
                     END    
       END

       -- Return the result of the function
	End

       if (select count(1) from BrokenRulesByTransfer WHERE IdTransfer = @idTransfer)=1 and exists (select top 1 1 from BrokenRulesByTransfer where IdKycAction = 6 and IdTransfer = @idTransfer) 
       begin
        INSERT @infoKyc(isHolded, infoMeesage)VALUES(0, 'Don''t review KYC for Beneficiary ID')
        return
       end
       
       INSERT @infoKyc(isHolded, infoMeesage)VALUES(1, 'A Compliance user needs to confirm KYC Review and Physical Copy of documents.')
       RETURN
END
