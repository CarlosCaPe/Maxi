CREATE procedure [dbo].[st_FindDenyListIssuerByNameChecks]  
(  
    @Name varchar(max),  
    @IdLenguage int,
    @HasError bit output,            
    @Message nvarchar(max) output    
)  
AS 
/********************************************************************
<Author>Aldo Morán Márquez</Author>
<app>MaxiCorp</app>
<Description>Use to search if issuer exists in list of deny</Description>

<ChangeLog>
<log Date="20/03/2015" Author="mAldo">Creacion del Store</log>
<log Date="01/02/2017" Author="mdelgado">Req. #013017-5, Logic change for deny list checks</log>
<log Date="17/01/2018" Author="jmolina">Performance: Se cambio IN() por Exists()</log>
<log Date="19/12/2018" Author="jmolina">Performance: Se agrego with(nolock)</log>
</ChangeLog>
*********************************************************************/ 
	SET NOCOUNT ON  
	DECLARE @Tot INT

	IF @IdLenguage IS NULL 
		SET @IdLenguage=2
	SET @HasError = 0
	SET @Message = 'Ok'

	SELECT  @Tot = count(1) 
	  FROM [dbo].IssuerChecks As ic WITH(NOLOCK)
	 WHERE 1 = 1
	   AND Name LIKE '%' + @Name + '%'
	   AND EXISTS (
			       SELECT 1 
			         FROM [dbo].[DenyListIssuerChecks] dc WITH(NOLOCK)
			       	-- s1017 denyList Only on Hold when action is BlockTransfer, only apply to Checks.
		            INNER JOIN [dbo].DenyListIssuerCheckActions dca WITH(NOLOCK) ON dca.IdDenyListIssuerCheck = dc.IdDenyListIssuerCheck
			        INNER JOIN [dbo].KYCAction ka WITH(NOLOCK) ON ka.IdKYCAction = dca.IdKYCAction
			        WHERE 1 = 1
			          AND idgenericstatus = 1 
			          AND ka.IdKYCAction = 5
			          AND ic.IdIssuer = dc.IdIssuerCheck
	              )

	IF ISNULL(@Tot,0)>0
	BEGIN 
		SET @HasError=1
	END