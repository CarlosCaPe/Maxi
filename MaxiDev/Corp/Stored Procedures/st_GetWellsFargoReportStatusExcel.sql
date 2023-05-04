CREATE PROCEDURE [Corp].[st_GetWellsFargoReportStatusExcel]
(
	@Agents varchar(max),
	@AgentsApplications varchar(max)
)
AS
/********************************************************************
<Author>mdelgado</Author>
<app>MaxiCorp</app>
<Description>Agent Report Witgh Needs & Request Wells Fargo Sub Account</Description>

<ChangeLog>
<log Date="2017/07/06" Author="mdelgado">S28 :: Creation Store</log>
</ChangeLog>
********************************************************************/
BEGIN

	SELECT
				'4125886457' as [Master_Account],
				'Maxitransfers Corporation' as [Master_Account_Name],
				'582563969' as [Master_Account_TIN],
				Cast(A.Creationdate as date) AS 'CreationDate',
				A.AgentCode as 'Agent_Code', 
				ISNULL(A.SubAccount,'') as 'Agent_Legal_Name', 
				ISNULL(A.SubAccount,'') as 'Agent_DBA_Trade_Name',
				ISNULL(A.SubAccount,'') as 'Agent_TIN_EIN', 
				A.AgentAddress as 'Agent_Address',A.agentcity as 'City', A.agentState as 'State', A.agentzipcode as 'ZIP_Code',
				ISNULL(A.SubAccount,'') as 'Country', ISNULL(A.SubAccount,'') as 'Agent_Entity_Type', P.Agentactivity as 'Agents_Main_Revenue_Source', 
				ISNULL(A.SubAccount,'') as 'Purpose_of_Sub_Account',
				ISNULL(A.SubAccount,'') as 'Number_of_Agent_Locations', 
				O.Name + ' '+ O.LastName  + ' '+ O.SecondLastName as 'Agent_Owner_#1', 
				O.Name as 'Owner_#1_First_Name', 
				ISNULL(A.SubAccount,'') as 'Owner_#1_Middle_Name',
				ISNULL(O.LastName  + ' '+ O.SecondLastName,'') as 'Owner_#1_Last_Name', 
				O.SSN as 'Owner_#1_SSN/TIN', O.Address as 'Owner_#1_Street_Address', O.City as 'Owner_#1_City', 
				O.State as 'Owner_#1_State', O.Zipcode as 'Owner_#1_Zip_Code', A.SubAccount as 'Owner_#1_Country', 
				--Cast(O.Borndate as date) as 'Owner_#1_Date_of_Birth',
				convert(VARCHAR(10),O.Borndate,101) as 'Owner_#1_Date_of_Birth',				
				A.SubAccount as 'Owner_#2_of_Agent', A.SubAccount as 'Owner_#2_First_Name', A.SubAccount as 'Owner_#2_Middle_Name', A.SubAccount as 'Owner_#2_Last_Name', A.SubAccount as 'Owner_#2_SSN/TIN', 
				A.SubAccount as 'Owner_#2_Street_Address', A.SubAccount as 'Owner_#2_City', A.SubAccount as 'Owner_#2_State', A.SubAccount as 'Owner_#2_Zip_Code', 
				A.SubAccount as 'Owner_#2_Country', 
				--
				A.SubAccount as 'Owner_#2_Date_of_Birth', 
				A.SubAccount as 'Agent_Owner_#3', A.SubAccount as 'Owner_#3_First_Name', A.SubAccount as 'Owner_#3_Middle_Name',
				A.SubAccount as 'Owner_#3_Last_Name', A.SubAccount as 'Owner_#3_SSN/TTN', A.SubAccount as 'Owner_#3_Street_Address', A.SubAccount as 'Owner_#3_City', 
				A.SubAccount as 'Owner_#3_State', A.SubAccount as 'Owner_#3_Zip_Code', A.SubAccount as 'Owner_#3_Country', A.SubAccount as 'Owner_#3_Date_of_Birth', 
				A.SubAccount as 'Agent_Owner_#4', A.SubAccount as 'Owner_#4_First_Name', A.SubAccount as 'Owner_#4_Middle_Name', A.SubAccount as 'Owner_#4_Last_Name', A.SubAccount as 'Owner_#4_SSN/TIN', 
				A.SubAccount as 'Owner_#4_Street_Address', A.SubAccount as 'Owner_#4_City', A.SubAccount as 'Owner_#4_State', A.SubAccount as 'Owner_#4_Zip_Code', 
				A.SubAccount as 'Owner_#4_Country', A.SubAccount as 'Owner_#4_Date_of_Birth', A.agentphone as 'Agent_Contact_Number'

	From Agent A
	LEFT JOIN Owner O ON A.idowner = O.idowner
	LEFT JOIN agentapplications P ON P.agentcode = A.agentcode
	WHERE		
	a.IdAgent in (SELECT * FROM [dbo].[fnSplit]  (@agents, ','))

	UNION ALL

	SELECT		
				'4125886457' as [Master_Account],
				'Maxitransfers Corporation' as [Master_Account_Name],
				'582563969' as [Master_Account_TIN],
				A.Dateofcreation as 'CreationDate',A.AgentCode as 'Agent_Code',
				A.Guarantortitle as 'Agent_Legal_Name', A.Guarantortitle as 'Agent_DBA_Trade_Name',
				A.Guarantortitle as 'Agent_TIN_EIN', A.AgentAddress as 'Agent_Address',A.agentcity as 'City', A.agentState as 'State', A.agentzipcode as 'ZIP_Code',
				A.Guarantortitle as 'Country', A.Guarantortitle as 'Agent_Entity_Type', A.Agentactivity as 'Agents_Main_Revenue_Source', A.Guarantortitle as 'Purpose_of_Sub_Account',
				A.Guarantortitle as 'Number_of_Agent_Locations', O.Name  + ' '+ O.LastName  + ' '+ O.SecondLastName as 'Agent_Owner_#1', O.Name as 'Owner_#1_First_Name', A.Guarantortitle as 'Owner_#1_Middle_Name',
				O.LastName  + ' '+ O.SecondLastName as 'Owner_#1_Last_Name', O.SSN as 'Owner_#1_SSN/TIN', O.Address as 'Owner_#1_Street_Address', O.City as 'Owner_#1_City', 
				O.State as 'Owner_#1_State', O.Zipcode as 'Owner_#1_Zip_Code', A.Guarantortitle as 'Owner_#1_Country', 
				--O.Borndate as 'Owner_#1_Date_of_Birth',
				convert(VARCHAR(10),O.Borndate,101) as 'Owner_#1_Date_of_Birth',
				A.Guarantortitle as 'Owner_#2_of_Agent', A.Guarantortitle as 'Owner_#2_First_Name', A.Guarantortitle as 'Owner_#2_Middle_Name', A.Guarantortitle as 'Owner_#2_Last_Name', A.Guarantortitle as 'Owner_#2_SSN/TIN', 
				A.Guarantortitle as 'Owner_#2_Street_Address', A.Guarantortitle as 'Owner_#2_City', A.Guarantortitle as 'Owner_#2_State', A.Guarantortitle as 'Owner_#2_Zip_Code', 
				A.Guarantortitle as 'Owner_#2_Country', A.Guarantortitle as 'Owner_#2_Date_of_Birth', A.Guarantortitle as 'Agent_Owner_#3', A.Guarantortitle as 'Owner_#3_First_Name', A.Guarantortitle as 'Owner_#3_Middle_Name',
				A.Guarantortitle as 'Owner_#3_Last_Name', A.Guarantortitle as 'Owner_#3_SSN/TTN', A.Guarantortitle as 'Owner_#3_Street_Address', A.Guarantortitle as 'Owner_#3_City', 
				A.Guarantortitle as 'Owner_#3_State', A.Guarantortitle as 'Owner_#3_Zip_Code', A.Guarantortitle as 'Owner_#3_Country', A.Guarantortitle as 'Owner_#3_Date_of_Birth', 
				A.Guarantortitle as 'Agent_Owner_#4', A.Guarantortitle as 'Owner_#4_First_Name',A.Guarantortitle as 'Owner_#4_Middle_Name', A.Guarantortitle as 'Owner_#4_Last_Name', A.Guarantortitle as 'Owner_#4_SSN/TIN', 
				A.Guarantortitle as 'Owner_#4_Street_Address', A.Guarantortitle as 'Owner_#4_City', A.Guarantortitle as 'Owner_#4_State', A.Guarantortitle as 'Owner_#4_Zip_Code', 
				A.Guarantortitle as 'Owner_#4_Country', A.Guarantortitle as 'Owner_#4_Date_of_Birth', A.agentphone as 'Agent_Contact_Number'
	FROM
		Agentapplications A
		LEFT JOIN Owner O ON A.idowner = O.idowner
	WHERE		
		a.IdAgentApplication in (SELECT * FROM [dbo].[fnSplit]  (@AgentsApplications, ','))
END
