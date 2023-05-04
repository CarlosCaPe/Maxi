CREATE procedure [dbo].[st_RegisterPcIdentifier]
(
       @MachineDescription nvarchar(MAX),
       @Identifier nvarchar(MAX),
       @IdAgent int,

       @HasError bit out,
       @MessageOut nvarchar(max) out,
       @IdPcIdentifier int out
)
as
begin try

       Declare @xml xml
       set @xml = @MachineDescription

       Declare @DocHandle INT 
    EXEC sp_xml_preparedocument @DocHandle OUTPUT, @xml

       Declare @SN varchar(MAX)
       set @SN = (SELECT SerialNumber From OPENXML (@DocHandle, '/PcInformation/Bios',2) WITH (SerialNumber varchar(MAX)))

       Declare @MN varchar(MAX)
       set @MN = (SELECT MachineName From OPENXML (@DocHandle, '/PcInformation/Enviroment',2)   WITH (MachineName varchar(MAX)))

       Declare @exist int 
       set @exist = (select IdPcIdentifier from PcIdentifier where SerialNumber = @SN and  MachineName = @MN and  Identifier = @Identifier)

       if(@exist > 0)
              Begin
                     set @IdPcIdentifier = @exist
                     if(@IdAgent > 0 and not exists(select IdAgent from AgentPc where IdPcIdentifier = @exist and IdAgent = @IdAgent))
                           insert into AgentPc(IdPcIdentifier,IdAgent) values (@IdPcIdentifier, @IdAgent)
              End
       else
              begin 
                     insert into PcIdentifier(MachineDescription, Identifier, SerialNumber, MachineName) values (@MachineDescription, @Identifier, @SN, @MN)
                     set @IdPcIdentifier = SCOPE_IDENTITY()

                     if(@IdAgent > 0)     
                           insert into AgentPc(IdPcIdentifier,IdAgent) values (@IdPcIdentifier, @IdAgent)
              end


	-- Comparar So y guardar el nuevo
	
	Declare @SO varchar(MAX)
  Declare @xmlInfoMachin xml
	Declare @SOold varchar(MAX)
	
  set @SO = (SELECT OSVersionName From OPENXML (@DocHandle, '/PcInformation/Enviroment',2) WITH (OSVersionName varchar(MAX)))
    
   
	set @xmlInfoMachin = (select MachineDescription from PcIdentifier  where  SerialNumber = @SN and  MachineName = @MN and  Identifier = @Identifier)

	Declare @DocHandleInfoMachin INT 
    EXEC sp_xml_preparedocument @DocHandleInfoMachin OUTPUT, @xmlInfoMachin
    

  set @SOold = (SELECT OSVersionName From OPENXML (@DocHandleInfoMachin, '/PcInformation/Enviroment',2) WITH (OSVersionName varchar(MAX)))
 
  --- Comparar So y guardar el nuevo  
   
		
		--Guardar Nuevo Registro		
	 	if @SO <> @SOold
 		 begin   		 	
 		   	update PcIdentifier
 		   	set MachineDescription = @MachineDescription
 		   	 where SerialNumber = @SN and  MachineName = @MN and  Identifier = @Identifier
			set @IdPcIdentifier = SCOPE_IDENTITY()
 		 end	
		
		

       set @HasError = 0
       set @MessageOut = 'UserRecordTheNewPcSuccessfully'

end try
begin catch

       set @IdPcIdentifier = SCOPE_IDENTITY()
       set @HasError = 1
       set @MessageOut = 'UserRecordTheNewPcError'

    Declare @ErrorMessage nvarchar(max)
    Select  @ErrorMessage=ERROR_MESSAGE()
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_RegisterPcIdentifier',Getdate(),@ErrorMessage)

end catch