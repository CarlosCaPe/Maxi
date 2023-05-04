CREATE PROCEDURE [dbo].[st_fax_Sent]
	@IdAgent int,
	@IdAgentSchema int,
	@HasFax bit output
AS
BEGIN

SET NOCOUNT ON;

declare @ReportName varchar(50) = 'ReportExchangeRate';

SET @HasFax = 0;


IF (@idAgent IS NOT NULL)
	BEGIN 
		
		Declare @fecha DateTime = Convert(DATE,getDate());
 
		 IF EXISTS (select top 1 1 from QueueFaxes WITH (NOLOCK,index(ix_QueueFaxes_IdAgent_ReportName_DateInsert)) where IdAgent=@idAgent AND ReportName = @ReportName and DateInsert >= @fecha) 
		 BEGIN 
		 
		 set @HasFax=1;	
		 /*
				DECLARE @TMP_XML TABLE ( IdAgentSchema INT );

				INSERT INTO @TMP_XML
					select Distinct
						  ISNULL(Parameters.value('(/Parameters/Parameter/@value)[3]', 'int'),0) AS Value
					from QueueFaxes WITH (NOLOCK) 
					where 
						IdAgent = @idAgent
						and ReportName =@ReportName
						and	DateInsert >= @fecha;

				IF EXISTS(select 1 from @TMP_XML WHERE IdAgentSchema = @IdAgentSchema)
				BEGIN
					set @HasFax=1;		

					DECLARE @ExpirationDate DateTime;
					SET @ExpirationDate = (SELECT MAX(EndDateTempSpread) FROM [dbo].[AgentSchemaDetail] WITH(NOLOCK) WHERE IdAgentSchema=@IdAgentSchema)
					IF(@ExpirationDate<=GETDATE())
					BEGIN
						set @HasFax=0;
					END
				END
		 */
		 
		 END 
	END


END
