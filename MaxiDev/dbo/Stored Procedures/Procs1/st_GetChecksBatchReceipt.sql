CREATE PROCEDURE [dbo].[st_GetChecksBatchReceipt] 
    @IdChecks VARCHAR (MAX)
AS
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

DECLARE @Checks AS TABLE 
(
    IdCheck  INT    
);
DECLARE @IdCheck VARCHAR(20) = null

WHILE LEN(@IdChecks) > 0
BEGIN
    IF PATINDEX('%,%',@IdChecks) > 0
    BEGIN
        SET @IdCheck = SUBSTRING(@IdChecks, 0, PATINDEX('%,%',@IdChecks));
		INSERT INTO @Checks (IdCheck) VALUES (@IdCheck);
        SET @IdChecks = SUBSTRING(@IdChecks, LEN(@IdCheck + ',') + 1, LEN(@IdChecks));
    END
    ELSE
    BEGIN
        SET @IdCheck = @IdChecks;
        SET @IdChecks = NULL;
        INSERT INTO @Checks (IdCheck) VALUES (@IdCheck);-- SELECT @IdCheck
    END
END
   
DECLARE @CorporationPhone varchar(50)      
SET @CorporationPhone = dbo.GetGlobalAttributeByName('CorporationPhone');      
      
 SELECT     
  row_number() over  (order by C.IdCheck desc) as NumIndex,
  @CorporationPhone CorporationPhone,      
  '' CorporationName,     
  '' ReceiptBillPaymentEnglishMessage,
  '' ReceiptBillPaymentSpanishMessage,  
  ISNULL(A.AgentCode,'')+' '+ ISNULL(A.AgentName,'') AgentName,      
  A.AgentAddress,      
  ISNULL(A.AgentCity,'')+ ' '+ ISNULL(A.AgentState,'') + ' '+ REPLACE(STR(isnull(A.AgentZipcode,0), 5), SPACE(1), '0')  AgentLocation,      
  A.AgentPhone,
  A.AgentCity,
  A.AgentState,
  A.AgentZipcode,
  A.AgentCode,
  A.AgentFax,
  C.IdCheck,       
  C.CheckNumber,
  getdate()  PaymentDate,  
  C.Amount,
  C.Fee,
  U.UserLogin,
  C.BachCode AS BatchCode
 FROM 
			@Checks CT 
 INNER JOIN Checks C with(nolock) ON CT.IdCheck = C.IdCheck
 INNER JOIN Agent A with(nolock) ON C.IdAgent = A.IdAgent
 INNER JOIN Users U with(nolock) ON U.IdUser = C.EnteredByIdUser
 ORDER BY C.IdCheck;

	


