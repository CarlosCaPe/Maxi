create PROCEDURE dbo.st_SaveRefExRate	 
	 @IdCountryCurrency int,
	 @RefExRate money,
	 @DateOfLastChange  datetime,
	 @EnterByIdUser int,
	 @IdGateway int,
	 @IdPayer int
AS

	update dbo.RefExRate set Active=0 where idCountryCurrency=@IdCountryCurrency
	and isnull(IdPayer,0) = isnull(@IdPayer,0) and isnull(IdGateway,0)=isnull(@IdGateway,0) and Active=1

	INSERT INTO [dbo].[RefExRate]
           ([IdCountryCurrency]
           ,[RefExRate]
           ,[Active]
           ,[DateOfLastChange]
           ,[EnterByIdUser]
           ,[IdGateway]
           ,[IdPayer])
     VALUES
           (@IdCountryCurrency
           ,@RefExRate
           ,1 
           ,@DateOfLastChange
           ,@EnterByIdUser
           ,@IdGateway
           ,@IdPayer)
		   
	RETURN
