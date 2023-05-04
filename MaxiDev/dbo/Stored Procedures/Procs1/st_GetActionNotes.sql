
CREATE PROCEDURE [dbo].[st_GetActionNotes]              
(              
	@Type int,              
	@Action datetime              
)              
AS              
  
  SELECT * FROM ActionNotes WHERE Type = @Type AND Action = @Action AND IsEnabled = 1

