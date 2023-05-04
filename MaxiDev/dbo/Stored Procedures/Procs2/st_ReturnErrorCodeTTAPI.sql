CREATE PROCEDURE [dbo].[st_ReturnErrorCodeTTAPI]
(
	@XML XML
	,@ReturnCode VARCHAR(25) OUTPUT
	,@ReturnMsg VARCHAR(MAX) OUTPUT
	,@IsError BIT OUTPUT
)
/********************************************************************
<Author></Author>
<app></app>
<Description>Get Error Code inside the Message</Description>
<SampleCall></SampleCall>
<ChangeLog>
<log Date="05/10/2018" Author="snevarez">Get Error Code inside the Message(status_message)</log>
</ChangeLog>
*********************************************************************/
AS
Set Nocount on

Begin try
    
    SET @ReturnCode = NULL;    
    SET @ReturnMsg = NULL;
    SET @IsError = 0;    

    -- Add the T-SQL statements to compute the return value here
    DECLARE @JSON VARCHAR(MAX);

    SET @JSON = @XML.value('(/Message/node())[1]', 'nvarchar(max)');

    DECLARE @TableJson TABLE
    (
	   element_id INT NOT NULL,		    /* internal surrogate primary key gives the order of parsing and the list order */
	   sequenceNo [int] NULL,		    /* the place in the sequence for the element */
	   parent_ID INT,				    /* if the element has a parent then it is in this column. The document is the ultimate parent, so you can get the structure from recursing from the document */
	   Object_ID INT,				    /* each list or object has an object id. This ties all elements to a parent. Lists are treated as objects here */
	   NAME NVARCHAR(2000),			    /* the name of the object */
	   StringValue NVARCHAR(MAX) NOT NULL, /*the string representation of the value of the element. */
	   ValueType VARCHAR(10) NOT null	    /* the declared type of the value represented as a string in StringValue*/
    )

    Insert Into @TableJson (element_id, sequenceNo, parent_ID, Object_ID, NAME, StringValue, ValueType)
	   Select 
		  element_id
		  , sequenceNo
		  , parent_ID
		  , Object_ID
		  , NAME
		  , StringValue
		  , ValueType
	   From dbo.fnParseJSON(@JSON);

    IF EXISTS(SELECT 1 FROM @TableJson WHERE NAME = 'errors')
    BEGIN
	   SET @ReturnCode = (SELECT TOP 1 StringValue FROM @TableJson WHERE NAME = 'code');
	   SET @IsError = 1;
	   SET @ReturnMsg =  @JSON;	   
    END
    ELSE
    BEGIN
	   SET @IsError = 0;
	   SET @ReturnMsg = 'Return code UNKNOWN:' + @JSON;
	   Insert into InfoLogForStoreProcedure (StoreProcedure,InfoDate,InfoMessage)Values('st_ReturnErrorCodeTTAPI',Getdate(), @ReturnMsg );	   
    END

End Try
Begin Catch

	Declare 
	   @ErrorLine nvarchar(50),
	   @ErrorMessage nvarchar(max);
	
	Select 
	   @ErrorLine = CONVERT(varchar(50), ERROR_LINE()), 
	   @ErrorMessage = ERROR_MESSAGE();
	
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ReturnErrorCodeTTAPI',Getdate(),'ErrorLine:'+@ErrorLine+',ErrorMessage:'+@ErrorMessage);

End Catch