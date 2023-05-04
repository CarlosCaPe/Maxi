CREATE PROCEDURE [Corp].[st_SaveOwner] (
	@idOwner int,
    @name varchar(MAX),
    @lastName varchar(MAX),
    @secondLastName varchar(MAX),
    @address varchar(MAX),
    @city varchar(MAX),
    @state varchar(MAX),
    @zipcode varchar(MAX),
    @phone varchar(MAX),
    @cel varchar(MAX),
    @email varchar(MAX),
    @ssn varchar(MAX),
    @idType varchar(MAX),
    @idNumber varchar(MAX),
    @idExpirationDate datetime = null,
    @bornDate datetime = null,
    @bornCountry varchar(MAX),
    @idStatus int,
	@enteredByIdUser int,	
	@IsSpanishLanguage bit,
    @Idcounty int = null,
	@HasError bit out,
	@MessageOut varchar(max) out,
	@IdOwnerOut int out
)            
AS            
Begin TRY

	/********************************************************************
	<Author>Unknown</Author>
	<app>MaxiCorp</app>
	<Description></Description>
	
	<ChangeLog>
	<log Date="22/02/2023" Author="cagarcia">BM-860: Se agrega validacion de SSN de Owner duplicado </log>
	</ChangeLog>
	********************************************************************/

	Set @HasError=0
	set @MessageOut =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,82) 

	if(exists (select top  1 1 from Owner with (nolock) where replace(replace(SSN, '-', ''), ' ', '') = replace(replace(@ssn, '-', ''), ' ', '') and IdOwner != @idOwner))
		begin 
			Set @HasError=1
			set @MessageOut =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,84)
			set @IdOwnerOut = 0
	    end
	else 
		begin 
			if(@idOwner > 0)
				begin
					if(exists(select top 1 1 from Owner with (nolock) where IdOwner = @idOwner))
						begin 
							update [dbo].[Owner] set 
							Name = @name, 
							LastName = @lastName,
							SecondLastName = @secondLastName,
							[Address] = @address,
							City = @city,
							[State] = @state,
							Zipcode = @zipcode,
							Phone = @phone,
							Cel = @cel,
							Email = @email,
							SSN = @ssn,
							IdType = @idType,
							IdNumber = @idNumber,
							IdExpirationDate = @idExpirationDate,
							BornDate = @bornDate,
							BornCountry = @bornCountry,
							IdStatus = @idStatus,
							DateofLastChange = GETDATE(),
							EnterByIdUser = @enteredByIdUser,
                            Idcounty = @Idcounty
							where IdOwner = @idOwner
						end
					else
						begin 
							Set @HasError=1
							Select @MessageOut =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,86)
						end

					set @IdOwnerOut = @idOwner

				end
			else
				begin 
					insert into [dbo].[Owner] (      
					  Name
					  ,LastName
					  ,SecondLastName
					  ,[Address]
					  ,City
					  ,[State]
					  ,Zipcode
					  ,Phone
					  ,Cel
					  ,Email
					  ,SSN
					  ,IdType
					  ,IdNumber
					  ,IdExpirationDate
					  ,BornDate
					  ,BornCountry
					  ,CreationDate
					  ,DateofLastChange
					  ,EnterByIdUser
					  ,IdStatus
                      ,Idcounty
				  )values (
					  @name, 
					  @lastName,
					  @secondLastName,
					  @address,
					  @city,
					  @state,
					  @zipcode,
					  @phone,
					  @cel,
					  @email,
					  @ssn,
					  @idType,
					  @idNumber,
					  @idExpirationDate,
					  @bornDate,
					  @bornCountry,
					  GETDATE(),
					  GETDATE(),
					  @enteredByIdUser,
					  @idStatus,
                      @Idcounty
                      )

			  set @IdOwnerOut = SCOPE_IDENTITY()
			end
		end
End Try                                                
Begin Catch        
                                        
	Set @HasError=1
	Select @MessageOut =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,33)          
	Declare @ErrorMessage nvarchar(max)                                       
	Select @ErrorMessage=ERROR_MESSAGE()                                                
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_SaveOwner]',Getdate(),@ErrorMessage)

End Catch 
