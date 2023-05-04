CREATE procedure [dbo].[st_FindDenyListByNameChecks]  
(  
    @Name varchar(max),  
    @FirstLastName nvarchar(max),  
    @SecondLastName nvarchar(max),
    @IdLenguage int,
    @IsCustomer bit,
    @HasError bit output,            
    @Message nvarchar(max) output    
)  
AS  
/********************************************************************
<Author>Aldo Morán Márquez</Author>
<app>MaxiCorp</app>
<Description>Use to search if Name of customer / Beneficiary exists in list of deny</Description>

<ChangeLog>
<log Date="20/03/2015" Author="mAldo">Creacion del Store</log>
<log Date="01/02/2017" Author="mdelgado">Req. #013017-5, Logic change for deny list checks</log>
<log Date="15/01/2018" Author="jmolina">Performance: se agrego EXISTS() en lugar de IN() </log>
</ChangeLog>
*********************************************************************/
	SET NOCOUNT ON  
	DECLARE @Tot INT

	IF @IdLenguage IS NULL 
		SET @IdLenguage = 2
	SET @HasError = 0
	SET @Message ='Ok'

	IF (@IsCustomer = 1)
	BEGIN
		SELECT @Tot = COUNT(1) 
		  FROM [dbo].customer As c WITH(NOLOCK)
		 WHERE 1 = 1
		   AND Name like '%' + @Name + '%' 
		   AND FirstLastName like '%' + @FirstLastName + '%' 
		   AND SecondLastName like '%' + @SecondLastName + '%' 
		   AND EXISTS (
                       SELECT 1 
                         FROM [dbo].[DenyListCustomer] dc WITH(NOLOCK)
                       	-- s1017 denyList Only on Hold when action is BlockTransfer, only apply to Checks.
                        INNER JOIN [dbo].DenyListCustomerActions dca WITH(NOLOCK) ON dca.IdDenyListCustomer = dc.IdDenyListCustomer
                        INNER JOIN [dbo].KYCAction ka WITH(NOLOCK) ON ka.IdKYCAction = dca.IdKYCAction
                        WHERE 1 = 1
                          AND idgenericstatus = 1 
                          AND ka.IdKYCAction = 5
                          AND dc.IdCustomer = c.IdCustomer
                      ) 
	END
	ELSE
	BEGIN
		SELECT @Tot = COUNT(1) 
		  FROM [dbo].beneficiary As b WITH(NOLOCK)
		 WHERE Name like '%' + @Name + '%'
		   AND FirstLastName like '%' + @FirstLastName + '%'
		   AND SecondLastName like '%' + @SecondLastName +'%'
           AND EXISTS (
                       SELECT 1 
                         FROM [dbo].[DenyListBeneficiary] dc WITH(NOLOCK)
                       	--s1017 denyList Only on Holds when action is BlockTransfer, only apply to checks.
                        INNER JOIN [dbo].DenyListBeneficiaryActions dca WITH(NOLOCK) ON dca.IdDenyListBeneficiary = dc.IdDenyListBeneficiary
                        INNER JOIN [dbo].KYCAction ka WITH(NOLOCK) on ka.IdKYCAction = dca.IdKYCAction
                        WHERE 1 = 1
                          AND dc.idgenericstatus = 1 
                          AND ka.IdKYCAction = 5
						  AND dc.idbeneficiary = b.idbeneficiary
		               )
	END

	IF ISNULL(@Tot,0) > 0
	BEGIN 
		SET @HasError = 1
	END
	