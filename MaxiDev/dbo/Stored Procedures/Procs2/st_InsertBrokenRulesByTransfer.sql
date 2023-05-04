CREATE Procedure [dbo].[st_InsertBrokenRulesByTransfer]      
(      
    @IdTransfer int,      
    @XmlRules XML,  
    @OWBRuleType int,      
    @HasError bit out      
)      
AS
/********************************************************************
<Author>Not Known</Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="2018-12-17" Author="jmolina"> Se agrego ; por cada insert y/o update</log>
</ChangeLog>
********************************************************************/      
Begin Try      
 
 Declare @DocHandle int      
 EXEC sp_xml_preparedocument @DocHandle OUTPUT, @XmlRules       
      
 Insert into BrokenRulesByTransfer (IdTransfer,IdKYCAction,IsDenyList,MessageInSpanish,MessageInEnglish,IdRule,RuleName,SSNRequired,IsBlackList, ComplianceFormatId)      
 SELECT @IdTransfer as IdTransfer
		,IdKYCAction
		,IsDenyList
		,MessageInSpanish
		,MessageInEnglish
		,IdRule,RuleName
		,SSNRequired
		,IsBlackList
		,(CASE ComplianceFormatId WHEN 0 THEN NULL ELSE ComplianceFormatId END) ComplianceFormatId
	FROM OPENXML (@DocHandle, '/BrokenRules/Rule',2)
 WITH (IdKYCAction int,      
 IsDenyList bit,      
 MessageInSpanish nvarchar(max),      
 MessageInEnglish nvarchar(max),
 IdRule int,
 RuleName nvarchar(3000),
 SSNRequired bit,
 IsBlackList bit,
 ComplianceFormatId INT
 );
   
   
if @OWBRuleType>1  
Begin  
     Insert into TransferRequestedOWB (IdTransfer,IdMoneyBelongToCustomer) values (@IdTransfer,@OWBRuleType);  
  
     If @OWBRuleType=2  
     Begin  
      Declare @OWBMessageInSpanish varchar(max),@OWBMessageInEnglish varchar(max)  
      Select @OWBMessageInSpanish=dbo.GetMessageFromLenguajeResorces(1,62),@OWBMessageInEnglish=dbo.GetMessageFromLenguajeResorces(0,62)  
      Insert into BrokenRulesByTransfer  
      (  
        IdTransfer,  
        IdKYCAction,  
        IsDenyList,  
        MessageInEnglish,  
        MessageInSpanish  
      )  
      SELECT top 1  @IdTransfer as IdTransfer,IdKYCAction,IsDenyList,@OWBMessageInEnglish,@OWBMessageInSpanish FROM OPENXML (@DocHandle, '/BrokenRules/Rule',2)      
      WITH (IdKYCAction int,      
      IsDenyList bit,      
      MessageInSpanish nvarchar(max),      
      MessageInEnglish nvarchar(max)      
      )  
      Where IdKYCAction=2;  
     End  
End  
      
EXEC sp_xml_removedocument @DocHandle      
Set @HasError=0      

End Try      
Begin Catch      
 Set @HasError=1       
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_InsertBrokenRulesByTransfer',Getdate(),@ErrorMessage)
End Catch
