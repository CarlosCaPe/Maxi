CREATE PROCEDURE [dbo].[st_WellsFargoSubAccount_CreateReport]
(	
	@EnteredByIdUser INT,
	@xmlDetail XML,
	@xmlDetailReport XML,
	@HasError BIT OUTPUT
)
AS
	/********************************************************************
	<Author>mdelgado</Author>
	<app>MaxiCorp</app>
	<Description>Create the header and Detail of report generated from user of WellsFargoReport to historical views </Description>

	<ChangeLog>
	<log Date="20170710" Author="mDelgado">Creacion del Store</log>
	</ChangeLog>
	*********************************************************************/
BEGIN
	BEGIN TRY
		SET @HasError = 0

		DECLARE @idReportGereted INT	

		INSERT INTO AgentsReportWellsFargo (IdUserWhoGenerate, ReportDateGenerated) VALUES (@EnteredByIdUser, GETDATE())
		SET @idReportGereted = @@IDENTITY;

		IF (@idReportGereted IS NOT NULL)
		BEGIN 

			DECLARE @DocHandle INT 
			EXEC sp_xml_preparedocument @DocHandle OUTPUT,@xmlDetail

			INSERT INTO AgentsReportWellsFargoDetail			
			SELECT	@idReportGereted, isAgent, idAgent, NeedsWFSubaccount, NeedsWFSubaccountDate, NeedsWFSubaccountIdUser, RequestWFSubaccount, RequestWFSubaccountDate,
					RequestWFSubaccountIdUser, WFSStatus, OpenDate, IdUserSeller, IdAgentStatus	
			FROM OPENXML (@DocHandle, '/WellsFargoReport/Detail',2)
			WITH
			(
				isAgent bit,
				idAgent int,
				NeedsWFSubaccount bit,
				NeedsWFSubaccountDate datetime,
				NeedsWFSubaccountIdUser int,
				RequestWFSubaccount bit,
				RequestWFSubaccountDate datetime,
				RequestWFSubaccountIdUser int,
				WFSStatus int,
				OpenDate datetime,
				IdUserSeller int,
				IdAgentStatus int,
				ReportGeneratedByIdUser int
			);

			EXEC sp_xml_preparedocument @DocHandle OUTPUT,@xmlDetailReport
			INSERT INTO [dbo].[WellsFargoReportDetailExcel]
				([IdAgentsReportWellsFargo],Master_Account,Master_Account_Name,Master_Account_TIN,Agent_Code,Agent_Address
				,City,Agents_Main_Revenue_Source,Agent_Owner_1,Owner_1_First_Name,Owner_1_Last_Name
				,Owner_1_SSNTIN,Owner_1_Street_Address,Owner_1_City,Owner_1_State,Owner_1_Zip_Code
				,Owner_1_Country,Owner_1_Date_of_Birth,Agent_Contact_Number
				,[State],ZIP_Code,Country
				,Agent_Entity_Type,Purpose_of_Sub_Account,Number_of_Agent_Locations

				)
			SELECT 
				@idReportGereted
				,Master_Account,Master_Account_Name,Master_Account_TIN,Agent_Code,Agent_Address
				,City,Agents_Main_Revenue_Source,Agent_Owner_1,Owner_1_First_Name,Owner_1_Last_Name
				,Owner_1_SSNTIN,Owner_1_Street_Address,Owner_1_City,Owner_1_State,Owner_1_Zip_Code
				,Owner_1_Country,Owner_1_Date_of_Birth,Agent_Contact_Number
				,[State],ZIP_Code,Country
				,Agent_Entity_Type,Purpose_of_Sub_Account,Number_of_Agent_Locations

			FROM OPENXML (@DocHandle, '/WellsFargoReport/Detail',2)
			WITH
			 (
				Master_Account VARCHAR(MAX),
				Master_Account_Name VARCHAR(MAX),
				Master_Account_TIN VARCHAR(MAX),
				Agent_Code VARCHAR(MAX),
				Agent_Address VARCHAR(MAX),
				City VARCHAR(MAX),
				Agents_Main_Revenue_Source VARCHAR(MAX),
				Agent_Owner_1 VARCHAR(MAX),
				Owner_1_First_Name VARCHAR(MAX),
				Owner_1_Last_Name VARCHAR(MAX),
				Owner_1_SSNTIN VARCHAR(MAX),
				Owner_1_Street_Address VARCHAR(MAX),
				Owner_1_City VARCHAR(MAX),
				Owner_1_State VARCHAR(MAX),
				Owner_1_Zip_Code VARCHAR(MAX),
				Owner_1_Country VARCHAR(MAX),
				Owner_1_Date_of_Birth VARCHAR(MAX),
				Agent_Contact_Number VARCHAR(MAX),
				[State] VARCHAR(MAX),
				ZIP_Code VARCHAR(MAX),
				Country VARCHAR(MAX),
				Agent_Entity_Type VARCHAR(MAX),
				Purpose_of_Sub_Account VARCHAR(MAX),
				Number_of_Agent_Locations VARCHAR(MAX)
				)

						
			UPDATE Agent SET IdAgentsReportWellsFargo = @idReportGereted
			WHERE idAgent IN (SELECT idAgent FROM AgentsReportWellsFargoDetail WHERE IdAgentsReportWellsFargo = @idReportGereted AND isAgent = 1);
			
			UPDATE AgentApplications SET IdAgentsReportWellsFargo = @idReportGereted
			WHERE idAgentApplication IN (SELECT idAgent FROM AgentsReportWellsFargoDetail WHERE IdAgentsReportWellsFargo = @idReportGereted AND isAgent = 0);
			
			DECLARE @idStatusHistory int
			SET @idStatusHistory = (Select Top 1  IdAgentStatus FROM AgentStatus WITH(NOLOCK) WHERE AgentStatus = 'Wells Fargo Sub Account Report Generated')

			INSERT INTO AgentStatusHistory (IdUser,IdAgent,IdAgentStatus,DateOfchange,Note) 
				SELECT @EnteredByIdUser,idAgent,@idStatusHistory, GETDATE(), 'Wells Fargo Sub Account Report Generated'
				FROM AgentsReportWellsFargoDetail 
				WHERE IdAgentsReportWellsFargo = @idReportGereted AND isAgent = 1

			SET @idStatusHistory = (Select TOP 1 IdAgentApplicationStatus FROM AgentApplicationStatuses where StatusCodeName = 'WellsFargoSubAccountReportGenerated')
			

			Insert into AgentApplicationStatusHistory (IdAgentApplication,IdAgentApplicationStatus, DateOfMovement,Note, DateOfLastChange,IdUserLastChange, IdType)
				SELECT idAgent,@idStatusHistory, GETDATE(), 'Wells Fargo Sub Account Report Generated', GETDATE(), @EnteredByIdUser, NULL
				FROM AgentsReportWellsFargoDetail 
				WHERE IdAgentsReportWellsFargo = @idReportGereted AND isAgent = 0
		END

	END TRY
	BEGIN CATCH
		SET @HasError = 1;
		DECLARE @ErrorMessage nvarchar(max)                                                                                             
		SELECT @ErrorMessage=ERROR_MESSAGE()                                             
		INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) VALUES ('st_WellsFargoSubAccount_CreateReport',GETDATE(),@ErrorMessage)                                                                                            		
	END CATCH
END