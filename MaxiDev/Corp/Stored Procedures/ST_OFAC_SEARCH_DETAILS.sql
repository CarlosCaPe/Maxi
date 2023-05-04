CREATE PROCEDURE [Corp].[ST_OFAC_SEARCH_DETAILS]
  (   
	@f_name   nvarchar(64) ,   
	@l_name_1  nvarchar(64),   
	@l_name_2    nvarchar(64)  
 )   
AS  
  
 
exec dbo.st_OfacSearchDetailsLetterPairsClr
@f_name,
@l_name_1,
@l_name_2
