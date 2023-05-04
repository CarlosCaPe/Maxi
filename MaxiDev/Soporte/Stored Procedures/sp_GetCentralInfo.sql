
CREATE PROCEDURE [Soporte].[sp_GetCentralInfo]
AS
BEGIN

SELECT * FROM (
select DATENAME(MM,T.DateOfTransfer) as Month, A.AgentState,C.CountryName, G.GatewayName, p.IdPayer,Replace(REPLACE(P.PayerName,',',' '),'–','-') as PayerName , Y.PaymentName,
       COUNT (T.Folio) as '#_Trans', SUM (T.AmountInDollars) as 'Amount_USD'
	From   Transfer T with (nolock)
	Join   Payer P with (nolock) on  T.IdPayer=P.IdPayer
	Join   Gateway G with (nolock) on T.IdGateway=G.IdGateway
	Join   PaymentType Y with (nolock) on T.IdPaymentType = Y.IdPaymentType
	Join   Countrycurrency R with (nolock) on T.IdCountryCurrency=R.IdCountryCurrency
	Join   Country C with (nolock) on R.IdCountry = C.IdCountry
	Join   Agent A with (nolock) on T.IdAgent=A.IdAgent
		Where  T.DateOfTransfer Between DATEADD(mm, -1, cast(getdate() as date)) And cast(GETDATE() as date)
		And    T.IdAgent not in ( 1242 )
			Group by      DATENAME(MM,T.DateOfTransfer), A.agentstate, C.CountryName,G.GatewayName, p.IdPayer,P.PayerName,Y.PaymentName
--Order by    G.GatewayName, P.PayerName,Y.PaymentName

 Union all

select DATENAME(MM,T.DateOfTransfer) as Month, A.AgentState,C.CountryName,G.GatewayName, p.IdPayer,Replace(REPLACE(P.PayerName,',',' '),'–','-') as PayerName, Y.PaymentName,
	   COUNT (T.Folio)as '#_Trans', SUM (T.AmountInDollars) as 'Amount_USD'
	From   Transferclosed T with (nolock)
	Join   Payer P with (nolock) on (T.IdPayer=P.IdPayer)
	Join   Gateway G with (nolock) on (T.IdGateway=G.IdGateway)
	Join   PaymentType Y with (nolock) on (T.IdPaymentType = Y.IdPaymentType)
	Join   Countrycurrency R with (nolock) on (T.IdCountryCurrency=R.IdCountryCurrency)
	Join   Country C with (nolock) on (R.IdCountry = C.IdCountry)
	Join   Agent A with (nolock) on (T.IdAgent=A.IdAgent)
		Where  T.DateOfTransfer Between DATEADD(mm, -1, cast(getdate() as date)) And cast(GETDATE() as date)
		And	   T.IdAgent not in ( 1242 )
			Group by      DATENAME(MM,T.DateOfTransfer), A.agentstate,C.CountryName,G.GatewayName, p.IdPayer,P.PayerName,Y.PaymentName
			--Order by       DATENAME(MM,T.DateOfTransfer),A.agentstate,C.CountryName,G.GatewayName, p.IdPayer,P.PayerName,Y.PaymentName

 
 Union all
--CANCELLED, REJECTED

 

select DATENAME(MM,T.DateStatusChange)  as Month, A.AgentState,C.CountryName,G.GatewayName, p.IdPayer,Replace(REPLACE(P.PayerName,',',' '),'–','-') as PayerName, Y.PaymentName, 
	   -COUNT (T.Folio) as '#_Trans', -SUM (T.AmountInDollars) as 'Amount_USD'
	From   Transfer T with (nolock)
	Join   Payer P with (nolock) on (T.IdPayer=P.IdPayer)
	Join   Gateway G with (nolock) on (T.IdGateway=G.IdGateway)
	Join   PaymentType Y with (nolock) on (T.IdPaymentType = Y.IdPaymentType)
	Join   Countrycurrency R with (nolock) on (T.IdCountryCurrency=R.IdCountryCurrency)
	Join   Country C with (nolock) on (R.IdCountry = C.IdCountry)
	Join   Agent A with (nolock) on (T.IdAgent=A.IdAgent)
		Where  T.DateStatusChange Between DATEADD(mm, -1, cast(getdate() as date)) And cast(GETDATE() as date)	
		And T.IdStatus in ('22','31')
		And          T.IdAgent not in ( 1242 )
			Group by      DATENAME(MM,T.DateStatusChange),A.agentstate,C.CountryName,G.GatewayName, p.IdPayer,P.PayerName,Y.PaymentName
			--Order by    G.GatewayName, P.PayerName,Y.PaymentName

Union all


select DATENAME(MM,T.DateStatusChange)  as Month, A.AgentState,C.CountryName,G.GatewayName, p.IdPayer,Replace(REPLACE(P.PayerName,',',' '),'–','-') as PayerName, Y.PaymentName, 
		-COUNT (T.Folio)as '#_Trans', -SUM (T.AmountInDollars) as 'Amount_USD'
	From   Transferclosed T with (nolock)
	Join   Payer P with (nolock) on (T.IdPayer=P.IdPayer)
	Join   Gateway G with (nolock) on (T.IdGateway=G.IdGateway)
	Join   PaymentType Y with (nolock) on (T.IdPaymentType = Y.IdPaymentType)
	Join   Countrycurrency R with (nolock) on (T.IdCountryCurrency=R.IdCountryCurrency)
	Join   Country C with (nolock) on (R.IdCountry = C.IdCountry)
	Join   Agent A with (nolock) on (T.IdAgent=A.IdAgent)
		Where  T.DateStatusChange Between DATEADD(mm, -1, cast(getdate() as date)) And cast(GETDATE() as date)
		And          T.IdStatus in ('22','31')
		And          T.IdAgent not in ( 1242 )
			Group by      DATENAME(MM,T.DateStatusChange),A.agentstate,C.CountryName,G.GatewayName, p.IdPayer,P.PayerName,Y.PaymentName
			--Order by      DATENAME(MM,T.DateStatusChange),A.agentstate,C.CountryName,G.GatewayName, p.IdPayer,P.PayerName,Y.PaymentName
			) AS report
			Order by Month,agentstate,CountryName,GatewayName,IdPayer,PayerName,PaymentName
END


