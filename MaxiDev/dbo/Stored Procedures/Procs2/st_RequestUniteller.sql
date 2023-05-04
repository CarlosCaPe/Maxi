CREATE procedure [dbo].[st_RequestUniteller]
(                                        
    @Claimcode varchar(30),
	@RequestType varchar(30),
    @Request varchar(max)
)                                   
AS

/********************************************************************
<Author></Author>
<app>  </app>
<Description></Description>
<SampleCall></SampleCall>
<ChangeLog>
<log Date="2/03/2023" Author="adominguez">Sp que almacena los Request hacia uniteller</log>
</ChangeLog>
*********************************************************************/

Set nocount on

BEGIN TRY


	Insert into UnitellerRequestLog values (getdate(),@Claimcode,@RequestType,@Request)

	END TRY
BEGIN CATCH
    DECLARE @ErrorMessage nvarchar(max)
    Select  @ErrorMessage = ERROR_MESSAGE()
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_RequestUniteller: ' + ', ErrorLine: ' + CONVERT(VARCHAR,ERROR_LINE()),Getdate(),@ErrorMessage)
END CATCH