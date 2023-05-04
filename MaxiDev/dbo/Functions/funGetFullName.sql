-- =============================================
-- Author:		O. Grageda
-- Create date: 5 FEB 2015
-- Description:	Returns the cust or ben Full Name without
-- =============================================
create FUNCTION  [dbo].[funGetFullName]
(
	@Name nvarchar(80)
	,@FirstLastName nvarchar(80)
	,@SecondLastName nvarchar(80)
	,@WithSpaces bit
)
RETURNS nvarchar(240)
AS
BEGIN
	IF @Name not like '%[a-zA-Z]%' and len(@Name) = 1
		SET @Name = ''
	IF @FirstLastName not like '%[a-zA-Z]%' and len(@FirstLastName) = 1
		SET @FirstLastName = ''
	IF @SecondLastName not like '%[a-zA-Z]%' and len(@SecondLastName) = 1
		SET @SecondLastName = ''
	---
	SET @Name = LTRIM(RTRIM(@Name))
	SET @FirstLastName = LTRIM(RTRIM(@FirstLastName))
	SET @SecondLastName = LTRIM(RTRIM(@SecondLastName))
	---
	IF @WithSpaces  = 0
	BEGIN
		RETURN ISNULL(@Name,'')+ISNULL(@FirstLastName,'')+ISNULL(@SecondLastName,'')
	END
	ELSE
	BEGIN
		RETURN ISNULL(@Name,'')+' '+ISNULL(@FirstLastName,'')+' '+ISNULL(@SecondLastName,'')
	END
	RETURN ''
END
