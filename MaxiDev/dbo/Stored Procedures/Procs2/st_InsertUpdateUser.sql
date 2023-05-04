CREATE Procedure [dbo].[st_InsertUpdateUser]    
(    
@IdUser Int,    
--@UserName nvarchar(max),    
@FirstName NVARCHAR(MAX),
@LastName NVARCHAR(MAX),
@SecondLastName NVARCHAR(MAX),
@UserLogin nvarchar(max),    
@IdUserType int,    
@UserMustChangePasswordAtNextTime bit,    
@AllowUserRegisterNewPc bit,    
@PasswordWasChanged bit,    
@Password nvarchar(max),    
@IdAgent int,    
@ZipCode nvarchar(max),    
@State nvarchar(max),    
@City nvarchar(max),    
@Address nvarchar(max),    
@Phone nvarchar(max),    
@Cellular nvarchar(max),    
@Email nvarchar(max),    
@IdUserSellerParent int,    
@salt nvarchar(max),    
@EnterByIdUser int,    
@IdGenericStatus int,    
@Options xml,    
--@IsSpanishLanguage bit, 
@IdCounty int=null,   
@IdLenguage int,
@idUserEdit int=0,
@HasError bit out,      
@Message varchar(max) out     
  )    
AS    
Set nocount on  

/********************************************************************
<Author> ???</Author>
<app>Corporate </app>
<Description> Inserta o actualiza los usuarios </Description>

<ChangeLog>
<log Date="16/08/2017" Author="dalmeida"> Se arregla bug que borraba los permisos especiales </log>
<log Date="25/07/2018" Author="mhinojo"> Se reinicia el contador de cambio de contraseña y se valida userlogin unico </log>
<log Date="29/08/2018" Author="smacias"> Se agrega los insert para los logs de cambios </log>
<log Date="10/09/2018" Author="smacias"> Se cambian los valores de action almacenado para valores mas precisos</log>
<log Date="08/10/2018" Author="smacias"> Se cambian las leyendas de los cambios</log>
</ChangeLog>

*********************************************************************/
Declare @DocHandle int
EXEC sp_xml_preparedocument @DocHandle OUTPUT, @Options

if @IdLenguage is null 
    set @IdLenguage=2
     
Begin Try      
--o FullUserName
DECLARE @UserName nvarchar(max) = ISNULL(@FirstName, '') + ' ' + ISNULL(@LastName, '') + ' ' + ISNULL(@SecondLastName, '')
--o
Declare @CurrentDate datetime
Set @CurrentDate=GETDATE()    
    
---- Validacion, no se puede repetir el userlogin ----------------    
IF Exists(Select 1 from users where (LTRIM(RTRIM(UPPER(UserLogin))) <> LTRIM(RTRIM(UPPER(@UserLogin))) AND IdUser = @IdUser) OR @IdUser = 0) 
BEGIN
	If Exists(Select 1 from users where LTRIM(RTRIM(UPPER(UserLogin)))=LTRIM(RTRIM(UPPER(@UserLogin))))    
	Begin    
		Set @HasError=1      
		--Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,18)
		SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE18')
	 Return    
	End    
END
-------------------------- Nuevo Usuario ---------------------------      
    
 If @IdUser=0    
    Begin    
 -- Alta usuario    
 Insert into Users (    
    UserName,    
    UserLogin,    
    UserPassword,    
    DateOfCreation,    
    CreatedByIdUser,    
    IdUserType,    
    ChangePasswordAtNextLogin,    
    AllowToRegisterPc,    
    IdGenericStatus,    
    salt,    
    EnterByIdUser,    
    DateOfLastChange
	--o
	, FirstName
	, LastName
	, SecondLastName   
	--o
    )    
    Values    
    (    
    @UserName,    
    @UserLogin,    
    @Password,    
    @CurrentDate,    
    @EnterByIdUser,    
    @IdUserType,    
    @UserMustChangePasswordAtNextTime,    
    @AllowUserRegisterNewPc,    
    1,    
    @salt,    
    @EnterByIdUser,    
    @CurrentDate    
	--o
	, @FirstName
	, @LastName
	, @SecondLastName
	--o
    )    
    Set @IdUser = SCOPE_IDENTITY()    
  if @IdUserType=1     
  Begin    
      Insert into corporate     
      (    
            IdUserCorporate,    
            ZipCode,    
            State,    
            City,    
            Address,    
            Phone,    
            Cellular,    
            Email,
            IdCounty
            )    
            Values    
            (    
            @IdUser, 
            @ZipCode,    
            @State,    
            @City,    
            @Address,    
            @Phone,    
            @Cellular,    
            @Email,
            @IdCounty
            )     
  End    
 if @IdUserType=2 and @IdAgent>0     
  Begin  
       Insert into AgentUser    
       (    
        IdAgent,    
        IdUser    
        )    
       values    
       (    
       @IdAgent,    
       @IdUser    
       )    
  End    
 if @IdUserType=3    
  Begin    
  Insert into Seller     
      (    
            IdUserSeller,    
            ZipCode,    
            State,    
            City,    
            Address,    
            Phone,    
            Cellular,    
            Email,    
            IdUserSellerParent,
            IdCounty
            )    
            Values    
            (    
            @IdUser,    
            @ZipCode,    
            @State,    
            @City,    
            @Address,    
            @Phone,    
            @Cellular,    
            @Email,    
            @IdUserSellerParent,
            @IdCounty
            )    
  End     
  End    
  Else    
  Begin    
-------------------------- Update Usuario ---------------------------     
-----Tablas Temporales para el Historico    
DECLARE @UserEdit TABLE(Field varchar(100), Change varchar(100));
DECLARE @UserEditOption TABLE(idOption INT, idAction int, Change varchar(50));
DECLARE @OldOptions TABLE (idAction int);
DECLARE @NewOptions TABLE (idAction int);
--Fecha   @CurrentDate
---Declara las variables para compararlas y agregarlas a las tablas temporales
Declare @oldIdGenericStatus nvarchar(max);
Declare @oldFirstName nvarchar(max);
Declare @oldLastName nvarchar(max);
Declare @oldSecondLastName nvarchar(max);
Declare @oldZipCode nvarchar(max);
Declare @oldCity nvarchar(max);
Declare @oldAddress nvarchar(max);
Declare @oldCellular nvarchar(max);
Declare @oldState nvarchar(max);
Declare @oldIdCounty nvarchar(max);
Declare @oldPhone nvarchar(max);
Declare @oldEmail nvarchar(max);
Declare @oldIdUserSellerParent nvarchar(max);
--Asigna las variables
Select @oldIdGenericStatus = IdGenericStatus, @oldFirstName = FirstName, @oldLastName = LastName, @oldSecondLastName = SecondLastName
from Users
where iduser = @IdUser;
 if @IdUserType=1     
Begin
	Select 
	@oldZipCode=ZipCode,    
    @oldState=State,    
    @oldCity=City,    
    @oldAddress=Address,    
    @oldPhone=Phone,    
    @oldCellular=Cellular,    
    @oldEmail=Email,
    @oldIdCounty=IdCounty
	from Corporate
    Where IdUserCorporate=@IdUser   
end
if @IdUserType=3  
Begin   
	Select    
		@oldZipCode=ZipCode,    
		@oldState=State,    
		@oldCity=City,    
		@oldAddress=Address,    
		@oldPhone=Phone,    
		@oldCellular=Cellular,    
		@oldEmail=Email,    
		@oldIdUserSellerParent=IdUserSellerParent ,
		@oldIdCounty=IdCounty   
	from Seller
	Where IdUserSeller=@IdUser   
end
--Compara y Agrega los campos modificados
if(@oldIdGenericStatus !=@IdGenericStatus)
Insert into @UserEdit (Field, Change) (Select 'Status', GenericStatus from GenericStatus where IdGenericStatus = @IdGenericStatus);
if(@oldFirstName !=@FirstName)
Insert into @UserEdit values ('First Name', @FirstName);
if(@oldLastName !=@LastName)
Insert into @UserEdit values ('Last Name', @LastName);
if(@oldSecondLastName !=@SecondLastName)
Insert into @UserEdit values ('Second Last Name', @SecondLastName);
if(@PasswordWasChanged=1)
Insert into @UserEdit values ('Password', '*********');
if(@oldZipCode != @ZipCode)
Insert into @UserEdit values ('ZipCode', @ZipCode);
if(@oldCity !=@City)
Insert into @UserEdit values ('City', @City);
if(@oldAddress != @Address)
Insert into @UserEdit values ('Address', @Address);
if(@oldCellular != @Cellular)
Insert into @UserEdit values ('Cellular', @Cellular);
if(@oldState != @State)
Insert into @UserEdit values ('State', @State);
if(@oldIdCounty != @IdCounty)
Insert into @UserEdit values ('County', @IdCounty);
if(@oldPhone != @Phone)
Insert into @UserEdit values ('Phone', @Phone);
if(@oldEmail != @Email)
Insert into @UserEdit values ('Email', @Email);
if(@oldIdUserSellerParent !=@IdUserSellerParent and @IdUserType=3)
Insert into @UserEdit values ('Seller Parent', (Select UserName from Users where IdUser=@IdUserSellerParent));


  Update Users Set    
     UserName=@UserName,    
     ChangePasswordAtNextLogin=@UserMustChangePasswordAtNextTime,    
     AllowToRegisterPc=@AllowUserRegisterNewPc,    
     IdGenericStatus=@IdGenericStatus,    
     DateOfLastChange=@CurrentDate,    
     EnterByIdUser=@EnterByIdUser
	 --o 
	 , FirstName=@FirstName
	, LastName=@LastName
	, SecondLastName=@SecondLastName   
	--o
     Where IdUser=@IdUser    
         
    if @PasswordWasChanged=1    
	Begin    
       Update Users Set    
          UserPassword=@Password,    
          Salt=@salt    
          Where IdUser=@IdUser    
		
		/*********************  REINICIA CONTADOR DE CAMBIO DE CONTRASEÑA ****************************************************/
		IF EXISTS (SELECT TOP 1 1 FROM UsersAditionalInfo WITH(NOLOCK) WHERE IdUser = @IdUser)
			UPDATE UsersAditionalInfo SET DateOfChangeLastPassword = @CurrentDate, AttemptsToLogin = 0 WHERE IdUser = @IdUser
		ELSE
			INSERT INTO UsersAditionalInfo (IdUser, DateOfChangeLastPassword, AttemptsToLogin) VALUES (@IdUser, @CurrentDate, 0)	

		/*********************************************************************************************************************/
    End    
     
  if @IdUserType=1     
  Begin    
     Update Corporate set    
           ZipCode=@ZipCode,    
           State=@State,    
           City=@City,    
           Address=@Address,    
           Phone=@Phone,    
           Cellular=@Cellular,    
           Email=@Email,
           IdCounty=@IdCounty
           Where IdUserCorporate=@IdUser    
  End    
      
 if @IdUserType=3    
  Begin    
     Update Seller set    
           ZipCode=@ZipCode,    
           State=@State,    
           City=@City,    
           Address=@Address,    
           Phone=@Phone,    
           Cellular=@Cellular,    
		   Email=@Email,		
           IdUserSellerParent=@IdUserSellerParent ,
           IdCounty=@IdCounty   
           Where IdUserSeller=@IdUser    
  End
--Guarda los viejos permisos
insert into @OldOptions (idAction)
(Select idAction from ActionAllowed AA join 
(Select OpU.IdOption, s.Item from OptionUsers OpU outer apply dbo.fnSplit(OpU.Action, '|') s where IdUser = @IdUser) OpA
on AA.IdOption=OpA.IdOption and AA.Code=OpA.item)

--Guarda los nuevos permisos
insert into @NewOptions (idAction)
(Select idAction from ActionAllowed AA join 
(Select OpU.IdOption as IdOption, s.Item from 
OPENXML (@DocHandle, '/Options/Detail',2) WITH (IdOption int, Action nvarchar(max)) OpU
outer apply dbo.fnSplit(OpU.Action, '|') s) OpA
on AA.IdOption=OpA.IdOption and AA.Code=OpA.item)


----Compara los permisos para insertarlos en la tabla de logs
Insert into @UserEditOption (idAction, Change) --Compara la lista Actual con la Nueva obteniendo los eliminados
(Select idAction, 'Disabled' from @OldOptions where idAction not in (Select idAction from @NewOptions))

Insert into @UserEditOption (idAction, Change) --Compara la lista Nueva con la Actual obteniendo los habilitados
(Select idAction, 'Enabled' from @NewOptions where idAction not in (Select idAction from @OldOptions))


if(@idUserEdit!=0)
begin
	--Inserta los logs de cambios despues de realizar los cambios
	insert into [dbo].[UserChangeHistory] ([idUser]
	,[idUserModified]
	,[Date]
	,[Field]
	,[Change])
	(Select @idUserEdit, @IdUser, @CurrentDate, Field, Change from @UserEdit)
  
  
	-------Inserta los cambios en la tabla de Logs
	Insert into [dbo].[UserOptionChangeHistory] 
	([idUser]
	,[idUserModified]
	,[Change]
	,[idAction]
	,[Date])
	(Select @idUserEdit, @IdUser, Change, idAction, @CurrentDate from @UserEditOption)  
end        

End    

      
  -------Borra las opciones e Ingresa los Permisos -------------    
Declare @canDeleteSP int = 0

 IF EXISTS(SELECT 1 FROM OptionUsers WHERE IdUser = @EnterByIdUser AND IdOption IN (SELECT IdOption FROM [Option] WHERE NAME = 'UsersPermissionsCp' OR NAME = 'UsersPermissionsAg')  AND Action like '%SP%')
	BEGIN
		SET @canDeleteSP = 1
	END

IF @canDeleteSP = 1
	BEGIN
		 Delete OptionUsers where IdUser=@IdUser
	END
ELSE
	BEGIN
		 Delete OptionUsers where IdUser=@IdUser and IdOption not in (SELECT IdOption FROM [Option] WHERE NAME = 'UsersPermissionsCp' OR NAME = 'UsersPermissionsAg')
	END

 --Inserta los nuevos permisos  
 Insert into OptionUsers (IdOption,IdUser,Action)      
 Select IdOption,@IdUser,Action From OPENXML (@DocHandle, '/Options/Detail',2)      
 WITH (      
 IdOption int,      
 Action nvarchar(max)      
 )       
 Exec sp_xml_removedocument @DocHandle 
 --------- Fin de Ingreso de Nuevos Permisos --------------------    
    
--------
 Set @HasError=0      
 --Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,19)      
 SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE19')
End Try      
Begin Catch      
 Set @HasError=1      
 --Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,20)      
 SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE20')
 Declare @ErrorMessage nvarchar(max)       
 Select @ErrorMessage=ERROR_MESSAGE()      
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_InsertUpdateUser',Getdate(),@ErrorMessage)      
End Catch

