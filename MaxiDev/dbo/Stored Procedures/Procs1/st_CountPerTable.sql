
CREATE Procedure st_CountPerTable
as

Truncate table RegistrosPorTabla

Create table #temp2
(
contador int
)


Insert into RegistrosPorTabla (name)
Select name from sys.objects where type='U'

Declare @id int,@Name nvarchar(max),@Count int
Set @id=1

While Exists (Select top 1 1 from RegistrosPorTabla where ID>@id)
Begin

	Select @Name='Select count(1) from '+Name from RegistrosPorTabla where id=@id
	Insert into  #temp2 (contador)
	Exec (@Name)
	
	Select @Count=contador From #temp2
	
	Update RegistrosPorTabla set contador=@Count where id=@id
	
	Set @id=@id+1
	
	delete #temp2
	
End

Select * from RegistrosPorTabla order by contador
