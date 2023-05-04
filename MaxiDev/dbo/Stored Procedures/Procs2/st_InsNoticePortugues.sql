CREATE  Procedure [dbo].[st_InsNoticePortugues] (@State varchar(max), @Notice varchar(max)) 
AS
BEGIN

DECLARE @result bit = 0
declare @IdState int = 0

set @IdState = null


IF ((Select count(*) from State s inner join StateNote n on n.IdState = s.IdState where s.StateName = @State) > 0)
	begin
		SET @IdState = (Select IdState from State where StateName = @State)
		update StateNote set ComplaintNoticePortugues = @Notice where IdState = @IdState
	end
else
	begin
		SET @IdState = (Select IdState from State where StateName = @State)
		if (@IdState is not null and @IdState > 0)
			begin
				INSERT INTO StateNote (IdState,ComplaintNoticePortugues)
				 VALUES (@IdState ,@Notice)
			end
	end



end
