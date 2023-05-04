/********************************************************************
<Author> JVelarde </Author>
<app> WebApi </app>
<Description> Sp que obtiene el detalle de una transferencia IdTransfer </Description>

<ChangeLog>
<log Date="09/08/2017" Author="JVelarde">Creation</log>
</ChangeLog>
<ChangeLog>
<log Date="20/11/2019" Author="Ulises García"></log>
<Description> se agrega funcionalidad para ver si el usuario tiene permiso para ver la commision de la transacción</Description>
</ChangeLog>
*********************************************************************/

CREATE PROCEDURE [MaxiMobile].[st_GetTransferByIdTransfer] --9990087, 9251
(
	@IdTransfer INT,
	@IdUser int = null
)
as
Begin Try 

--dia de cobro
declare @TimeForClaimTransfer varchar(50)
set @TimeForClaimTransfer = [dbo].[GetGlobalAttributeByName]('TimeForClaimTransfer') 

declare @DayOfWeek int
set @DayOfWeek = [dbo].[GetDayOfWeek](getdate())

DECLARE @InterCode NVARCHAR(MAX) = [dbo].[GetGlobalAttributeByName]('InfiniteCountryCode')

IF EXISTS(SELECT 1 FROM [TRANSFER] WHERE IdTransfer=@IdTransfer) 
BEGIN
		SELECT DISTINCT 
			A.IdAgent,      
			T.IdTransfer,                              
			T.IdStatus,      
			T.ClaimCode,                            
			T.DateOfTransfer,                            
			A.AgentCode,                            
			A.AgentName,                            
			T.Folio,   
			T.IdCustomer,                               
			T.CustomerName+ ' '+ T.CustomerFirstLastName + ' '+ T.CustomerSecondLastName as CustomerName,     
			T.CustomerAddress,      
			T.CustomerCity+', '+ T.CustomerState+' '+ REPLACE(STR(isnull(T.CustomerZipcode,0), 5), SPACE(1), '0') AS  CustomerLocation,      
			T.CustomerPhoneNumber,  
			T.CustomerCelullarNumber,     
			T.IdBeneficiary,	                  
			T.BeneficiaryName+ ' '+ T.BeneficiaryFirstLastName+ ' '+ T.BeneficiarySecondLastName as BeneficiaryName,    
			T.BeneficiaryAddress,      
			case when T.BeneficiaryCity='' then BrC.CityName+', '+ BrS.StateName else B.City+', '+B.State end BeneficiaryLocation,
			T.BeneficiaryPhoneNumber,    
			T.BeneficiaryCountry,                            
			D.PayerName,     
			GB.GatewayBranchCode,                         
			E.PaymentName as PaymentTypeName,   
			Br.BranchName,      
			BrC.CityName+', '+ BrS.StateName BranchLocation,                             
			G.CountryName,                            
			C.StatusName,
			H.GatewayName,
			T.Fee,
			G.IdCountry,
			T.AmountInDollars,
			Case SF.State When 'OK' Then 'Oklahoma' When Null Then '' Else  SF.State End StateTax,    
			Isnull(SF.Tax,0) as Tax, 
			T.ExRate,
			T.AmountInMN,
			T.AgentCommission,
			I.CurrencyName,
			T.DateStatusChange,
			U.UserLogin,
			ISNULL(br.schedule,'') BranchSchedule,
			case
            when T.DateOfTransfer<=[dbo].[RemoveTimeFromDatetime](T.DateOfTransfer)+@TimeForClaimTransfer then CONVERT (varchar(10),T.DateOfTransfer,101)
            when T.DateOfTransfer>[dbo].[RemoveTimeFromDatetime](T.DateOfTransfer) and @DayOfWeek=6 then CONVERT (varchar(10),T.DateOfTransfer+2,101)
            when @DayOfWeek=7 then CONVERT (varchar(10),T.DateOfTransfer+1,101)
            else CONVERT (varchar(10),T.DateOfTransfer+1,101)
          end
          AvailableDay,
		  'By signing here I attest to have received $ ' + CONVERT(NVARCHAR(MAX),ROUND((T.AmountInDollars+T.Fee+Isnull(SF.Tax,0)),2)) + ' from the customer' + ' / ' +
		  'Al firmar aqui reconozco haber recibido $ ' + CONVERT(NVARCHAR(MAX),ROUND((T.AmountInDollars+T.Fee+Isnull(SF.Tax,0)),2)) + ' del cliente' [AttestMessage],
		   isnull(CN.[AllowSentMessages],0) AllowSentMessages,
			 case 
			when isnull(pm.idtransfer,0)>0 then 1
			else
			0 end BonusMessage,
			    --case 
        --when TN.IdTransfer is not null then  T.AmountInDollars+T.Fee 
        --else 
            CASE 
                WHEN DATEDIFF(minute, t.DateOfTransfer, t.DateStatusChange)<=30 then  T.AmountInDollars+T.Fee + Isnull(SF.Tax,0) 
                --ELSE T.AmountInDollars
                when TN.IdTransfer is not null then T.AmountInDollars+T.Fee + Isnull(SF.Tax,0) 
						--case
						--when (A.CancelReturnCommission=1) then  T.AmountInDollars+T.Fee + Isnull(SF.Tax,0) 
						--else            
						--	case (rc.returnallcomission) 
						--		when 1 then  T.AmountInDollars+T.Fee + Isnull(SF.Tax,0) 
						--		else T.AmountInDollars              
						--	end						
						--end
                else            
                case (R.returnallcomission) 
                        when 1 then  T.AmountInDollars+T.Fee + Isnull(SF.Tax,0) 
                        else T.AmountInDollars              
                    end
            END              
    --end 
    AmountToReimburse,
    DATEDIFF(minute, t.DateOfTransfer, t.DateStatusChange) TransferMinutes ,
    isnull(R.Reason,'') Reason,
	isnull(t.DepositAccountNumber,'') AccoutNumber,

	ISNULL(n.[ComplaintNoticeEnglish],'') as ComplaintNoticeEnglish,
	ISNULL(n.[ComplaintNoticeSpanish],'') as ComplaintNoticeSpanish,
 
     AffiliationNoticeEnglish = 
      												(case 
															   when 
															     a.AgentState = 'CA'
															   then ''
															  else
															   ISNULL(REPLACE(AffiliationNoticeEnglish, '[Agent]', A.AgentName),'')
															 end       												
      												),
		 -- ISNULL(REPLACE(AffiliationNoticeEnglish, '[Agent]', A.AgentName),'') as AffiliationNoticeEnglish,
 
     AffiliationNoticeSpanish = 
      												(case 
															   when 
															     a.AgentState = 'CA'
															   then ''
															  else
															   ISNULL(REPLACE(AffiliationNoticeSpanish, '[Agent]', A.AgentName),'')
															 end       												
      												),
		(select 
		count(*)
		from Modulo M
       	inner join [Option] O on M.IdModule=O.IdModule
		inner join dbo.OptionUsers OU on OU.IdOption = O.IdOption
		where  M.IdApplication = 1 and OU.IdUser=@IdUser and OU.Action like '%ShowAgentProfit%') ShowCommision,
		T.Discount,
		cpm.PaymentMethod,
		(T.AmountInDollars + T.Fee + T.StateTax - T.Discount) TotalAmountPaid
		FROM [TRANSFER] T                            
			Join Agent A WITH(NOLOCK) ON (T.IdAgent=A.IdAgent)     
			inner join Users U on U.IdUser = T.EnterByIdUser                             
			Join Status C WITH(NOLOCK) ON (T.IdStatus=C.IdStatus)                            
			Join Payer D WITH(NOLOCK) ON (T.IdPayer=D.IdPayer)                            
			Join PaymentType E WITH(NOLOCK) ON (E.IdPaymentType=T.IdPaymentType)                            
			Join CountryCurrency F WITH(NOLOCK) ON (F.IdCountryCurrency=T.IdCountryCurrency)                            
			Join Country G WITH(NOLOCK) ON (G.IdCountry=F.IdCountry)
			Join Gateway H WITH(NOLOCK) ON (H.IdGateway=T.IdGateway)
			Join Currency I WITH(NOLOCK) ON (I.IdCurrency=F.IdCurrency)   
			inner join Beneficiary B on B.IdBeneficiary =T.IdBeneficiary       
			left join GatewayBranch GB on GB.IdBranch =T.IdBranch and GB.IdGateway = T.IdGateway                          
			Left Join TransferHolds thold WITH(NOLOCK) ON (thold.IdTransfer=T.IdTransfer)  
			left join Branch Br on Br.IdBranch = T.IdBranch      
			left join City BrC on BrC.IdCity = Br.IdCity      
			left join State BrS on BrS.IdState = BrC.IdState     
			left join StateFee SF on SF.IdTransfer=T.IdTransfer  
			LEFT JOIN [Infinite].[CellularNumber] CN ON T.[CustomerCelullarNumber] = CN.[NumberWithFormat] AND [CN].[IsCustomer] = 1 AND [CN].[InterCode] = @InterCode
			left join PureMinutesTransaction pm on t.idtransfer=pm.idtransfer and pm.status=1
			left join TransferNotAllowedResend TN on TN.IdTransfer =T.IdTransfer  
			Left join ReasonForCancel R on R.IdReasonForCancel=T.IdReasonForCancel
			--left join reasonforcancel rc on t.idreasonforcancel=rc.idreasonforcancel
			LEFT JOIN dbo.State s ON s.StateCode = isnull(nullif(T.CustomerState,''),A.AgentState) and s.idcountry=18
			LEFT JOIN StateNote n ON s.IdState = n.idstate 
			JOIN PaymentMethod cpm WITH(NOLOCK) ON cpm.IdPaymentMethod = ISNULL(T.IdPaymentMethod, 1)
			WHERE T.IdTransfer=@IdTransfer
END
ELSE
BEGIN		
		SELECT DISTINCT
			A.IdAgent,      
			T.IdTransferClosed AS IdTransfer,                              
			T.IdStatus,      
			T.ClaimCode,                            
			T.DateOfTransfer,                            
			A.AgentCode,                            
			A.AgentName,                            
			T.Folio,        
			T.IdCustomer,                    
			T.CustomerName+ ' '+ T.CustomerFirstLastName + ' '+ T.CustomerSecondLastName as CustomerName,     
			T.CustomerAddress,      
			T.CustomerCity+', '+ T.CustomerState+' '+ REPLACE(STR(isnull(T.CustomerZipcode,0), 5), SPACE(1), '0') AS  CustomerLocation,      
			T.CustomerPhoneNumber,  
			T.CustomerCelullarNumber,   
			T.IdBeneficiary,                    
			T.BeneficiaryName+ ' '+ T.BeneficiaryFirstLastName+ ' '+ T.BeneficiarySecondLastName as BeneficiaryName,    
			T.BeneficiaryAddress,      
			case when T.BeneficiaryCity='' then BrC.CityName+', '+ BrS.StateName else B.City+', '+B.State end BeneficiaryLocation,
			T.BeneficiaryPhoneNumber,    
			T.BeneficiaryCountry,                            
			D.PayerName,     
			GB.GatewayBranchCode,                         
			E.PaymentName as PaymentTypeName,   
			Br.BranchName,      
			Br.Address+' '+ BrC.CityName+' '+ BrS.StateName+' '+Br.zipcode BranchLocation,                             
			G.CountryName,                            
			C.StatusName,
			H.GatewayName,
			T.Fee,
			G.IdCountry,
			T.AmountInDollars,
			Case SF.State When 'OK' Then 'Oklahoma' When Null Then '' Else  SF.State End StateTax,    
			Isnull(SF.Tax,0) as Tax, 
			T.ExRate,
			T.AmountInMN,
			T.AgentCommission,
			I.CurrencyName,
			T.DateStatusChange,
			U.UserLogin,
			ISNULL(br.schedule,'') BranchSchedule,
			case
            when T.DateOfTransfer<=[dbo].[RemoveTimeFromDatetime](T.DateOfTransfer)+@TimeForClaimTransfer then CONVERT (varchar(10),T.DateOfTransfer,101)
            when T.DateOfTransfer>[dbo].[RemoveTimeFromDatetime](T.DateOfTransfer) and @DayOfWeek=6 then CONVERT (varchar(10),T.DateOfTransfer+2,101)
            when @DayOfWeek=7 then CONVERT (varchar(10),T.DateOfTransfer+1,101)
            else CONVERT (varchar(10),T.DateOfTransfer+1,101)
          end
          AvailableDay,
		  'By signing here I attest to have received $ ' + CONVERT(NVARCHAR(MAX),ROUND((T.AmountInDollars+T.Fee+Isnull(SF.Tax,0)),2)) + ' from the customer' + ' / ' +
		  'Al firmar aqui reconozco haber recibido $ ' + CONVERT(NVARCHAR(MAX),ROUND((T.AmountInDollars+T.Fee+Isnull(SF.Tax,0)),2)) + ' del cliente' [AttestMessage],
		  isnull(CN.[AllowSentMessages],0) AllowSentMessages,
		  case 
			when isnull(pm.idtransfer,0)>0 then 1
			else
			0 end BonusMessage,
				    --case 
        --when TN.IdTransfer is not null then  T.AmountInDollars+T.Fee 
        --else 
            CASE 
                WHEN DATEDIFF(minute, t.DateOfTransfer, t.DateStatusChange)<=30 then  T.AmountInDollars+T.Fee + Isnull(SF.Tax,0) 
                --ELSE T.AmountInDollars
                when TN.IdTransfer is not null then T.AmountInDollars+T.Fee + Isnull(SF.Tax,0) 
						--case
						--when (A.CancelReturnCommission=1) then  T.AmountInDollars+T.Fee + Isnull(SF.Tax,0) 
						--else            
						--	case (rc.returnallcomission) 
						--		when 1 then  T.AmountInDollars+T.Fee + Isnull(SF.Tax,0) 
						--		else T.AmountInDollars              
						--	end						
						--end
                else            
                case (r.returnallcomission) 
                        when 1 then  T.AmountInDollars+T.Fee + Isnull(SF.Tax,0) 
                        else T.AmountInDollars              
                    end
            END              
    --end 
    AmountToReimburse,
    DATEDIFF(minute, t.DateOfTransfer, t.DateStatusChange) TransferMinutes ,
    isnull(R.Reason,'') Reason,
	isnull(t.DepositAccountNumber,'') AccoutNumber,

	ISNULL(n.[ComplaintNoticeEnglish],'') as ComplaintNoticeEnglish,
	ISNULL(n.[ComplaintNoticeSpanish],'') as ComplaintNoticeSpanish,
 
     AffiliationNoticeEnglish = 
      												(case 
															   when 
															     a.AgentState = 'CA'
															   then ''
															  else
															   ISNULL(REPLACE(AffiliationNoticeEnglish, '[Agent]', A.AgentName),'')
															 end       												
      												),
		 -- ISNULL(REPLACE(AffiliationNoticeEnglish, '[Agent]', A.AgentName),'') as AffiliationNoticeEnglish,
 
     AffiliationNoticeSpanish = 
      												(case 
															   when 
															     a.AgentState = 'CA'
															   then ''
															  else
															   ISNULL(REPLACE(AffiliationNoticeSpanish, '[Agent]', A.AgentName),'')
															 end       												
      												),
		(select 
		count(*)
		--#1
		from Modulo M
       	inner join [Option] O on M.IdModule=O.IdModule
		inner join dbo.OptionUsers OU on OU.IdOption = O.IdOption
		where  M.IdApplication = 2 and OU.IdUser=@IdUser and OU.Action like '%ShowAgentProfit%') ShowCommision,
		T.Discount,
		cpm.PaymentMethod,
		(T.AmountInDollars + T.Fee + ISNULL(SF.Tax, 0) - T.Discount) TotalAmountPaid
		FROM TransferClosed T WITH(NOLOCK)                        
			Join Agent A WITH(NOLOCK) ON (T.IdAgent=A.IdAgent)  
			inner join Users U on U.IdUser = T.EnterByIdUser                                
			Join Status C WITH(NOLOCK) ON (T.IdStatus=C.IdStatus)                            
			Join Payer D WITH(NOLOCK) ON (T.IdPayer=D.IdPayer)                            
			Join PaymentType E WITH(NOLOCK) ON (E.IdPaymentType=T.IdPaymentType)                            
			Join CountryCurrency F WITH(NOLOCK) ON (F.IdCountryCurrency=T.IdCountryCurrency)                            
			Join Country G WITH(NOLOCK) ON (G.IdCountry=F.IdCountry)
			Join Gateway H WITH(NOLOCK) ON (H.IdGateway=T.IdGateway)
			Join Currency I WITH(NOLOCK) ON (I.IdCurrency=F.IdCurrency)   
			inner join Beneficiary B on B.IdBeneficiary =T.IdBeneficiary       
			left join GatewayBranch GB on GB.IdBranch =T.IdBranch and GB.IdGateway = T.IdGateway                          
			Left Join TransferHolds thold WITH(NOLOCK) ON (thold.IdTransfer=T.IdTransferClosed)  
			left join Branch Br on Br.IdBranch = T.IdBranch      
			left join City BrC on BrC.IdCity = Br.IdCity      
			left join State BrS on BrS.IdState = BrC.IdState     
			left join StateFee SF on SF.IdTransfer=T.IdTransferClosed  
			LEFT JOIN [Infinite].[CellularNumber] CN ON T.[CustomerCelullarNumber] = CN.[NumberWithFormat] AND [CN].[IsCustomer] = 1 AND [CN].[InterCode] = @InterCode
			left join PureMinutesTransaction pm on t.IdTransferClosed=pm.idtransfer and pm.status=1
			left join TransferNotAllowedResend TN on TN.IdTransfer =T.IdTransferclosed  
			Left join ReasonForCancel R on R.IdReasonForCancel=T.IdReasonForCancel
			--left join reasonforcancel rc on t.idreasonforcancel=rc.idreasonforcancel
			LEFT JOIN dbo.State s ON s.StateCode = isnull(nullif(T.CustomerState,''),A.AgentState) and s.idcountry=18
			LEFT JOIN StateNote n ON s.IdState = n.idstate 
			JOIN PaymentMethod cpm WITH(NOLOCK) ON cpm.IdPaymentMethod = ISNULL(T.IdPaymentMethod, 1)
			WHERE T.IdTransferClosed=@IdTransfer
END 
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage=ERROR_MESSAGE()           
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
	VALUES('[MaxiMobile].[st_GetTransferByIdTransfer]',GETDATE(),@ErrorMessage)
END CATCH


