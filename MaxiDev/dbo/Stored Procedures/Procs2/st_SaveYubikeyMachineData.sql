/********************************************************************
<Author> Alexis Zavala </Author>
<app> Agents </app>
<Description>Inserta o actualiza informacion de los equipos en relacion a MacAddress de Ethernet y Wi-Fi</Description>

<ChangeLog>
<log Date="10/08/2018" Author="azavala">Creacion</log>
</ChangeLog>

*********************************************************************/
CREATE PROCEDURE [dbo].[st_SaveYubikeyMachineData] 
	@IdAgent int,
	@Ethernet varchar(max),
	@WiFi varchar(max),
	@AgentVersion varchar(max)
AS
BEGIN try
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if not exists (select 1 from YubikeyMachineData with(nolock) where IdAgent=@IdAgent and Ethernet=@Ethernet and WiFi=@WiFi)
		begin
			insert into YubikeyMachineData (IdAgent,Ethernet,WiFi,AgentVersion) values (@IdAgent,@Ethernet,@WiFi,@AgentVersion)
		end
	else
		begin
			update YubikeyMachineData set AgentVersion=@AgentVersion where IdAgent=@IdAgent and Ethernet=@Ethernet and WiFi=@WiFi
		end
END try
BEGIN CATCH
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveYubikeyMachineDatar',Getdate(),ERROR_MESSAGE())
END CATCH
