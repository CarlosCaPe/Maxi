CREATE procedure [dbo].[IsValidIdStatusValidator]
(@FromIdStatus int,
 @XmlValue Xml,
 @IsValid int output
 )  
AS  
Set nocount on 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

Declare @DocHandle int  
EXEC sp_xml_preparedocument @DocHandle OUTPUT, @XmlValue   
       
    
     If Exists (Select 1 from ValidTransferStatusTransition WITH(NOLOCK) where FromIdStatus=@FromIdStatus and ToIdStatus in (SELECT [Status] FROM OPENXML (@DocHandle, 'Main/ValidStatus',2)  WITH ([Status] int)   ))  
        Set @IsValid=1  
     Else  
        Set @IsValid=0  
          
  EXEC sp_xml_removedocument @DocHandle



