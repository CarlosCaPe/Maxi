CREATE function [dbo].[funGetBranchCodeAndName] (@IdCity int, @BranchReceive nvarchar(max), @Idgateway int, @IdPayer int, @idstatus int)  
RETURNS nvarchar(max)   
BEGIN 

if @idstatus not in (30) return ''

declare @BranchCodeAndName nvarchar(max) 

select top 1 
    --@CityReceive = upper(isnull(c.CityName,''))
    --@StateReceive = upper(isnull(s.StateName,''))
    @BranchCodeAndName = upper(isnull(b.BranchName,''))
from 
    GatewayBranch gb WITH(NOLOCK)
join Branch 
        b WITH(NOLOCK) on b.IdBranch=gb.IdBranch and IdPayer=@IdPayer
left join 
    city c WITH(NOLOCK) on b.IdCity=c.IdCity and b.idcity=@IdCity
left join 
    [state] s WITH(NOLOCK) on c.IdState=s.IdState
where 
    idgateway=@IdGateway and 
    GatewayBranchCode = 
    case (@IdGateway)
            when 9 then 
                case (IdPayer)
                    when 631 then @BranchReceive --facach
                    else 
                        case (
                            case (len(isnull(@BranchReceive,'')))
                            when 0 then @BranchReceive
                            when 1 then @BranchReceive
                            when 2 then @BranchReceive
                            when 3 then @BranchReceive
                            when 4 then @BranchReceive
                            else
                                substring(@BranchReceive,4,len(@BranchReceive)-3)
                            end
                            )
                        when '01' then '1'
                        when '02' then '2'
                        when '03' then '3'
                        when '04' then '4'
                        when '05' then '5'
                        when '06' then '6'
                        when '07' then '7'
                        when '08' then '8'
                        when '09' then '9'
                        else
                            case (len(isnull(@BranchReceive,'')))
                            when 0 then @BranchReceive
                            when 1 then @BranchReceive
                            when 2 then @BranchReceive
                            when 3 then @BranchReceive
                            when 4 then @BranchReceive
                            else
                                substring(@BranchReceive,4,len(@BranchReceive)-3)
                            end
                        end
                end                                
            else
                @BranchReceive 
            end
order by
	upper(isnull(c.CityName,'')) desc ,upper(isnull(s.StateName,'')) desc,b.address desc
    --b.address desc


return @BranchCodeAndName

end