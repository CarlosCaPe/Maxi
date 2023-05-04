CREATE PROCEDURE [Corp].[st_GetCheckProcessorBank]
as

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

 SELECT IdCheckProcessorBank, [Name]
   FROM CheckProcessorBank WITH(NOLOCK)
