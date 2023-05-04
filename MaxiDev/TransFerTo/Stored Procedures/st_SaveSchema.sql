CREATE procedure [TransFerTo].[st_SaveSchema]
(   
    @IdSchema [int],
    @SchemaName [nvarchar](max),
    @IdCountry [int],
    @IdCarrier [int],
    @IdProduct [int],    
    @BeginValue money,
    @EndValue money,
    @Commission money,
    @IsDefault [bit],
    @IdGenericStatus int,    
	@EnterByIdUser [int],
    @IdLenguage int,
    @IdSchemaOut [int] out,
    @HasError bit output,            
    @Message nvarchar(max) output
)
as
Set nocount on  
Begin Try 

set @HasError=0
set @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SchemaSave')     

if (@IdSchema=0)
begin
    if exists (select top 1 1 from  [TransFerTo].[Schema] where isnull(IdCountry,0)=isnull(@IdCountry,0) and isnull(IdCarrier,0)=isnull(@IdCarrier,0) and isnull(IdProduct,0)=isnull(@IdProduct,0) and isnull(BeginValue,0)=isnull(@BeginValue,0) and isnull(EndValue,0)=isnull(@EndValue,0) and IsDefault=0 and Commission=@Commission) and @IsDefault=0
    begin
        set @HasError=1
        set @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SchemaError2')     
        return
    end

    if exists (select top 1 1 from  [TransFerTo].[Schema] where isnull(IdCountry,0)=isnull(@IdCountry,0) and isnull(IdCarrier,0)=isnull(@IdCarrier,0) and isnull(IdProduct,0)=isnull(@IdProduct,0) and isnull(BeginValue,0)=isnull(@BeginValue,0) and isnull(EndValue,0)=isnull(@EndValue,0) and IsDefault=1) and @IdProduct is not null and @IsDefault=1
    begin
        set @HasError=1
        set @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SchemaError2')     
        return
    end

    if exists (select top 1 1 from  [TransFerTo].[Schema] where isnull(IdCountry,0)=isnull(@IdCountry,0) and isnull(IdCarrier,0)=isnull(@IdCarrier,0) and isnull(IdProduct,0)=isnull(@IdProduct,0) and IsDefault=1 and ((isnull(@BeginValue,0)>=BeginValue and isnull(@BeginValue,0)<=EndValue)or(isnull(@EndValue,0)>=BeginValue and isnull(@EndValue,0)<=EndValue)) and IsDefault=1) and @IdProduct is null and @IsDefault=1
    begin
        set @HasError=1
        set @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SchemaError3')     
        return
    end

    INSERT INTO [TransFerTo].[Schema]
           ([SchemaName]
           ,[IdCountry]
           ,[IdCarrier]
           ,[IdProduct]
           ,[BeginValue]
           ,[EndValue]
           ,[Commission]
           ,[IsDefault]
           ,[IdGenericStatus]
           ,[DateOfCreation]
           ,[DateOfLastChange]
           ,[EnterByIdUser])
     VALUES
     (
        @SchemaName,
        @IdCountry,
        @IdCarrier,
        @IdProduct,
        @BeginValue,
        @EndValue,
        @Commission,
        @IsDefault,
        @IdGenericStatus,
        getdate(),
        getdate(),
        @EnterByIdUser
     )
      
     set @IdSchemaOut = SCOPE_IDENTITY()
end
else
begin 
    if exists (select top 1 1 from  [TransFerTo].[Schema] where isnull(IdCountry,0)=isnull(@IdCountry,0) and isnull(IdCarrier,0)=isnull(@IdCarrier,0) and isnull(IdProduct,0)=isnull(@IdProduct,0) and isnull(BeginValue,0)=isnull(@BeginValue,0) and isnull(EndValue,0)=isnull(@EndValue,0) and IsDefault=0 and Commission=@Commission and IdSchema!=@IdSchema) and @IsDefault=0
    begin
        set @HasError=1
        set @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SchemaError2')     
        return
    end

    if exists (select top 1 1 from  [TransFerTo].[Schema] where isnull(IdCountry,0)=isnull(@IdCountry,0) and isnull(IdCarrier,0)=isnull(@IdCarrier,0) and isnull(IdProduct,0)=isnull(@IdProduct,0) and isnull(BeginValue,0)=isnull(@BeginValue,0) and isnull(EndValue,0)=isnull(@EndValue,0) and IsDefault=1 and IdSchema!=@IdSchema) and @IdProduct is not null and @IsDefault=1
    begin
        set @HasError=1
        set @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SchemaError2')     
        return
    end

    if exists (select top 1 1 from  [TransFerTo].[Schema] where isnull(IdCountry,0)=isnull(@IdCountry,0) and isnull(IdCarrier,0)=isnull(@IdCarrier,0) and isnull(IdProduct,0)=isnull(@IdProduct,0) and IsDefault=1 and ((isnull(@BeginValue,0)>=BeginValue and isnull(@BeginValue,0)<=EndValue)or(isnull(@EndValue,0)>=BeginValue and isnull(@EndValue,0)<=EndValue)) and IsDefault=1 and IdSchema!=@IdSchema) and @IdProduct is null and @IsDefault=1
    begin
        set @HasError=1
        set @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SchemaError3')     
        return
    end

    UPDATE [TransFerTo].[Schema]
   SET [SchemaName] = @SchemaName
      ,[IdCountry] = @IdCountry
      ,[IdCarrier] = @IdCarrier
      ,[IdProduct] = @IdProduct
      ,[BeginValue] = @BeginValue
      ,[EndValue] = @EndValue
      ,[Commission] = @Commission
      ,[IsDefault] = @IsDefault
      ,[IdGenericStatus] = @IdGenericStatus      
      ,[DateOfLastChange] = getdate()
      ,[EnterByIdUser] = @EnterByIdUser
    WHERE IdSchema=@IdSchema

    set @IdSchemaOut = @IdSchema
end


end try
Begin Catch            
 Set @HasError=1            
 Select @Message =dbo.[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SchemaError1')            
 Declare @ErrorMessage nvarchar(max)             
 Select @ErrorMessage=ERROR_MESSAGE()            
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('TransFerTo.st_SaveSchema',Getdate(),@ErrorMessage)            
End Catch