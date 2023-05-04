
/********************************************************************
<Author>  </Author>
<app> Pontual </app>
<Description></Description>
<ChangeLog>
<log>date:22-05-2020, CR M00036, modificate by: jgomez </>
</ChangeLog>
*********************************************************************/

CREATE PROCEDURE [dbo].[st_SaveRefExRatePontual]
	 @RefExRate money,
     @EnterByIdUser int
AS

IF NOT EXISTS(SELECT * FROM [dbo].[RefExRate] WITH(NOLOCK) where IdGateway = 28 AND Active = 1 AND IdCountryCurrency = 3)
  BEGIN

   INSERT INTO [dbo].[RefExRate]
           ([IdCountryCurrency]
           ,[RefExRate]
           ,[Active]
           ,[DateOfLastChange]
           ,[EnterByIdUser]
           ,[IdGateway]
           ,[IdPayer])
     VALUES
           (3
           ,@RefExRate
           ,1 
           ,getdate()
           ,@EnterByIdUser
           ,28
           ,NULL)
  END
ELSE
  BEGIN
		UPDATE [dbo].[RefExRate]
		set [RefExRate] = @RefExRate,
		[DateOfLastChange] = GETDATE(),
		[EnterByIdUser] = @EnterByIdUser
		where IdGateway = 28 AND Active = 1
END
