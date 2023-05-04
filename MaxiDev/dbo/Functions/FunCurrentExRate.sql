CREATE FUNCTION [dbo].[FunCurrentExRate] 
(
    @IdCountryCurrency money
    , @IdGateway money
    , @IdPayer money
    , @IdAgent int
    , @IdCity int
    , @IdPaymentType int
    , @IdAgentSchema int
    , @AmountInDollars MONEY 
)  
RETURNS Money
/********************************************************************
<Author>snevarez</Author>
<app></app>
<Description>Creacion de notificaciones por porcentaje</Description>

<ChangeLog>
<log Date="06/12/2017" Author="Snevarez"> Fix:0000803:Log al romper una regla(suma de nulos en subconsultas) </log>
<log Date="24/12/2018" Author="jmolina"> Add with(nolock) </log>
</ChangeLog>
*********************************************************************/  
BEGIN   
  
	Declare @RefExRate  Money  
       

	SELECT TOP 1 @RefExRate=RefExRate FROM 
	(
		SELECT DISTINCT 
		--g.idpayer,
		CASE          
		WHEN E.EndDateTempSpread >GETDATE() then E.TempSpread            
		ELSE 0          
		END 
		+ F.SpreadValue 
		+ CASE WHEN ISNULL(E.IdSpread,0)>0 
				THEN ISNULL((SELECT ISNULL(SD.SpreadValue,0) 
						FROM SpreadDetail SD (NOLOCK) 
						WHERE SD.IdSpread = E.IdSpread 
							AND @AmountInDollars BETWEEN SD.FromAmount AND SD.ToAmount),0)
				ELSE ISNULL(E.SpreadValue ,0)
			END 
		+ ISNULL(R1.RefExRate,ISNULL(R2.RefExRate,ISNULL(R3.RefExRate,0))) RefExRate
		--drop table #refexrate  
		FROM AgentSchema B WITH(NOLOCK)
			--from RelationAgentSchema A with (nolock) 
			--Join AgentSchema B with (nolock) on (A.IdAgentSchema=B.IdAgentSchema)  
			Join CountryCurrency C with (nolock) on (C.IdCountryCurrency=B.IdCountryCurrency)   
			Join Currency D with (nolock) on (D.IdCurrency=C.IdCurrency)  
			Join AgentSchemaDetail E with (nolock) on (B.IdAgentSchema=E.IdAgentSchema)  
			Join PayerConfig F with (nolock) on (F.IdPayerConfig=E.IdPayerConfig and F.IdCountryCurrency=B.IdCountryCurrency)  
			Join Payer G with (nolock) on (G.IdPayer=F.IdPayer)  
			Join PaymentType H with (nolock) on (H.IdPaymentType=F.IdPaymentType)
			LEFT JOIN RefExRate R1 WITH(NOLOCK) ON R1.IdCountryCurrency=B.IdCountryCurrency and R1.Active=1 and R1.RefExRate<>0 and F.IdGateway=R1.IdGateway and F.IdPayer=R1.IdPayer  
			LEFT JOIN RefExRate R2 WITH(NOLOCK) ON R2.IdCountryCurrency=B.IdCountryCurrency and R2.Active=1 and R2.RefExRate<>0 and F.IdGateway=R2.IdGateway and R2.IdPayer is NULL AND R1.RefExRate IS NULL
			LEFT JOIN RefExRate R3 WITH(NOLOCK) ON R3.IdCountryCurrency=B.IdCountryCurrency and R3.Active=1 and R3.IdGateway is NULL and R3.IdPayer is NULL AND R1.RefExRate IS NULL AND R2.RefExRate IS NULL
		WHERE 
		IdAgent=@IdAgent and  F.IdGenericStatus=1 and B.IdGenericStatus=1 and G.IdGenericStatus=1  and
		c.idcountrycurrency=@IdCountryCurrency and f.idgateway=@IdGateway and g.idpayer=@IdPayer  and h.idpaymenttype=@IdPaymentType and b.idagentschema=@IdAgentSchema
	) T
	ORDER BY RefExRate

       --     --p.idpayer,          
       --     Isnull(J.Spread,0) +
       --     PC.SpreadValue +        
       --     AD.SpreadValue +        
       --     dbo.FunRefExRate(@IdCountryCurrency,@IdGateway,@IdPayer)
       --from 
       --     AgentSchema A         
       --JOIN AgentSchemaDetail AD on (A.IdAgentSchema=AD.IdAgentSchema)           
       --JOIN PayerConfig PC on (AD.IdPayerConfig=PC.IdPayerConfig) AND A.IdCountryCurrency =PC.IdCountryCurrency          
       --JOIN CountryCurrency CC on CC.IdCountryCurrency =PC.IdCountryCurrency      
       --JOIN Currency C on C.IdCurrency =CC.IdCurrency      
       --JOIN Payer P on (PC.IdPayer=P.IdPayer)  
       --Left JOIN RelationAgentSchema J on (J.IdAgent=@IdAgent and J.IdAgentSchema=A.IdAgentSchema and J.EndDateSpread>GETDATE())          
       --JOIN(        
       --     select distinct B.IdPayer from  Branch B        
       --     where B.IdCity = @IdCity AND B.IdGenericStatus=1          
       --)B on (B.IdPayer=P.IdPayer)          
       --Where 
       --     A.IdAgentSchema=@IdAgentSchema           
       --     AND PC.IdGenericStatus=1  AND P.IdGenericStatus=1          
       --     and dbo.fnPaymentTypeComparison(4,PC.IdPaymentType)=1      
       --     and PC.IdPaymentType=@IdPaymentType and p.idpayer=@IdPayer
        
           
        Return @RefExRate  
END

