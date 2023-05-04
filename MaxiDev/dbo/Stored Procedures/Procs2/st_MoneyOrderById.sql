/********************************************************************
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
	<log Date="03/08/2023" Author="acontreras">Se crea SP</log>
	<log Date="03/16/2023" Author="jcsierra">Fix column PayToOrder</log>
	<log Date="03/21/2023" Author="jcsierra">Add IdCustomer column</log>
</ChangeLog>
********************************************************************/
CREATE   PROCEDURE [dbo].[st_MoneyOrderById]
(
	
	@IdSaleRecord		INT
)
AS
BEGIN
	SELECT	
		sr.IdSaleRecord,
		sr.IdCustomer,
		sr.CreationDate,
		sr.IdAgent,
		a.AgentName,
		sr.SequenceNumber,
		sr.IdStatus,
		s.StatusName,
		sr.FeeAmount,
		sr.Amount  ,
		sr.TotalAmount,
		sr.Payee PayToOrder,
		sr.AgentCommission,
		sr.CorporateCommission,
		sr.CustomerName,
		sr.CustomerFirstLastName,
		sr.CustomerSecondLastName,
		sr.CustomerCelullarNumber CustomerCelullarNumber,
		sr.CustomerIdIdentificationType,
		ct.Name CustomerIdentificationType,
		sr.CustomerIdTypeTaxId,
		tt.TypeName CustomerTypeTaxId,
		sr.CustomerSSN,
		sr.CustomerIdentificationNumber,
		sr.CustomerBornDate,
		(c.Address+' '+c.City +' '+c.State) Address,
		c.Occupation,
		c.OccupationDetail,
		sr.CustomerIdOccupation,
		sr.CustomerIdSubcategoryOccupation,
		sr.CustomerSubcategoryOccupationOther
	FROM 
		MoneyOrder.SaleRecord sr WITH (NOLOCK) 
		INNER JOIN Agent a WITH (NOLOCK)  ON a.IdAgent = sr.IdAgent
		INNER JOIN Status s WITH (NOLOCK)  ON s.IdStatus = sr.IdStatus
		INNER JOIN Customer c WITH (NOLOCK) ON c.IdCustomer = sr.IdCustomer

		LEFT JOIN CustomerIdentificationType ct WITH(NOLOCK) ON ct.IdCustomerIdentificationType = sr.CustomerIdIdentificationType
		LEFT JOIN TypeTaxId tt WITH(NOLOCK) ON tt.IdTypeTaxId = sr.CustomerIdTypeTaxId
	WHERE
		sr.IdSaleRecord = @IdSaleRecord
END
