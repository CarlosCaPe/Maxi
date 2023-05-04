CREATE procedure [dbo].[st_ResponseReturnCodeArias]                
(                  
@IdGateway  int,                  
@Claimcode  nvarchar(max),                  
@ReturnCode nvarchar(max),                  
@ReturnCodeType int,             
@XmlValue xml,            
@IsCorrect bit Output            
)             
AS
/********************************************************************
<Author></Author>
<app>  </app>
<Description></Description>
<SampleCall></SampleCall>
<ChangeLog>
<log Date="10/12/2018" Author="adominguez">Se agrega "with(nolock)" a las consultas</log>
<log Date="12/12/2018" Author="jmolina">Se agrega "cast a mimsmo tamaño de variable y campo de tabla" a las consultas #1</log>
</ChangeLog>
*********************************************************************/
Set nocount on            
Declare @Description nvarchar(max)              
Declare @IdStatusAction int              
Declare @IdTransfer int    

declare @ReturnCodeCast nvarchar(16)
declare @ClaimcodeCast nvarchar(50)

set @ReturnCodeCast = convert(nvarchar(16), @ReturnCode)
set @ClaimcodeCast = convert(nvarchar(50), @Claimcode)
    
    
   If @ReturnCodeType=1 and @ReturnCode='0'    
   Begin    
    Declare @DocHandle int    
    Declare @RemittanceID int      
    EXEC sp_xml_preparedocument @DocHandle OUTPUT, @XmlValue       
    Select @RemittanceID=RemittanceID From OPENXML (@DocHandle, '/Arias/Detail',2)      
    WITH (      
    RemittanceId int      
    )       
    Exec sp_xml_removedocument @DocHandle      
    Insert into AriasClaimCodeRemittanceID (ClaimCode,RemittanceID) values (@Claimcode,@RemittanceID)    
  End    
  Else    
  Begin    
   Select @Claimcode=Claimcode from AriasClaimCodeRemittanceID where RemittanceID=@Claimcode    
  End    
      
    
              
Select @IdStatusAction=IdStatusAction,@Description=[Description] from GatewayReturnCode with(nolock)               
where IdGateway=@IdGateway And IdGatewayReturnCodeType=3 And ReturnCode=@ReturnCodeCast
--where IdGateway=@IdGateway And IdGatewayReturnCodeType=3 And ReturnCode=@ReturnCode --#1

              
Insert into  [MAXILOG].[dbo].AriasResponseLog values (getdate(),@Claimcode,@ReturnCode,@ReturnCodeType,@IdStatusAction,@Description,@XmlValue)            
              
If @IdStatusAction>0              
Begin              
 --Select @IdTransfer=IdTransfer From [Transfer] with(nolock) where ClaimCode=@Claimcode         
 Select @IdTransfer=IdTransfer From [Transfer] with(nolock) where ClaimCode=@ClaimcodeCast
 if @IdTransfer is not null        
 begin             
  Update [Transfer] set IdStatus=@IdStatusAction,DateStatusChange=GETDATE() where IdTransfer=@IdTransfer              
  Exec st_SaveChangesToTransferLog @IdTransfer,@IdStatusAction,@Description,0              
 end        
End            
            
Set @IsCorrect=1
