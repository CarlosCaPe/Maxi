create function [dbo].[RemoveTimeFromDatetime] (@date datetime)
returns datetime
Begin

return  cast(floor(cast(@date as float)) as datetime)

End
