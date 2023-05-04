CREATE procedure [dbo].[st_ValidateCustomerAddress]
(
    @IdLenguage int,
    @CustomerAddress nvarchar(max),
	@HasError bit OUTPUT,
	@ResultMessage nvarchar(max) OUTPUT
)
as

set @IdLenguage = isnull(@IdLenguage,2);

declare @TempString nvarchar(500);
set @TempString =  replace(@CustomerAddress,' ', '');
set @TempString =  replace(@TempString,'.', '');
set @TempString =  replace(@TempString,',', '');
set @TempString =  UPPER(@TempString);

/*2	Disabled*/
if exists (SELECT Top 1 1 FROM Agent WITH(NOLOCK) WHERE IdAgentStatus != 2  and  UPPER(replace(replace(replace(AgentAddress,'.', ''),' ', ''),',', '')) = @TempString)
begin
	Set @HasError = 1;
    Set @ResultMessage = [dbo].[GetMessageFromMultiLenguajeResorces](@IdLenguage,'MESSAGE71');
end
else
begin
    Set @HasError = 0;
	Set @ResultMessage = '';
end