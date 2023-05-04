CREATE Procedure [dbo].[st_AssignPayerFXGrouping]
(
    @IdUser INT,
    @PayerGrouping XML,
    @HasError BIT OUT,
    @Message varchar(max) OUT
)
AS
/********************************************************************
<Author> ??? </Author>
<app> Corporative </app>
<Description>Assignment of Payers to Groups</Description>

<ChangeLog>
<log Date="16/10/2017" Author="snevarez">Assignment of Payers to Groups</log>
</ChangeLog>
*********************************************************************/
BEGIN TRY
    Set @HasError = 0;

    IF ( ISNULL(@IdUser,0) = 0 )
    BEGIN
	   SET @HasError = 1;
	   SET @Message = 'User required for this process';
	   RAISERROR(@Message, 16, 1);
    END

    /*Read XML - Begin*/
    /*----------------*/
    --<Root>
	   --<Group Name = "GrupoGiro">
		  --<Payers>
    --			 <Payer Id="1">
				--<PayerConfig Id="1"/>
				--<PayerConfig Id="2"/>
			 --</Payer>
    --			 <Payer Id="2">
				--<PayerConfig Id="5"/>
			 --</Payer>
    --			 <Payer Id="3">
				--<PayerConfig Id="3"/>
			 --</Payer>
		  --</Payers>
	   --</Group>
    --</Root>
    --SET @Message = 'Read XML';
    DECLARE @XMLTable TABLE 
    (
	   IdXml INT IDENTITY
	   , PayerGroup VARCHAR(150)
	   , IdPayer INT DEFAULT(0)
	   , IdPayerConfig INT DEFAULT(0)
    );

    DECLARE @DocHandle INT;
    EXEC sp_xml_preparedocument @DocHandle OUTPUT, @PayerGrouping;
		
    INSERT INTO @XMLTable (PayerGroup,IdPayer,IdPayerConfig)
	    SELECT 
		  PayerGroup
		  ,IdPayer
		  ,IdPayerConfig
	   FROM OPENXML (@DocHandle, 'Root/Group/Payers/Payer/PayerConfig')    
	   WITH
	   ( 
		  PayerGroup VARCHAR(150) '../../../@Name',
		  IdPayer INT '../@Id',
		  IdPayerConfig INT '@Id'
	   );

    EXEC sp_xml_removedocument @DocHandle;

    /*Read XML - End*/


    /*Validation of Group Name - Begin*/
    /*--------------------------------*/
    Declare @PayerGroup Varchar(150);
    Declare @IdPayerGroup Int;
    Declare @Action Varchar(20) = '';
    IF EXISTS(SELECT TOP 1 1 FROM @XMLTable)
    BEGIN
	   SET @PayerGroup = (SELECT TOP 1 PayerGroup FROM @XMLTable);

	   SET @IdPayerGroup = (Select TOp 1 IdPayerGroup From PayerGroup WITH (NOLOCK) Where PayerGroup = @PayerGroup);
	   IF ( ISNULL(@IdPayerGroup,0) = 0)
	   BEGIN
		  Set @Action = 'New';
		  SET @Message = @PayerGroup + ':Successfully created group';
		  INSERT INTO [dbo].[PayerGroup] ([PayerGroup],[DateOfCreate],[IdUserCreate],[Active])
			 VALUES (@PayerGroup,GETDATE(),@IdUser,1);

		  SET @IdPayerGroup = SCOPE_IDENTITY();
	   END
	   ELSE
	   BEGIN
		  Set @Action = 'Update';
		  SET @Message = @PayerGroup + ':Successfully updated group';
		  UPDATE [dbo].[PayerGroup]
		  SET
			 [DateOfLastChange] = GETDATE()
			 ,[IdUserLastChange] = @IdUser
			 ,[Active] = 1
		  WHERE IdPayerGroup = @IdPayerGroup;
	   END
    END

    /*Validation of Group Name - End*/


    /*Validation of Payer Id - Begin*/
    /*------------------------------*/    
    IF (EXISTS(Select Top 1 1 From [dbo].[PayerFXGrouping] WITH (NOLOCK) Where IdPayerGroup = @IdPayerGroup))
    BEGIN
	   Set @Action = 'Delete';
	   SET @Message = @PayerGroup + ':Successfully debugger payer list';
	   DELETE FROM [dbo].[PayerFXGrouping] WHERE IdPayerGroup = @IdPayerGroup	   
    END
    
    SET @Message = @PayerGroup + ':'+ @Action + ' & ' + 'Successfully updated payer list';
    INSERT INTO [dbo].[PayerFXGrouping] (IdPayerGroup,IdPayer,IdPayerConfig,DateOfLastChange,IdUserLastChange)
	   SELECT 
		  @IdPayerGroup AS IdPayerGroup
		  ,IdPayer
		  ,IdPayerConfig
		  ,GETDATE() AS DateOfLastChange
		  ,@IdUser AS IdUserLastChange
	   FROM @XMLTable;

    
    /*Validation of Payer Id - End*/

END TRY

BEGIN CATCH
    Set @HasError = 1;
    Declare @ErrorMessage nvarchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_AssignPayerFXGrouping',Getdate(),@ErrorMessage);
END CATCH
