create PROCEDURE [dbo].[st_UpdatePureMinutesUserID]
	@PureMinutesTransID int,
	@PureMinutesUserID nvarchar(max)
AS
	/* SET NOCOUNT ON */

    if exists(select 1 from dbo.PureMinutesTransaction where PureMinutesTransID=@PureMinutesTransID and isnull(PureMinutesUserId,'')='' )
    begin
	    update dbo.PureMinutesTransaction set PureMinutesUserId= @PureMinutesUserID where PureMinutesTransID=@PureMinutesTransID
    end

	RETURN
