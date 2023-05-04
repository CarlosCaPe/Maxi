CREATE PROCEDURE [Corp].[st_GetAgentApplicationsV2]
(
    @IdUserSeller int = null,
    @StatusesPreselected XML
)
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

Begin try

    Declare @tStatus table    
		(    
		 id int    
		)
    
    Declare @DocHandle int    
    Declare @hasStatus bit    

    EXEC sp_xml_preparedocument @DocHandle OUTPUT, @StatusesPreselected      
    
    insert into @tStatus(id)     
    select id    
    FROM OPENXML (@DocHandle, '/statuses/status',1)     
    WITH (id int)   

    EXEC sp_xml_removedocument @DocHandle   

    select 
	   ap.IdAgentApplication Id
	   , ap.AgentCode
	   , ap.AgentName
	   , ap.IdAgentApplicationStatus IdStatus
	   , ap.DateOfCreation
	   , ap.DateOfLastChange
	   , isnull(ua.HasNewImg, 0) HasNewImg
    from agentapplications ap with(nolock)
	   left join UploadAgentApp ua with(nolock) on ap.IdAgentApplication = ua.IdAgentApp
    where 
	   DateOfCreation >= DATEADD(day, -7, GETDATE()) 
	   and IdUserSeller = isnull(@IdUserSeller, IdUserSeller) 
	   and IdAgentApplicationStatus in (select id from @tStatus)
    order by DateOfLastChange desc

    select 
	   ap.IdAgentApplication Id
	   , ap.AgentCode
	   , ap.AgentName
	   , ap.IdAgentApplicationStatus IdStatus
	   , ap.DateOfCreation
	   , ap.DateOfLastChange, isnull(ua.HasNewImg, 0) HasNewImg
    from agentapplications ap with(nolock)
	   left join UploadAgentApp ua with(nolock) on ap.IdAgentApplication = ua.IdAgentApp
    where DateOfCreation >= DATEADD(day, -14, GETDATE())
	   and DateOfCreation < DATEADD(day, -7, GETDATE())
	   and IdUserSeller=isnull(@IdUserSeller,IdUserSeller)
	   and IdAgentApplicationStatus in (select id from @tStatus)
    order by DateOfLastChange desc

    select 
	   ap.IdAgentApplication Id
	   , ap.AgentCode
	   , ap.AgentName
	   , ap.IdAgentApplicationStatus IdStatus
	   , ap.DateOfCreation
	   , ap.DateOfLastChange
	   , isnull(ua.HasNewImg, 0) HasNewImg
    from agentapplications ap with(nolock)
	   left join UploadAgentApp ua with(nolock) on ap.IdAgentApplication = ua.IdAgentApp
    where DateOfCreation < DATEADD(day, -14, GETDATE()) 
	   and IdUserSeller=isnull(@IdUserSeller,IdUserSeller)
	   and IdAgentApplicationStatus in (select id from @tStatus)
    order by DateOfLastChange desc


End Try
Begin Catch

	   Declare @ErrorLine nvarchar(max) = CONVERT(varchar(12) ,ERROR_LINE());

	   Declare @ErrorMessage nvarchar(max);
	   Select @ErrorMessage=ERROR_MESSAGE();

	   Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
		  Values('st_GetAgentApplicationsV2'
			    ,Getdate()
			    ,'Error line:' + @ErrorLine + ':' + @ErrorMessage +  ': IdUserSeller:' + CAST(ISNULL(@IdUserSeller,'') AS nvarchar(25)) 
													    + ', StatusesPreselected:' + CAST(ISNULL(@StatusesPreselected,'') AS nvarchar(25)));

End Catch
