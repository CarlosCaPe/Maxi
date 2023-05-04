
CREATE procedure [BillPayment].[st_GetBillerAgent]
   @Idagent int
   , @IsNational bit
as


/********************************************************************
<Author>Amoreno</Author>
<app>MaxiCorp</app>
<Description>Optener Biller By </Description>

<ChangeLog>

<log Date="15/06/2018" Author="amoreno">Creation</log>
<log Date="21/09/2018" Author="esalazar">Field "Posting" </log>
<log Date="27/09/2018" Author="azavala">Get Only Billers with Fee and Commission</log>
<log Date="05/11/2018" Author="jmolina">Se agrega filtro de status enabled en biller #1</log>
<log Date="29/01/2019" Author="azavala">se agrega IdAggregator y ChoiseData a la consulta saliente - Ref: 29012019_azavala</log>
<log Date="29/01/2019" Author="amoreno">se agregael campo</log>
<log Date="04/04/2019" Author="azavala">se agrega IsFixedFee a la consulta saliente - Ref: 04042019_azavala</log>
<log Date="22/04/2019" Author="jmolina">se agrega validacion para agencia 0301-TX, solo considerar Fiserv para dicha agencia.</log>
<log Date="30/04/2019" Author="jmolina">se agrega validacion para agencia 0317-TX y 1666-TX, considerar Fiserv para dichas agencias. #1</log>
<log Date="06/05/2019" Author="jmolina">Se habilitan las agencias: 9207-CA, 10132-CA, 9181-CA, 1036-IL, 10074-IL, 3810-LA, 3801-LA, 8028-LA, 3610-FL, 3608-FL, 0879-TX, 6776-TX, 9018-TX, 9062-TX, 2233-GA, 2236-GA</log>
<log Date="07/05/2019" Author="jmolina">Se habilitan las agencias de bajo volumen, enviadas por Jesus Juarez: 6229-UT, 4749-UT, 10170-TX, 10171-TX, 10284-TX, 10625-TX, 2304-TX, 10065-TN, 4119-TN, 10349-SC, 10283-OR, 3686-OK, 10426-NC, 10407-MS, 10704-MS, 10728-MS, 10798-LA, 10470-LA, 10558-LA, 10627-LA, 4248-LA, 10034-GA, 10035-GA, 10092-FL, 10150-FL, 10173-FL, 10770-FL, 6368-CO, 10110-CO, 10510-CA, 10598-CA, 10695-CA, 5225-AL, 2200-AL</log>
<log Date="08/05/2019" Author="jmolina">Se habilitan las agencias, enviadas por Jesus Juarez: 10087-AL, 9037-AL, 9569-AL, 9973-AL, 10056-AL, 10331-LA, 10530-LA, 3837-LA, 4714-LA, 8030-LA, 8038-LA, 8058-LA, 8099-LA, 8120-LA, 8170-LA, 8194-LA, 8602-NV, 10002-NV, 10330-NV</log>
<log Date="13/05/2019" Author="jmolina">Se habilitan todas las agencias</log>
</ChangeLog>
*********************************************************************/
 declare 
  @AgentState varchar (5)
  , @idState int
  --, @IdAgentValida int
  --declare @IdAgentValida TABLE (IdAgent int) --#1
 
  --SET @IdAgentValida = (SELECT IdAgent FROM dbo.Agent WITH(NOLOCK) WHERE AgentCode = '0301-TX');
  --SET @IdAgentValida = (SELECT IdAgent FROM dbo.Agent WITH(NOLOCK) WHERE AgentCode = '0020-XX');
  /*INSERT INTO @IdAgentValida(IdAgent)--#1
  SELECT IdAgent
    FROM dbo.Agent WITH(NOLOCK)
   WHERE 1 = 1*/
   --AND AgentCode IN ('0301-TX', '2233-GA')
     --AND AgentCode IN ('0301-TX', '0317-TX', '1666-TX', '10623-TX', '10130-CA', '9207-CA','10132-CA','9181-CA','1036-IL','10074-IL','3810-LA','3801-LA','8028-LA','3610-FL','3608-FL','0879-TX','6776-TX','9018-TX','9062-TX','2233-GA','2236-GA')
	 /*AND AgentCode IN ('0301-TX', '0317-TX', '0879-TX', '10034-GA', '10035-GA', '10065-TN', '10074-IL', '10092-FL', '10110-CO', '10130-CA', '10132-CA', '10150-FL', '10170-TX', '10171-TX', '10173-FL', '10283-OR', '10284-TX', '10349-SC', '1036-IL', '10407-MS', '10426-NC', '10470-LA', '10510-CA', '10558-LA', '10598-CA', '10623-TX', '10625-TX', '10627-LA', '10695-CA', '10704-MS', '10728-MS', '10770-FL', '10798-LA', '1666-TX', '2200-AL', '2233-GA', '2236-GA', '2304-TX', '3608-FL', '3610-FL', '3686-OK', '3801-LA', '3810-LA', '4119-TN', '4248-LA', '4749-UT', '5225-AL', '6229-UT', '6368-CO', '6776-TX', '8028-LA', '9018-TX', '9062-TX', '9181-CA', '9207-CA',
	                   '10530-LA', '8170-LA', '10087-AL', '8120-LA', '3837-LA', '8030-LA', '8058-LA', '8038-LA', '8099-LA', '8194-LA', '8602-NV', '9569-AL', '9973-AL', '10002-NV', '10330-NV', '10331-LA', '4714-LA', '9037-AL', '10056-LA')*/
	 
  BEGIN TRY
		if (@IsNational=1)
			begin 
				set @idState = (select IdState from [State] where StateCode =(Select AgentState from Agent where IdAgent = @Idagent))
				--IF (@IdAgentValida = @Idagent)
				/*IF EXISTS(SELECT 1 FROM @IdAgentValida WHERE IdAgent = @Idagent) --#1
				BEGIN*/
					select  
					 B.idBiller
					 , B.Name
					 , B.Category
					 , B.Posting
					-- , IdCommission
					 , [Fee] = BuyRate
					 , B.IdAggregator -- 29012019_azavala
					 , B.BillerInstructions
					 , B.ChoiseData --29012019_azavala
					 , B.IsFixedFee --04042019_azavala
					from 
					 BillPayment.Billers B with (nolock)
					inner join BillPayment.StateForBillers S with (nolock) on 
						S.Idbiller= B.IdBiller
						and S.IdState = @idState
						and S.Idstatus= 1
					inner join BillPayment.Aggregator A on A.Idstatus= 1 and A.IdAggregator = B.IdAggregator
					where 1 = 1
					  and B.IsDomestic=1 --#1
					  and B.IdStatus = 1 --#1
				/*END
				ELSE
				BEGIN
					select  
					 B.idBiller
					 , B.Name
					 , B.Category
					 , B.Posting
					-- , IdCommission
					 , [Fee] = BuyRate
					 , B.IdAggregator -- 29012019_azavala
					 , B.BillerInstructions
					 , B.ChoiseData --29012019_azavala
					 , B.IsFixedFee --04042019_azavala
					from 
					 BillPayment.Billers B with (nolock)
					inner join BillPayment.StateForBillers S with (nolock) on 
						S.Idbiller= B.IdBiller
						and S.IdState = @idState
						and S.Idstatus= 1
					inner join BillPayment.Aggregator A on A.IdAggregator = 1 AND A.Idstatus= 1 and A.IdAggregator = B.IdAggregator
					where 1 = 1
					  and B.IsDomestic=1 --#1
					  and B.IdStatus = 1 --#1
					--inner join BillPayment.AgentForBillers AB with(nolock) on AB.IdBiller=B.IdBiller
					--group by B.idBiller, B.[Name], B.Category, B.Posting,B.BuyRate
				END*/
			end
		else
		  begin 
   			select  
				B.idBiller
				, B.Name
				, Category
				, B.Posting
		--		, IdCommission= 0
				, [Fee] = BuyRate
				, B.IdAggregator --29012019_azavala
				, B.BillerInstructions
				, B.ChoiseData ----29012019_azavala
				, B.IsFixedFee --04042019_azavala
			from BillPayment.Billers B with (nolock)
	  			inner join BillPayment.Aggregator A on A.Idstatus= 1 and A.IdAggregator = B.IdAggregator 
				--inner join	BillPayment.AgentForBillers AB with(nolock) on AB.IdBiller=B.IdBiller
			where  
				B.IdStatus = 1
				and B.IsDomestic= 0
			--group by B.idBiller, B.[Name], B.Category, B.Posting,B.BuyRate
		  end 	 
    END TRY
  BEGIN CATCH  
  Declare @ErrorMessage nvarchar(max)
  Select  @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[BillPayment].[st_GetBillerAgent] ',Getdate(),@ErrorMessage)
  END CATCH
