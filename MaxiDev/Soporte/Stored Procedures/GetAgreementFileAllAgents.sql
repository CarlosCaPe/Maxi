/********************************************************************
<Author> azavala </Author>
<app>Maxi API</app>
<Description> Obtiene el contrato de cada agencia </Description>

<ChangeLog>
<log Date="" Author="azavala">Creacion</log>
<log Date="" Author="azavala">Agregar filtro Status de agencia</log>
</ChangeLog>
*********************************************************************/
CREATE PROCEDURE [Soporte].[GetAgreementFileAllAgents]
	@UploadPath varchar(max) output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	select
		a.IdAgent,
		a.AgentCode, 
		(u.FileGuid+'.pdf') as FileGuid
	from 
		Agent a with(nolock) inner join UploadFiles u with(nolock) on a.IdAgent=u.IdReference 
	where 
		u.IdDocumentType=11 and a.IdAgentStatus not in(2,6) order by LastChange_LastDateChange

	set @UploadPath = (select Value from GlobalAttributes where Name='UploadPath')
END
