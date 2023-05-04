CREATE PROCEDURE [Corp].[st_GetWellsFargoReportStatusExcelById]
(
 @CurrentIdReportHistory INT
)
AS
/********************************************************************
<Author>mdelgado</Author>
<app>MaxiCorp</app>
<Description>Agent Report Witgh Needs & Request Wells Fargo Sub Account</Description>

<ChangeLog>
<log Date="2017/07/25" Author="mdelgado">S28 :: Creation Store</log>
</ChangeLog>

<example>
EXEC st_GetWellsFargoReportStatusExcelById 53
</example>

********************************************************************/
BEGIN
	SELECT [idWellsFargoReportDetailExcel]
      ,[IdAgentsReportWellsFargo]
      ,[Master_Account]
      ,[Master_Account_Name]
      ,[Master_Account_TIN]
      ,[Agent_Code]
      ,[Agent_Address]
      ,[City]
      ,[Agents_Main_Revenue_Source]
      ,[Agent_Owner_1]
      ,[Owner_1_First_Name]
      ,[Owner_1_Last_Name]
      ,[Owner_1_SSNTIN]
      ,[Owner_1_Street_Address]
      ,[Owner_1_City]
      ,[Owner_1_State]
      ,[Owner_1_Zip_Code]
      ,[Owner_1_Country]
      ,[Owner_1_Date_of_Birth]
      ,[Agent_Contact_Number]
      ,[State]
      ,[ZIP_Code]
      ,[Country]
      ,[Agent_Entity_Type]
      ,[Purpose_of_Sub_Account]
      ,[Number_of_Agent_Locations]
  FROM [dbo].[WellsFargoReportDetailExcel]
	 WHERE IdAgentsReportWellsFargo = @CurrentIdReportHistory

END


