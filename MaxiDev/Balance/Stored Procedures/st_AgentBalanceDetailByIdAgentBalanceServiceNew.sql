CREATE PROCEDURE [Balance].[st_AgentBalanceDetailByIdAgentBalanceServiceNew]
(              
    @IdAgent int,              
    @IdAgentBalanceService int,
    @DateFrom datetime,               
    @DateTo datetime              
)              
AS             

SET NOCOUNT ON;         
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

---------------------------------------------------------------------------------------------------------------------
--DECLARE @IdAgent int              
--DECLARE @IdAgentBalanceService int
--DECLARE @DateFrom datetime               
--DECLARE @DateTo datetime        
---------------------------------------------------------------------------------------------------------------------
DECLARE @TypeM TABLE
    (
        TypeOfMovement NVARCHAR(MAX)
    )

DECLARE @Balance TABLE
   (
		IdAgentBalance INT,
		TypeOfMovement NVARCHAR(MAX),
		DateOfMovement DATETIME,
		Reference int,
		DESCRIPTION NVARCHAR(MAX),
		Country NVARCHAR(MAX),
		Fee MONEY,
		Commission MONEY,
		FxFee MONEY,
		Amount MONEY,
		AmountForBalance MONEY,
		nsffee MONEY
	)

SELECT @DateFrom=dbo.RemoveTimeFromDatetime(@DateFrom),@DateTo=dbo.RemoveTimeFromDatetime(@DateTo+1)              

---------------------------------------------------------------------------------------------------------------------
	--SET @IdAgent = 1244
	--SET @IdAgentBalanceService = 7
	--SET @DateFrom  = '2013-01-01'              
	--SET @DateTo = '2016-01-01'              
---------------------------------------------------------------------------------------------------------------------

/*
1,Money Transfers
2,Bill Payments
3,Long Distance
4,Top Ups
5,Deposits, Credits and Charges
6,Others
7,CH~
8,CH Returned Checks
9,Check Pending Release 
*/



DECLARE @RelationAgentBalanceServiceOtherProduct TABLE
(
	IdAgentBalanceService INT NOT NULL,
	IdOtherProduct        INT NULL
);

INSERT INTO @RelationAgentBalanceServiceOtherProduct
SELECT * FROM RelationAgentBalanceServiceOtherProduct	
UNION SELECT 8 ,15	
UNION SELECT 9 ,15

---------------------------------------------------------------------------------------------------------------------
	if @IdAgentBalanceService=1 
	   begin
				insert into @TypeM
				values  ('CANC'),
						('REJ'),
						('TRAN')
------------------------------------------------------
				insert into @Balance
				Select    
					   IdAgentBalance,     
					   TypeOfMovement,              
					   DateOfMovement,              
					   case 
							when isnull(Reference,'')='' then convert(varchar,IdAgentBalance)
						    else Reference
					   end Reference,              
					   Description,              
					   Country,   
					   case 
						    when DebitOrCredit='Debit' Then t.Fee 
						    else t.Fee*(-1) end Fee,           
					   Commission,      
					   FxFee,                         
				       case 
							when DebitOrCredit='Debit'  Then  t.AmountInDollars   
							else t.AmountInDollars*(-1) 
					   end Amount,    
					   case 
						    when DebitOrCredit='Debit' Then Amount 
							else Amount*(-1) 
					   end AmountForBalance,
					       0.0 nsffee
					  from AgentBalance b  with (nolock)               
				      join transfer t with (nolock) on b.IdTransfer=t.idtransfer					  
					      
					 where b.IdAgent=@IdAgent              
					   and DateOfMovement>=@DateFrom 
					   and DateOfMovement<@DateTo  
					   and TypeOfMovement in (select TypeOfMovement from @TypeM)
			
				 union all

					Select    
						   IdAgentBalance,     
					       TypeOfMovement,              
						   DateOfMovement,              
						   case 
								when isnull(Reference,'')='' then convert(varchar,IdAgentBalance)
							    else Reference
						   end    
						   Reference,              
						   Description,              
						   Country,   
					       case 
								when DebitOrCredit='Debit' Then t.Fee 
								else t.Fee*(-1) 
						   end Fee,           
						   Commission,      
						   FxFee,                         
						   case when DebitOrCredit='Debit'  Then  t.AmountInDollars   else  t.AmountInDollars*(-1) end Amount,    
					       case when DebitOrCredit='Debit' Then Amount else Amount*(-1) end AmountForBalance,
						   0.0 nsffee
					  from AgentBalance b with (nolock)             
				      join transferclosed t with (nolock) on b.IdTransfer=t.idtransferclosed					  
				     where b.IdAgent=@IdAgent              
				       and DateOfMovement>=@DateFrom 
					   and DateOfMovement<@DateTo  
					   and TypeOfMovement in (select TypeOfMovement from @TypeM)			

					delete from @TypeM



				    insert into @TypeM values ('CGO')

			        insert into @Balance
				    Select    
						   IdAgentBalance,     
						   'TRAN',              
						   DateOfMovement,              
						   case 
							   when isnull(Reference,'')='' then convert(varchar,IdAgentBalance)
						       else Reference
						   end    
						   Reference,              
						   Description,              
						   Country,
					       0 Fee,
						   Commission,      
						   FxFee,                         
						   case when DebitOrCredit='Debit'  Then  Amount   else  Amount*(-1) end Amount,    
					       case when DebitOrCredit='Debit' Then Amount else Amount*(-1) end AmountForBalance,
						   0.0 nsffee
                      from AgentBalance b with (nolock)
				     where b.IdAgent=@IdAgent              
					   and DateOfMovement>=@DateFrom and DateOfMovement<@DateTo  and TypeOfMovement in  (select TypeOfMovement from @TypeM) and b.Commission!=0    
			end

	if @IdAgentBalanceService in (2,3,4)
				begin
					insert into @TypeM    
				    select typeofmovement 
					  from @RelationAgentBalanceServiceOtherProduct r 
					  join agentbalancehelper h 
					    on r.idotherproduct=h.idotherproduct 
				     where r.IdAgentBalanceService=@IdAgentBalanceService

			        insert into @Balance
				    Select    
						   IdAgentBalance,     
						   TypeOfMovement,              
					       DateOfMovement,              
						   case 
							   when isnull(Reference,'')='' then convert(varchar,IdAgentBalance)
							   else Reference
						   end    
					       Reference,              
					       Description,  
	--case 
    --    when b.TypeOfMovement in ('RBP','CRBP') then co.CountryCode 
    --    else b.Country
    --end            
    --Country,  
			               b.country,
					       case when DebitOrCredit='Debit' Then isnull(t.fee,ISNULL(P.FEE,0)) else isnull(t.fee,ISNULL(P.FEE,0))*(-1) end Fee,                
						   B.Commission,      
						   FxFee,                          
						  case when DebitOrCredit='Debit'  Then 
										case when b.IsMonthly=1 then B.Amount-isnull(t.fee,ISNULL(P.Fee,0)) else B.Amount+B.Commission end
							   else 
									    case when b.IsMonthly=1 then (B.Amount-isnull(t.fee,ISNULL(P.Fee,0)))*(-1) else B.Amount*(-1)+B.Commission end
						  end Amount,    
					      case when DebitOrCredit='Debit' Then B.Amount else B.Amount*(-1) end AmountForBalance,
						  0.0 nsffee
					 from AgentBalance b with (nolock)
			         left join BillPaymentTransactions t with (nolock) on b.idtransfer=t.IdBillPayment and b.TypeOfMovement in ('BP','CBP')
					 left join Operation.ProductTransfer P with (nolock) on b.idtransfer=P.IdProductTransfer and b.TypeOfMovement in ('RBP','CRBP')
    --left join Regalii.TransferR r on p.IdProductTransfer=r.IdProductTransfer
    --left join Country co on r.IdCountry=co.IdCountry    
				    where b.IdAgent=@IdAgent              
				      and DateOfMovement>=@DateFrom and DateOfMovement<@DateTo  and TypeOfMovement in  (select TypeOfMovement from @TypeM) 
		  end

	if @IdAgentBalanceService = 7
			begin
					insert into @TypeM    
				    select typeofmovement 
					  from @RelationAgentBalanceServiceOtherProduct r join agentbalancehelper h on r.idotherproduct=h.idotherproduct 
					 where r.IdAgentBalanceService=@IdAgentBalanceService

		  --INSERT INTO @TypeM  values ('CHNFS') /*S12*/

		  DELETE FROM  @TypeM WHERE TypeOfMovement = 'CHRTN'; /*S12:REQ._MC.02_Rediseño_de_Agent_Balance_Report*/

          INSERT INTO @Balance
	      SELECT IdAgentBalance,     
				 TypeOfMovement,              
			     b.DateOfMovement,                  
			     Reference,              
			     Description,              
			     isnull(country,'') Country,  

				 --------------------------------------------------------------------------------------------------
				 case when TypeOfMovement!='CHNFS' then
									case 
										 when DebitOrCredit='Debit' then t.Fee*(-1) 
									     --										 
									     when TypeOfMovement='CH' then t.Fee   
					                     when TypeOfMovement='CHRTN' then t.Fee
										 --
										 else t.Fee  
								    end					  
					  else 0 end Fee,               
				--------------------------------------------------------------------------------------------------			     
				 0 Commission,      
			     case when TypeOfMovement='CHNFS' 
					  then t.Comission
					  else 0
				 end
				 FxFee,   
				 case when DebitOrCredit='Debit' 
					Then CASE WHEN [TypeOfMovement] ='CHNFS' THEN 0 ELSE t.Amount END
					else 
						t.Amount*(-1)
				 end Amount,    
			     case when DebitOrCredit='Debit' Then B.Amount else B.Amount*(-1) end AmountForBalance,
			    
				--------------------------------------------------------------------------------------------------
				 CASE WHEN TypeOfMovement ='CHNFS' 
				      THEN convert(decimal(18,2),t.Comission) 					  
					  ELSE 0.00 END nsffee ---- NSF Fee solo debe mostrar valor cuando el movimiento concepto es CHRTN
				--------------------------------------------------------------------------------------------------			     
				

		    from AgentBalance b with (nolock)
            left join Checks t with (nolock) on b.idtransfer=t.IdCheck and b.TypeOfMovement in (select TypeOfMovement from @TypeM)    

           where b.IdAgent=@IdAgent              
			 and b.DateOfMovement>=@DateFrom and b.DateOfMovement<@DateTo  
			 and TypeOfMovement in  (select TypeOfMovement from @TypeM) 
		end

	if @IdAgentBalanceService =5
				begin
						insert into @TypeM
					    values ('DEP')

			 INSERT INTO @Balance
			 SELECT b.IdAgentBalance,     
				    TypeOfMovement,              
					DateOfMovement,              
					case 
						when isnull(Reference,'')='' then convert(varchar,b.IdAgentBalance)
						else Reference
					end    
					Reference,              
					Description,              
					Country,   
					0 Fee,               
					0 Commission,          
					0 FxFee,                         
				    case when TypeOfMovement='DEP' Then b.Amount else 0 end * case when DebitOrCredit='Debit' Then -1 ELSE 1 END Amount,    
					case when DebitOrCredit='Debit' Then b.Amount else b.Amount*(-1) end AmountForBalance,
				    0.0 nsffee
			   from AgentBalance b with (nolock)   

			  where b.IdAgent=@IdAgent              
		        and DateOfMovement>=@DateFrom 
				and DateOfMovement<@DateTo  
				and TypeOfMovement in  (select TypeOfMovement from @TypeM)  
    
    delete from @TypeM
    
	insert into @TypeM
    values ('CGO')

    
				insert into @Balance
				Select b.IdAgentBalance,     
					   case when DebitOrCredit='Debit' then 'CHG' else 'CRED' END TypeOfMovement,
				       DateOfMovement,              
					   case 
							when isnull(Reference,'')='' then convert(varchar,b.IdAgentBalance)
							else Reference
					   end    
					   Reference,              
					   Description,              
					   Country,   
					   0 Fee,                   
    --case when TypeOfMovement='CGO' and b.commission=0 and isnull(o.IdOtherChargesMemo,0) in (6) Then b.Amount else 0 end * case when DebitOrCredit='Debit' Then 1 ELSE -1 END Commission,
    --case when TypeOfMovement='CGO' and b.commission=0 and isnull(o.IdOtherChargesMemo,0) not in (6) Then b.Amount else 0 end * case when DebitOrCredit='Debit' Then 1 ELSE -1 END FxFee,                         
					   Case when DebitOrCredit='Credit' Then b.Amount else 0 end as Commission,              
					   Case when DebitOrCredit='Debit' Then b.Amount else 0 end as FxFee, 
					   0 Amount,    
					   case when DebitOrCredit='Debit' Then b.Amount else b.Amount*(-1) end AmountForBalance
					   , 0.0 nsffee
			      from AgentBalance b with (nolock)

    --left join agentothercharge o with (nolock) on b.idagentbalance=o.idagentbalance                  
			     where b.IdAgent=@IdAgent              
				   and DateOfMovement>=@DateFrom and DateOfMovement<@DateTo  and TypeOfMovement in  (select TypeOfMovement from @TypeM) and b.Commission=0 
			end

	if @IdAgentBalanceService = 0
			    begin
    
						insert into @TypeM    
						select typeofmovement from agentbalancehelper with (nolock) where idotherproduct in(
					    select idotherproducts from otherproducts with (nolock) where idotherproducts not in (
					    select idotherproduct from @RelationAgentBalanceServiceOtherProduct ))


			    insert into @Balance
				Select IdAgentBalance,     
					   TypeOfMovement,              
					   DateOfMovement,              
					   case 
							when isnull(Reference,'')='' then convert(varchar,IdAgentBalance)
							else Reference
						end   Reference,              
					   Description,              
					   Country,   
					   0 Fee,           
					   Commission,      
					   FxFee,                         
					   case when DebitOrCredit='Debit' 
							Then case when b.IsMonthly=1 then Amount else Amount+Commission end
							else case when b.IsMonthly=1 then Amount*(-1) else Amount*(-1)+Commission end
					   end Amount,    
					   case when DebitOrCredit='Debit' Then Amount else Amount*(-1) end AmountForBalance
				       , 0.0 nsffee
			      from AgentBalance b with (nolock)   

		         where b.IdAgent=@IdAgent              
				   and DateOfMovement>=@DateFrom and DateOfMovement<@DateTo  and TypeOfMovement in  (select TypeOfMovement from @TypeM)
			end

	/*---------------------------------------------*/
	/*S12:REQ._MC.02_Rediseño_de_Agent_Balance_Report*/
	if @IdAgentBalanceService = 8
		begin
					insert into @TypeM    
				    select typeofmovement 
					  from @RelationAgentBalanceServiceOtherProduct r join agentbalancehelper h on r.idotherproduct=h.idotherproduct 
					 where r.IdAgentBalanceService=@IdAgentBalanceService

		  INSERT INTO @TypeM values ('CHNFS')

		  /*CH*/
		  DELETE FROM  @TypeM WHERE TypeOfMovement = 'CH';

          INSERT INTO @Balance
	      SELECT IdAgentBalance,     
				 TypeOfMovement,              
			     b.DateOfMovement,                  
			     Reference,              
			     Description,              
			     isnull(country,'') Country,  

				 --------------------------------------------------------------------------------------------------
				 case when TypeOfMovement!='CHNFS' then
									case 
										 when DebitOrCredit='Debit' then t.Fee*(-1) 
									     --										 
									     when TypeOfMovement='CH' then t.Fee   
					                     when TypeOfMovement='CHRTN' then t.Fee
										 --
										 else t.Fee  
								    end					  
					  else 0 end Fee,               
				--------------------------------------------------------------------------------------------------			     
				 0 Commission,      
			     case when TypeOfMovement='CHNFS' 
					  then t.Comission
					  else 0
				 end
				 FxFee,   
				 case when DebitOrCredit='Debit' 
					Then CASE WHEN [TypeOfMovement] ='CHNFS' THEN 0 ELSE t.Amount END
					else 
						t.Amount*(-1)
				 end Amount,    
			     case when DebitOrCredit='Debit' Then B.Amount else B.Amount*(-1) end AmountForBalance,
			    
				--------------------------------------------------------------------------------------------------
				 CASE WHEN TypeOfMovement ='CHNFS' 
				      THEN convert(decimal(18,2),t.Comission) 					  
					  ELSE 0.00 END nsffee ---- NSF Fee solo debe mostrar valor cuando el movimiento concepto es CHRTN
				--------------------------------------------------------------------------------------------------			     
				
		    from AgentBalance b with (nolock)
            left join Checks t with (nolock) on b.idtransfer=t.IdCheck and b.TypeOfMovement in (select TypeOfMovement from @TypeM)    

           where b.IdAgent=@IdAgent              
			 and b.DateOfMovement>=@DateFrom and b.DateOfMovement<@DateTo  
			 and TypeOfMovement in  (select TypeOfMovement from @TypeM) 
		end

	if @IdAgentBalanceService = 9
	begin

		insert into @Balance
		SELECT 
			0 AS IdAgentBalance
			,'CH' AS TypeOfMovement
			,DateOfMovement
			,IdCheck AS Reference
			,([Name] + ' '	+ FirstLastName + ' ' + SecondLastName) AS [Description]
			, '' AS Country
			--,Fee
			,ISNULL(TransactionFee,0) AS Fee
			,0  AS Commission
			,ISNULL(CustomerFee,0) AS FxFee
			,Amount
			,0 AS AmountForBalance
			,ISNULL(ReturnFee,0) AS nsffee
		FROM Checks 
			---INNER JOIN CheckHolds AS CH ON C.idCheck = Ch.idCheck and IsReleased is null
		WHERE IdStatus = 41
		AND IdAgent=@IdAgent
		AND [DateStatusChange]>=@DateFrom
		AND [DateStatusChange]<@DateTo
		ORDER BY idCheck DESC;

	end
	/*---------------------------------------------*/
---------------------------------------------------------------------------------------------------------------------


	select 
		IdAgentBalance,
		TypeOfMovement,
		DateOfMovement,
		Reference,
		Description,
		Country,
		Fee,
		Commission,
		FxFee,
		Amount,
		AmountForBalance,
		nsffee, 
		0.0 valuefee 
	from @Balance 
	Order by DateOfMovement asc, 
			IdAgentBalance asc

