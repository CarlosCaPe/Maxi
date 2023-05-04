
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_CC_GetMakerByAcc]

@RoutingNum int,
@AccountNum bigint

AS
BEGIN

/*SELECT m.* FROM CC_MakerAccount ma JOIN CC_MakerAccountRel mar ON (ma.MakerAccount_ID=mar.MakerAccount_ID)
  JOIN CC_Maker m ON (mar.Maker_ID=m.Maker_ID)
WHERE MA_RoutingNumInt=@RoutingNum AND MA_AccountNumInt=@AccountNum
*/

SELECT Maker_ID=IdIssuer, MAK_DateCreated=DateOfCreation, MAK_IdUserCreated=EnteredByIdUser, MAK_Name=Name,
	MAK_Address='', MAK_City='', MAK_State='', IdState=0, MAK_ZipCode='', MAK_Active=CAST(1 as bit)
  FROM IssuerChecks
WHERE RoutingNumber=@RoutingNum AND AccountNumber=@AccountNum



END
