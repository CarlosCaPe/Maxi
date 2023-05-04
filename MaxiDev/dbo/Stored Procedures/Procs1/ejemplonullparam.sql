CREATE PROCEDURE dbo.ejemplonullparam 
	@par1 INT,
	@par2 INT = NULL,
	@par3 INT
AS
BEGIN
	SELECT @par1, @par2, @par3
END	