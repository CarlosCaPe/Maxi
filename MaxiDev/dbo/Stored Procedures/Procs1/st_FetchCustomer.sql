CREATE PROCEDURE [dbo].[st_FetchCustomer]
(
	@Offset			BIGINT,
	@Limit			BIGINT
)
AS
BEGIN

SELECT 
	   COUNT(*) OVER() _PagedResult_Total,
	[IdCustomer] as [Id] 
      ,[Name] as [Name]
  FROM [dbo].[Customer]WITH(NOLOCK)
	
	ORDER BY IdCustomer
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY
END
