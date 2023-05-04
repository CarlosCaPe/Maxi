CREATE procedure [dbo].[st_ReportTransferAudit]
(    
    @StartDate datetime,
    @EndDate datetime,
    @IdAgent int = NULL,    
	@IdOwner int = NULL, 
	@IdCustomer int = NULL, 
	@IdBeneficiary int = NULL, 
    @Amount money = null
)
as

/********************************************************************
<ChangeLog>
<log Date="15/06/2018" Author="jhornedo">Se agrega with (nolock) a consultas </log>
</ChangeLog>
********************************************************************/ 

if(@IdAgent = 0)
begin
	set @IdAgent = null
end

if(@IdCustomer = 0)
begin
	set @IdCustomer = null
end

if(@IdBeneficiary = 0)
begin
	set @IdBeneficiary = null
end

if(@IdOwner = 0)
begin
	set @IdOwner = null
end


Select @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1);
Select @StartDate=dbo.RemoveTimeFromDatetime(@StartDate);

WITH CTE_TRAN AS (
SELECT
      --A.AgentCode AS 'Agent Code',
	  T.Folio  AS 'Folio',
      T.ClaimCode  AS 'Transaction Number',
      T.DateOfTransfer AS 'Transaction Date',
      T.AmountInDollars AS 'Transaction Amount in US dollars ',
      T.ReferenceExRate AS 'Rate of Exchange',
      T.FEE AS 'Transaction Fee or Commission',
      T.CustomerName AS 'Customer First Name',   
      T.CustomerFirstLastName AS 'Customer P. Last Name',
      T.CustomerSecondLastName AS 'Customer M. Last Name',
      T.CustomerAddress AS 'Customer Address',
      T.CustomerCity AS 'Customer City',
      T.CustomerState AS 'Customer State',

      --T.CustomerPhoneNumber AS 'Customer Telephone Number',
	  (CASE WHEN Len(isnull(T.CustomerPhoneNumber,''))=0 THEN Ctr.PhoneNumber ELSE T.CustomerPhoneNumber END) AS 'Customer Telephone Number',  /*2016-Oct-05*/

	  --T.CustomerCelullarNumber AS 'Customer Cellular Number',
	  (CASE WHEN Len(isnull(T.CustomerCelullarNumber,''))=0 THEN Ctr.CelullarNumber ELSE T.CustomerCelullarNumber END) AS 'Customer Cellular Number',  /*2016-Oct-05*/

	  --T.CustomerSSNumber AS 'Customer Social Security Number',   
      (CASE WHEN Len(isnull(T.CustomerSSNumber,''))=0 THEN Ctr.SSNumber ELSE T.CustomerSSNumber END) AS 'Customer Social Security Number',  /*2016-Oct-05*/

      --I.Name AS 'Customer Photo ID Type',
	  (CASE WHEN Len(isnull(I.Name,''))=0 THEN 
		(SELECT TOP 1 NAME FROM  CustomerIdentificationType AS II WITH (NOLOCK) WHERE II.IdCustomerIdentificationType = Ctr.IdCustomerIdentificationType)
	   ELSE I.Name END) AS 'Customer Photo ID Type',  /*2016-Oct-12*/

      --T.CustomerIdentificationNumber AS 'Customer Photo ID Number',
	  (CASE WHEN Len(isnull(T.CustomerIdentificationNumber,''))=0 THEN Ctr.IdentificationNumber ELSE T.CustomerIdentificationNumber END) AS 'Customer Photo ID Number',  /*2016-Oct-12*/

      --T.CustomerBornDate AS 'Customer Date of Birth',
	  (CASE WHEN Len(isnull(Convert(Varchar(10),T.CustomerBornDate,112),''))=0 THEN Ctr.BornDate ELSE T.CustomerBornDate END) AS 'Customer Date of Birth',  /*2016-Oct-12*/

      --T.CustomerOccupation AS 'Customer Occupation',
	  (CASE WHEN Len(isnull(T.CustomerOccupation,''))=0 THEN Ctr.Occupation ELSE T.CustomerOccupation END) AS 'Customer Occupation',  /*2016-Oct-12*/

      T.BeneficiaryName AS 'Beneficiary First Name',
      T.BeneficiaryFirstLastName AS 'Beneficiary P. Last Name',
      T.BeneficiarySecondLastName AS 'Beneficiary M. Last Name',
      T.BeneficiaryAddress AS 'Beneficiary Address',

		BrC.CityName AS 'Beneficiary City',
		BrS.StateName AS 'Beneficiary State',
		C.CountryName  AS 'Beneficiary Country',
		T.BeneficiaryPhoneNumber AS 'Beneficiary Telephone Number',

		A.AgentName AS 'Agent Name',
		A.AgentAddress AS 'Transaction Location Address',
		A.AgentCity AS 'Transaction Location City',
		A.AgentState      AS 'Transaction Location State',
		A.AgentZipcode AS 'Transaction Location Zipcode', 

   case when T.idstatus=30 AND T.IdPaymentType in (1,4) then case when d.idbranch is not null then ISNULL(tpi.BranchCode,'') else '' end +' '+isnull(p1.payername,'') else '' end 'Branch'  
                    , case when t.idstatus=30 AND t.IdPaymentType in (1,4) then ISNULL(TPI.DateOfPayment,'') else '' end AS Date
                    , case when t.idstatus=30 AND t.IdPaymentType in (1,4) then isnull(e.CityName,'') else '' end 'City'
                    , case when t.idstatus=30 AND t.IdPaymentType in (1,4) then isnull(f.StateName,'') else '' end 'State'
 
FROM
      Transfer T WITH (NOLOCK)
      Join Agent AS A WITH(NOLOCK) on (T.IdAgent = A.IdAgent)
      Join CountryCurrency Y WITH(NOLOCK) on (T.IdCountryCurrency = Y.IdCountryCurrency)
      Join Country O WITH(NOLOCK) on (Y.IdCountry = O.IdCountry)
	  left join Branch Br WITH(NOLOCK) on Br.IdBranch = T.IdBranch      
	  left join City BrC WITH(NOLOCK) on BrC.IdCity = Br.IdCity      
	  left join State BrS WITH(NOLOCK) on BrS.IdState = BrC.IdState   
	  Join Country C WITH(NOLOCK) on (BrS.IdCountry = c.IdCountry)

      Left Join CustomerIdentificationType I WITH(NOLOCK) on (I.IdCustomerIdentificationType=T.CustomerIdCustomerIdentificationType)
	  inner Join Customer AS Ctr WITH(NOLOCK) on (T.IdCustomer=Ctr.IdCustomer) /*2016-Oct-05*/

	left join [TransferPayInfo] TPI (NOLOCK) ON TPI.IdTransfer = t.IdTransfer
            and TPI.IdTransferPayInfo=(select max(tt.IdTransferPayInfo) from TransferPayInfo tt  WITH(NOLOCK)  where tt.IdTransfer =T.IdTransfer)
	left join branch d WITH(NOLOCK) on d.IdBranch= case when tpi.idtransfer is not null then tpi.idbranch else 0 end
	left Join City E With(Nolock) on (E.IdCity=D.IdCity)
    left Join State F With(Nolock) on (F.IdState=E.IdState)
	left join payer p1 WITH(NOLOCK) on d.idpayer=p1.idpayer
     
WHERE T.DateOfTransfer >= @StartDate AND T.DateOfTransfer <=@EndDate
	AND   NOT T.IdStatus IN ('1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','22','31','41')
 
	AND	T.IdAgent = isnull(@IdAgent,T.IdAgent)
	AND	T.AmountInDollars >=isnull(@Amount,0)
	AND T.IdCustomer = isnull(@IdCustomer,T.IdCustomer)
	AND T.IdBeneficiary = isnull(@IdBeneficiary,T.IdBeneficiary)
	AND A.IdOwner = isnull(@IdOwner,A.IdOwner)

UNION
 
SELECT
      --A.AgentCode AS 'Agent Code',
	  T.Folio  AS 'Folio',
      T.ClaimCode  AS 'Transaction Number',
      T.DateOfTransfer AS 'Transaction Date',
      T.AmountInDollars AS 'Transaction Amount in US dollars ',
      T.ReferenceExRate AS 'Rate of Exchange',
      T.FEE AS 'Transaction Fee or Commission',
      T.CustomerName AS 'Customer First Name',   
      T.CustomerFirstLastName AS 'Customer P. Last Name',
      T.CustomerSecondLastName AS 'Customer M. Last Name',
      T.CustomerAddress AS 'Customer Address',
      T.CustomerCity AS 'Customer City',
      T.CustomerState AS 'Customer State',

      --T.CustomerPhoneNumber AS 'Customer Telephone Number',
	  (CASE WHEN Len(isnull(T.CustomerPhoneNumber,''))=0 THEN Ctr.PhoneNumber ELSE T.CustomerPhoneNumber END) AS 'Customer Telephone Number',  /*2016-Oct-05*/

	  --T.CustomerCelullarNumber AS 'Customer Cellular Number',
	  (CASE WHEN Len(isnull(T.CustomerCelullarNumber,''))=0 THEN Ctr.CelullarNumber ELSE T.CustomerCelullarNumber END) AS 'Customer Cellular Number',  /*2016-Oct-05*/
	  
      --T.CustomerSSNumber AS 'Customer Social Security Number',   
	  (CASE WHEN Len(isnull(T.CustomerSSNumber,''))=0 THEN Ctr.SSNumber ELSE T.CustomerSSNumber END) AS 'Customer Social Security Number',  /*2016-Oct-05*/

	  --I.Name AS 'Customer Photo ID Type',
	  (CASE WHEN Len(isnull(I.Name,''))=0 THEN 
		(SELECT TOP 1 NAME FROM  CustomerIdentificationType AS II WITH (NOLOCK) WHERE II.IdCustomerIdentificationType = Ctr.IdCustomerIdentificationType)
	   ELSE I.Name END) AS 'Customer Photo ID Type',  /*2016-Oct-12*/

      --T.CustomerIdentificationNumber AS 'Customer Photo ID Number',
	  (CASE WHEN Len(isnull(T.CustomerIdentificationNumber,''))=0 THEN Ctr.IdentificationNumber ELSE T.CustomerIdentificationNumber END) AS 'Customer Photo ID Number',  /*2016-Oct-12*/

      --T.CustomerBornDate AS 'Customer Date of Birth',
	  (CASE WHEN Len(isnull(Convert(Varchar(10),T.CustomerBornDate,112),''))=0 THEN Ctr.BornDate ELSE T.CustomerBornDate END) AS 'Customer Date of Birth',  /*2016-Oct-12*/

      --T.CustomerOccupation AS 'Customer Occupation',
	  (CASE WHEN Len(isnull(T.CustomerOccupation,''))=0 THEN Ctr.Occupation ELSE T.CustomerOccupation END) AS 'Customer Occupation',  /*2016-Oct-12*/

      T.BeneficiaryName AS 'Beneficiary First Name',
      T.BeneficiaryFirstLastName AS 'Beneficiary P. Last Name',
      T.BeneficiarySecondLastName AS 'Beneficiary M. Last Name',
      T.BeneficiaryAddress AS 'Beneficiary Address',

		BrC.CityName AS 'Beneficiary City',
		BrS.StateName AS 'Beneficiary State',
		C.CountryName  AS 'Beneficiary Country',
		T.BeneficiaryPhoneNumber AS 'Beneficiary Telephone Number',

		A.AgentName AS 'Agent Name',
		A.AgentAddress AS 'Transaction Location Address',
		A.AgentCity AS 'Transaction Location City',
		A.AgentState      AS 'Transaction Location State',
		A.AgentZipcode AS 'Transaction Location Zipcode',
	
	 case when T.idstatus=30 AND T.IdPaymentType in (1,4) then case when d.idbranch is not null then ISNULL(tpi.BranchCode,'') else '' end +' '+isnull(p1.payername,'') else '' end 'Branch'  
                    , case when t.idstatus=30 AND t.IdPaymentType in (1,4) then ISNULL(TPI.DateOfPayment,'') else '' end AS Date
                    , case when t.idstatus=30 AND t.IdPaymentType in (1,4) then isnull(e.CityName,'') else '' end 'City'
                    , case when t.idstatus=30 AND t.IdPaymentType in (1,4) then isnull(f.StateName,'') else '' end 'State'
 
FROM TransferCLOSED T  WITH(NOLOCK) 
    Join Agent A WITH(NOLOCK) on (T.IdAgent = A.IdAgent)
    Join CountryCurrency Y WITH(NOLOCK) on (T.IdCountryCurrency = Y.IdCountryCurrency)
    Join Country O WITH(NOLOCK) on (Y.IdCountry = O.IdCountry)
	left join Branch Br WITH(NOLOCK) on Br.IdBranch = T.IdBranch      
	left join City BrC WITH(NOLOCK) on BrC.IdCity = Br.IdCity      
	left join State BrS WITH(NOLOCK) on BrS.IdState = BrC.IdState   
	Join Country C WITH(NOLOCK) on (BrS.IdCountry = c.IdCountry)

    Left Join CustomerIdentificationType I WITH(NOLOCK) on (I.IdCustomerIdentificationType=T.CustomerIdCustomerIdentificationType)
	inner Join Customer AS Ctr WITH(NOLOCK) on (T.IdCustomer=Ctr.IdCustomer) /*2016-Oct-05*/
     
	left join [TransferPayInfo] TPI (NOLOCK) ON TPI.IdTransfer = T.IdTransferClosed and TPI.IdTransferPayInfo=(select max(tt.IdTransferPayInfo) from TransferPayInfo tt  WITH(NOLOCK) where tt.IdTransfer =T.IdTransferClosed)
	left join branch d  WITH(NOLOCK) on d.IdBranch= case when tpi.idtransfer is not null then tpi.idbranch else 0 end
	left Join City E With(Nolock) on (E.IdCity=D.IdCity)
	left Join State F With(Nolock) on (F.IdState=E.IdState)
	left join payer p1  WITH(NOLOCK) on d.idpayer=p1.idpayer

WHERE T.DateOfTransfer >= @StartDate AND T.DateOfTransfer <= @EndDate
	AND	NOT T.IdStatus IN ('1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','22','31','41')
 
	AND	T.IdAgent = isnull(@IdAgent,T.IdAgent)
	AND T.AmountInDollars >=isnull(@Amount,0)
	AND T.IdCustomer = isnull(@IdCustomer,T.IdCustomer)
	AND T.IdBeneficiary = isnull(@IdBeneficiary,T.IdBeneficiary)
	AND A.IdOwner = isnull(@IdOwner,A.IdOwner)

--ORDER BY T.DateOfTransfer
)
SELECT
	[Folio],
	[Transaction Number],
	[Transaction Date],
	[Transaction Amount in US dollars ],
	[Rate of Exchange],
	[Transaction Fee or Commission],
	[Customer First Name],   
	[Customer P. Last Name],
	[Customer M. Last Name],
	[Customer Address],
	[Customer City],
	[Customer State],
	[Customer Telephone Number],
	[Customer Cellular Number],
	[Customer Social Security Number],

	--[Customer Photo ID Type],
	(CASE WHEN
		((Len(isnull([Customer Photo ID Number],''))=0)
			OR
		([Customer Date of Birth] IS NULL))
		THEN NULL ELSE [Customer Photo ID Type] END) AS 'Customer Photo ID Type',

	--[Customer Photo ID Number],
	(CASE WHEN
		((Len(isnull([Customer Photo ID Number],''))=0)
			OR
		([Customer Date of Birth] IS NULL))	
		THEN NULL ELSE [Customer Photo ID Number] END) AS 'Customer Photo ID Number',

	--[Customer Date of Birth],
	(CASE WHEN
		((Len(isnull([Customer Photo ID Type],''))=0)
			OR
		(Len(isnull([Customer Photo ID Number],''))=0))	
		THEN NULL ELSE [Customer Date of Birth] END) AS 'Customer Date of Birth',

	[Customer Occupation],
	[Beneficiary First Name],
	[Beneficiary P. Last Name],
	[Beneficiary M. Last Name],
	[Beneficiary Address],
	[Beneficiary City],
	[Beneficiary State],
	[Beneficiary Country],
	[Beneficiary Telephone Number],
	[Agent Name],
	[Transaction Location Address],
	[Transaction Location City],
	[Transaction Location State],
	[Transaction Location Zipcode],

	[Branch],
	[Date],
	[City],
	[State]
FROM CTE_TRAN
	ORDER BY [Transaction Date];