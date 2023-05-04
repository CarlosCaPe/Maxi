CREATE PROCEDURE [dbo].[st_SearchCustomer]
(
 	@IdCustomer INT,
	@Name NVARCHAR(MAX),
	@FirstLastName NVARCHAR(MAX),
	@SecondLastName NVARCHAR(MAX)
)
AS
BEGIN
SET NOCOUNT ON;


	IF (ISNULL(@IdCustomer,0)>0)
	BEGIN
		SELECT IdCustomer, Name, FirstLastName, SecondLastName , BornDate, City, State 
		FROM Customer
		WHERE IdCustomer = @IdCustomer
	END
	ELSE
	BEGIN
		SELECT IdCustomer, Name, FirstLastName, SecondLastName , BornDate , City, State
		FROM Customer
		WHERE 
		((LEN(ISNULL(@Name,''))=0) OR LEN(ISNULL(@name,''))>0 AND Name LIKE '%'+ @Name+'%' )
		AND ((LEN(ISNULL(@FirstLastName,''))=0) OR LEN(ISNULL(@FirstLastName,''))>0 AND  FirstLastName LIKE '%'+@FirstLastName+'%')
		AND ((LEN(ISNULL(@SecondLastName,''))=0) OR LEN(ISNULL(@SecondLastName,''))>0 AND SecondLastName LIKE '%'+@SecondLastName+'%')
	END
END   
