create procedure [dbo].[st_GetServiCentroIdFile]
(            
    @IdFile INT output            
)
as
Set  @IdFile=0 
if not exists (select top 1 1 from ServiCentroGeneradorIdFiles where [DateOfGenerator]=[dbo].[RemoveTimeFromDatetime](getdate()))
 begin
    insert into [ServiCentroGeneradorIdFiles]
    values
    (0,[dbo].[RemoveTimeFromDatetime](getdate()))
 end
    Update ServiCentroGeneradorIdFiles set IdFile=IdFile+1,@IdFile=IdFile+1 where [DateOfGenerator]=[dbo].[RemoveTimeFromDatetime](getdate())