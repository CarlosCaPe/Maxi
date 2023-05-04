CREATE procedure [dbo].[st_UpdateStatusForCompliance]          
 (          
 @EnterByIdUser int,          
 @IsSpanishLanguage bit,          
 @XMLTransfer int,          
 @Note nvarchar(max), 
 @NewIdStatus int, 
 @HasError bit out,
 @Message varchar(max) out          
 )          
as
Set nocount on

Create Table #Temp
(
Id int identity(1,1),
Transfer Int,
Mensaje nvarchar(max)
)
   
Declare @DocHandle int    
EXEC sp_xml_preparedocument @DocHandle OUTPUT, @XMLTransfer     
Insert into #Temp (Transfer)
SELECT Transfer  FROM OPENXML (@DocHandle, 'Main/ValidTransfer',2)  WITH (Transfer int)           
EXEC sp_xml_removedocument @DocHandle    


Declare @Counter int
Set @Counter=1

While exists (Select 1 from #Temp where ID<=@Counter)
Begin
	Select * from #Temp where ID=@Counter
	Set @Counter=@Counter+1
End
