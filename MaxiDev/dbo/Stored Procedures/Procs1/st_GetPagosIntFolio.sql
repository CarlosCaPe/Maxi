CREATE procedure st_GetPagosIntFolio
as
Set nocount on 
Declare @IdFile int
Update PagosIntGeneradorIdFiles set IdFile=IdFile+1, @IdFile=IdFile+1
Select @IdFile

