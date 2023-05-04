CREATE procedure [Corp].[st_SaveNews]  
    @IdNews int ,  
    @BeginDate datetime,  
    @EndDate datetime,  
    @Title nvarchar(50),  
    @News nvarchar(max),  
    @NewsSpanish nvarchar(max)=null,
    @IdGenericStatus int,  
    @EnterByIdUser int,  
    --@IsSpanishLanguage bit,  
    @IdLenguage int,
    @HasError bit out,  
    @ResultMessage nvarchar(max) out  
as  

/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="2021/02/05" Author="jgomez"> CR - M0003 problema con saltos de linea</log>
</ChangeLog>
********************************************************************/  
  
declare @IdGenericStatusEnable int  
set @IdGenericStatusEnable = 1 --Enable  

if @IdLenguage is null 
    set @IdLenguage=2  

SET @News = REPLACE(@News, '<p><br></p>', '<p style="margin: 0px; padding: 0px;">&nbsp;</p>')  -- Start CR - M0003
SET @NewsSpanish = REPLACE(@NewsSpanish, '<p><br></p>', '<p style="margin: 0px; padding: 0px;">&nbsp;</p>') 
SET @News = REPLACE(@News, '<p>', '<p style="margin: 0px; padding: 0px;">')  
SET @NewsSpanish = REPLACE(@NewsSpanish, '<p>', '<p style="margin: 0px;">')  -- End CR - M0003
  
Begin try  
  if @IdNews<>0 and exists(select 1 from dbo.News with(nolock)
           where IdNews =@IdNews )  
   Begin   
    UPDATE [dbo].[News]  
       SET [BeginDate] = @BeginDate  
       ,[EndDate] = @EndDate  
       ,[Title] = @Title  
       ,[News] = @News
       ,[NewsSpanish] = isnull(@NewsSpanish,'')
       ,[IdGenericStatus] = @IdGenericStatus              
      WHERE IdNews =@IdNews  
         
   End  
  Else  
   Begin  
    INSERT INTO [dbo].[News]  
        ([DateInsert]  
        ,[BeginDate]  
        ,[EndDate]  
        ,[Title]  
        ,[News]
        ,[NewsSpanish]  
        ,[EnterByIdUser]  
        ,[IdGenericStatus])  
     VALUES  
        (GETDATE()  
        ,@BeginDate  
        ,@EndDate  
        ,@Title  
        ,@News  
        ,isnull(@NewsSpanish,'')
        ,@EnterByIdUser  
        ,@IdGenericStatus)  
  
     set @IdNews =SCOPE_IDENTITY()     
       
   End  
  
  set @HasError =0  
  --set @ResultMessage = dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,48)  
  SELECT @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE48')
End try  
Begin Catch  
   Declare @ErrorMessage nvarchar(max)           
   Select @ErrorMessage=ERROR_MESSAGE()          
   Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[[st_SaveNews]]',Getdate(),@ErrorMessage)   
  set @HasError =1  
  --set @ResultMessage = dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,49)  
  SELECT @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE49')
End catch  
  
return;