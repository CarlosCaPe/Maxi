CREATE PROCEDURE [Corp].[st_InsertFaxToQueueFaxes]
(
    @Parameters XML,
    @ReportName varchar(50),
    @Priority int,
    @IdAgent int,
    @IdLenguage int,
    @EnterByIdUser int,
    @HasError bit out,
    @ResultMessage nvarchar(max) out
)
as

/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="24/01/2018" Author="jmolina">Add with(nolock) And Schema</log>
<log Date="11/10/2019" Author="bortega">Receipt to Fax California Id#M00077</log>
</ChangeLog>
********************************************************************/

if @IdLenguage is null 
    set @IdLenguage=2

Begin try

if @ReportName='AgentBalance'
begin

    DECLARE @DocHandle INT 
    EXEC sp_xml_preparedocument @DocHandle OUTPUT,@Parameters   


    SELECT name,value into #TMPData
    FROM OPENXML (@DocHandle, '/Parameters/Parameter',2)
    With (
		    name nvarchar(max) '@name',
            value nvarchar(max) '@value'
	    )

    EXEC sp_xml_removedocument @DocHandle 

    declare @IdAgentFax int
    declare @DateFrom date
    declare @DateTo date

    select @IdAgentFax=value from #TMPData where name='IdAgent'

    begin try
        select @DateFrom=convert(datetime,value,110) from #TMPData where name='DateFrom'
        select @DateTo=convert(datetime,value,110) from #TMPData where name='DateTo'
    end try
    begin catch
        select @DateFrom=convert(datetime,value,103) from #TMPData where name='DateFrom'
        select @DateTo=convert(datetime,value,103) from #TMPData where name='DateTo'
    end catch

    --DECLARE @Parameters XML

      SELECT @Parameters=
            (
                SELECT
                (
                SELECT
                @IdAgentFax AS [Parameter/@IdAgent],
                convert(varchar(10),@DateFrom,110) AS [Parameter/@DateFrom],
                convert(varchar(10),@DateTo,110) AS [Parameter/@DateTo],
                [dbo].[GetGlobalAttributeByName]('QRHandler')+'?id='+[dbo].[GetGlobalAttributeByName]('QRAgentPrefix')+convert(varchar,@IdAgentFax) [Parameter/@QR_Base64_Image]
                FOR XML PATH('Parameters'),TYPE
                ).query('
                for $Parameters in /Parameters
                return
                <Parameters>        
                <Parameter name="IdAgent" value="{data($Parameters/Parameter/@IdAgent)}"></Parameter>
                <Parameter name="DateFrom" value="{data($Parameters/Parameter/@DateFrom)}"></Parameter>
                <Parameter name="DateTo" value="{data($Parameters/Parameter/@DateTo)}"></Parameter>
                <Parameter name="QR_Base64_Image" value="{data($Parameters/Parameter/@QR_Base64_Image)}"></Parameter>                
                </Parameters>
                ')   
            )   
end

     if exists(select 1 from [dbo].Agent WITH(nolock) where IdAgent=@idAgent and agentstate='CA') and @ReportName='TransactionReceipts' 
     begin
     	--set @ReportName = 'TransactionReceiptsCA'
		set @ReportName = 'TransactionReceiptsFAXCA' --#M00077
     end 

INSERT INTO [dbo].[QueueFaxes]
           (IdAgent
		   ,[Parameters]
           ,[ReportName]
           ,[Priority]
           ,IdQueueFaxStatus
           ,EnterByIdUser
           )
     VALUES
           (@IdAgent
           ,@Parameters
           ,@ReportName
           ,@Priority
           ,1
           ,@EnterByIdUser
           )
		set @HasError =0
        SELECT @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE46')
End try
Begin Catch
		 Declare @ErrorMessage nvarchar(max)         
		 Select @ErrorMessage=ERROR_MESSAGE()        
		 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_InsertFaxToQueueFaxes]',Getdate(),@ErrorMessage) 
         set @HasError =1
         SELECT @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE47')		
End catch
