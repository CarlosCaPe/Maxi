CREATE PROCEDURE [dbo].[st_ValidatedPontualStatusXML]
(
    @ResultCodesTemp xml,
	@IdGatewayReturnCodeType int,
    @IsSpanishLanguage bit = 1,
    @HasError bit = 0 ,
    @MessageOUT varchar(max) = out   
)
AS

--declaracion de variables
DECLARE  
@DocHandle INT ,
@ResponseName varchar(250),
@StatusName varchar(250),
@Status varchar(20),
@IsActive bit 

Create Table #ResultCodesTemp
(
    Id int identity(1,1),
	ResultCodes varchar(250),
	IsActive bit 
)

Create Table #ResultCodes
(
    Id int identity(1,1),
	ResultCodes varchar(250),
	IsActive bit default(0),
	StatusName varchar (250)
)

begin try

--Inicializar Variables
Set @HasError=0

EXEC sp_xml_preparedocument @DocHandle OUTPUT, @ResultCodesTemp 

SELECT @ResponseName = ResultCodes FROM OPENXML (@DocHandle, '/Error',2) With ( ResultCodes varchar(250))

EXEC sp_xml_removedocument @DocHandle 

INSERT INTO #ResultCodesTemp (ResultCodes) (SELECT [item] FROM [dbo].[fnSplit] (@ResponseName,','))

WHILE EXISTS (select * from #ResultCodesTemp)
   BEGIN 

	DECLARE @NonNumeric varchar(1000)
	DECLARE @Index int 
	DECLARE @IdS int 

	select @NonNumeric =  ResultCodes , @IdS = Id from #ResultCodesTemp

SET @Index = 0  
WHILE 1=1  
BEGIN  
       set @Index = patindex('%[^0-9]%',@NonNumeric)  
       if @Index <> 0  
       begin  
           SET @NonNumeric = replace(@NonNumeric,substring(@NonNumeric,@Index, 1), '')  
       end  
       else    
           break;   
END  
insert into #ResultCodes (ResultCodes) values (@NonNumeric)
delete from #ResultCodesTemp where Id = @IdS   

END 

WHILE EXISTS (select * from #ResultCodes where StatusName is null AND IsActive = 0)
BEGIN 
	SELECT @Status =  ResultCodes, @IdS = Id from #ResultCodes where StatusName is null

	SELECT @StatusName = s.StatusName
	from GatewayReturnCode A  with(nolock)
	Join GatewayReturnCodeType B with(nolock) on (A.IdGatewayReturnCodeType=B.IdGatewayReturnCodeType)
	inner join [Status] s with(nolock) on (s.IdStatus = A.IdStatusAction)
	where A.IdGateway=28 And A.IdGatewayReturnCodeType=@IdGatewayReturnCodeType And A.ReturnCode=@Status

	update #ResultCodes Set StatusName = @StatusName, IsActive = 1  where Id = @IdS

END

SELECT * FROM #ResultCodes

End Try
Begin Catch
 Set @HasError=1                                                                                   
 Select @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,80)  
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[dbo].[st_ValidatedPontualStatusXML]',Getdate(),ERROR_MESSAGE())    
End Catch


