
CREATE function [dbo].[fnMixTable]
(@string varchar(1000),@separator char(1))
returns @result table (
	name nvarchar(1000),
	firstLastName nvarchar(1000),
	secondLastName nvarchar(1000)
	)
as
BEGIN

declare @names TABLE 
	(
		id int ,
		part nvarchar(1000)
	)
insert into @names 
select id, part 
	from  dbo.[FnSplitTable](@string,@separator)

declare @namesNumber int
set @namesNumber = (select count(1) from @names)

declare @id int, @part nvarchar(1000)
declare @Name nvarchar(100), @FirstLastName nvarchar(100), @Text nvarchar(100)

declare @merges int
 
if( @namesNumber=1)
	Begin
		set @part =(select part from @names where id=1)	
		insert @result (name,firstLastName,secondLastName) 
			values (LTRIM(RTRIM(@part)), '', '')
	End
Else
	Begin
		set @merges=1
		while (@merges<@namesNumber)
			Begin	
				set @id=1	
				set @Name =''
				set @FirstLastName =''
				while (@id<=@namesNumber)
					Begin
						set @part =(select part from @names where id=@id)				
						if(@id<=@merges)
							Begin
								set @Name = @Name +' '+ @part 
							End
						Else
							Begin
								set @FirstLastName = @FirstLastName +' '+ @part 
							End
						set @id = @id+1
					End
				set @merges = @merges+1
				insert @result (name,firstLastName,secondLastName) 
					values (LTRIM(RTRIM(@name)), LTRIM(RTRIM(@firstLastName)), '')
			end
	End	
return
END
