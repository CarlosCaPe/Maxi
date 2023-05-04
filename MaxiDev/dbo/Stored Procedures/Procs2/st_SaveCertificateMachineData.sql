/********************************************************************
<Author> azavala </Author>
<app>Maxi Agents</app>
<Description> Guarda informacion de agencia y equipo </Description>

<ChangeLog>
<log Date="03/07/2018" Author="azavala">Creacion</log>
<log Date="30/07/2018" Author="azavala">Cambio de logica al guardar</log>
</ChangeLog>
*********************************************************************/
CREATE PROCEDURE [dbo].[st_SaveCertificateMachineData]
	@IdAgent int,
	@IdUser int,
	@AgentVersion varchar(max),
	@MacAddress varchar(max),
	@SerialMotherBoard varchar(max),
	@WithCertificate bit,
	@HasError bit output
AS
BEGIN try
	if not exists(select 1 from dbo.CertificateMachineData where IdAgent=@IdAgent and MacAddress=@MacAddress AND SerialMotherBoard=@SerialMotherBoard)
		begin
			if(@WithCertificate=1)
				begin
					select 'Insert withCert=1'
					insert into dbo.CertificateMachineData (IdAgent, IdUser, AgentVersion, MacAddress,SerialMotherBoard,WithCertificate,DateDetectedCertificate,DateLoggedData) values (@IdAgent,@IdUser,@AgentVersion,@MacAddress,@SerialMotherBoard,@WithCertificate, GETDATE(),GETDATE())
				end
			else
				begin
					select 'Insert withCert=0'
					insert into dbo.CertificateMachineData (IdAgent, IdUser, AgentVersion, MacAddress,SerialMotherBoard,WithCertificate,DateLoggedData) values (@IdAgent,@IdUser,@AgentVersion,@MacAddress,@SerialMotherBoard,@WithCertificate,GetDate())
				end
		end
	else
		begin
			declare @WithCertificateMirror bit
			set @WithCertificateMirror = (select WithCertificate from dbo.CertificateMachineData where IdAgent=@IdAgent and MacAddress=@MacAddress AND SerialMotherBoard=@SerialMotherBoard)
			IF(@WithCertificateMirror=0 AND @WithCertificate=1)
				begin
					select 'Update withCert=1 and withCertMirror=0'
					update dbo.CertificateMachineData set WithCertificate=@WithCertificate, AgentVersion=@AgentVersion, DateLoggedData=GetDate(), DateDetectedCertificate=GetDate() where MacAddress=@MacAddress and SerialMotherBoard=@SerialMotherBoard
				end
			else
				begin
					select @WithCertificate as WithCert, @WithCertificateMirror as WithCertMirror
					update dbo.CertificateMachineData set WithCertificate=@WithCertificate, AgentVersion=@AgentVersion, DateLoggedData=GetDate() where MacAddress=@MacAddress and SerialMotherBoard=@SerialMotherBoard
				end
		end
		select * from dbo.CertificateMachineData where IdAgent=@IdAgent and SerialMotherBoard=@SerialMotherBoard and MacAddress=@MacAddress
END TRY
BEGIN CATCH
	sELECT 'Error: ' + ERROR_MESSAGE()
END CATCH