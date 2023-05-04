
create function GetToday()
returns int
Begin

--This must be the result
--Monday		=1
--tuesday		=2
--wednesday		=3
--thursday		=4
--friday		=5
--saturday		=6
--SunDay		=7

Declare @Today int
set @Today= datepart(dw,getdate()) 

--To Fix in production uncomment
Set @Today=@Today-1
If  @Today=0
	Set @Today=7
return @Today

End

