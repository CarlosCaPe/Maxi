CREATE procedure [dbo].[st_SaveBeneficiary]  
    @IdBeneficiary int ,  
    @IdCustomer int,  
    @Name nvarchar(max),  
    @FirstLastName nvarchar(max),  
    @SecondLastName nvarchar(max),  
    @Address nvarchar(max),  
    @City nvarchar(max),  
    @State nvarchar(max),  
    @Country nvarchar(max),  
    @Zipcode nvarchar(max),  
    @PhoneNumber nvarchar(max),  
    @CelullarNumber nvarchar(max),  
    @EnterByIdUser int,  
    --@IsSpanishLanguage bit,  
    @IdLenguage int,
    @HasError bit out,  
    @ResultMessage nvarchar(max) out  
as  
  
declare @IdGenericStatusEnable int  
set @IdGenericStatusEnable =1 --Enable  

if @IdLenguage is null 
    set @IdLenguage=2
  
  
Begin try  
  if @IdBeneficiary<>0 and exists(select 1 from dbo.Beneficiary   
           where IdBeneficiary =@IdBeneficiary )  
   Begin   
      
    UPDATE [dbo].Beneficiary  
        SET [IdCustomer] = @IdCustomer  
        ,[IdGenericStatus] = @IdGenericStatusEnable  
        ,[Name] =@Name  
        ,[FirstLastName] = @FirstLastName  
        ,[SecondLastName] = @SecondLastName  
        ,[Address] = isnull(@Address  ,'')
        ,[City] = isnull(@City ,'')  
        ,[State] = isnull(@State ,'')  
        ,[Country] = isnull(@Country,'')   
        ,[Zipcode] = isnull(@Zipcode,'')   
        ,[PhoneNumber] = @PhoneNumber  
        ,[CelullarNumber] = @CelullarNumber          
      WHERE IdBeneficiary =@IdBeneficiary  
         
   End  
  Else  
   Begin  
    INSERT INTO [dbo].Beneficiary  
        ([IdCustomer]  
        ,[IdGenericStatus]  
        ,[Name]  
        ,[FirstLastName]  
        ,[SecondLastName]  
        ,[Address]  
        ,[City]  
        ,[State]  
        ,[Country]  
        ,[Zipcode]  
        ,[PhoneNumber]  
        ,[CelullarNumber]  
        ,[SSNumber]  
        ,[BornDate]  
        ,[Occupation]  
        ,[DateOfLastChange]  
        ,[EnterByIdUser]  
        ,Note)  
     VALUES  
        (@IdCustomer ,  
        @IdGenericStatusEnable ,  
        @Name ,  
        @FirstLastName ,  
        @SecondLastName ,  
        isnull(@Address ,''),  
        isnull(@City  ,''),
        isnull(@State,'') ,  
        isnull(@Country,'')  ,  
        isnull(@Zipcode,'')  ,  
        @PhoneNumber ,  
        @CelullarNumber ,  
        '' ,  
        null ,  
        '' ,  
        GETDATE() ,  
        @EnterByIdUser  
        ,'' )  
  
     set @IdBeneficiary =SCOPE_IDENTITY()     
       
   End  
  
  set @HasError =0  
  --set @ResultMessage = dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,12)  
  SELECT @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE12')
End try  
Begin Catch  
   Declare @ErrorMessage nvarchar(max)           
   Select @ErrorMessage=ERROR_MESSAGE()          
   Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[st_SaveBeneficiary]',Getdate(),@ErrorMessage)   
  set @HasError =1  
  --set @ResultMessage = dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,13)  
  SELECT @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE13')
End catch  
  
return;