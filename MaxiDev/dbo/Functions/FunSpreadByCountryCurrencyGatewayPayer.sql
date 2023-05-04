

create function  [dbo].[FunSpreadByCountryCurrencyGatewayPayer] (@IdCountryCurrency int, @IdGateway int, @IdPayer int, @IsMax bit)  
RETURNS Money  
begin
    declare @result money
    if @IsMax=1
    begin
        select @result=max(SpreadValue) from payerconfig with (nolock) where idgenericstatus=1 and idpayer=@IdPayer and idgateway=@IdGateway and idcountrycurrency=@IdCountryCurrency
    end
    else
    begin
        select @result=min(SpreadValue) from payerconfig with (nolock) where idgenericstatus=1 and idpayer=@IdPayer and idgateway=@IdGateway and idcountrycurrency=@IdCountryCurrency
    end
    return isnull(@result,0)
end