
CREATE PROCEDURE [TransFerTo].[st_GetCustomerFrequentNumber]
(
    @IdCustomer INT
)
AS
/********************************************************************
<Author>Unknown</Author>
<app>MaxiAgente</app>
<Description>This stored is used in agent for get frequents numbers of a customer</Description>

<ChangeLog>
<log Date="28/02/2018" Author="Mhinojo">Condition to select frequents numbers of client if hasn't cell phone number</log>
</ChangeLog>
*********************************************************************/
DECLARE @CellPhoneNumber NVARCHAR(MAX)

SELECT @CellPhoneNumber=celullarnumber FROM customer WHERE idcustomer=@IdCustomer

IF @CellPhoneNumber IS NULL OR LTRIM(RTRIM(@CellPhoneNumber)) = ''
SELECT IdCustomerFrequentNumber,ISNULL(NickName,'') NickName,BeneficiaryCelullar 
FROM [TransFerTo].CUSTOMERFREQUENTNUMBER 
WHERE idcustomer=@IdCustomer AND idgenericstatus=1
ELSE
SELECT IdCustomerFrequentNumber,ISNULL(NickName,'') NickName,BeneficiaryCelullar 
FROM [TransFerTo].CUSTOMERFREQUENTNUMBER 
WHERE
idcustomer IN (SELECT idcustomer FROM Customer WHERE celullarnumber=@CellPhoneNumber)
AND idgenericstatus=1