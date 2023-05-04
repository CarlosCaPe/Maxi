-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[sp_CC_SearchCustomer]

@FullName varchar(150)

AS
BEGIN
DECLARE
@FullNameLike varchar(150)

SET @FullNameLike = REPLACE(@FullName, ' ', '%')

SELECT IdCustomer, FullName, Name, FirstLastName, SecondLastName
  Address, City, State, PhoneNumber, CelullarNumber
FROM Customer WITH (NOLOCK) WHERE FullName=@FullName
UNION
SELECT IdCustomer, FullName, Name, FirstLastName, SecondLastName
  Address, City, State, PhoneNumber, CelullarNumber
FROM Customer WITH (NOLOCK) WHERE FullName LIKE @FullNameLike

ORDER BY FullName

END
