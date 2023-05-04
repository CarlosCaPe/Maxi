


CREATE PROCEDURE [dbo].[TextoEnSP]
	@Texto varchar(50)
AS

Select so.ID, so.Name, sc.Text
from sysobjects so join syscomments sc on (so.ID=sc.ID)
Where Cast(sc.Text as Varchar(4000)) like '%'+@Texto+'%'




