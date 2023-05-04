CREATE function  [dbo].[funPayInfoGetState] (@IdCity int, @BranchReceive nvarchar(max), @Idgateway int, @IdPayer int, @idstatus int)  
RETURNS nvarchar(max)
/********************************************************************
<Author>Not Known</Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="24/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/   
BEGIN 

if @idstatus not in (30) return ''

declare @StateReceive nvarchar(max) 

select top 1 
    --@CityReceive = upper(isnull(c.CityName,''))
    @StateReceive = upper(isnull(s.StateName,''))
    --@AddressReceive = upper(isnull(b.Address,''))
from 
    GatewayBranch gb with(nolock)
join Branch 
        b with(nolock) on b.IdBranch=gb.IdBranch and IdPayer=@IdPayer
left join 
    city c with(nolock) on b.IdCity=c.IdCity and b.idcity=@IdCity
left join 
    [state] s with(nolock) on c.IdState=s.IdState
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
    upper(isnull(c.CityName,'')) desc ,upper(isnull(s.StateName,'')) desc,b.[address] desc

if (@StateReceive='')
begin
    select top 1 
        --@CityReceive = upper(isnull(c.CityName,''))--,
        @StateReceive = upper(isnull(s.StateName,''))
        --@AddressReceive = upper(isnull(b.Address,''))
    from 
        GatewayBranch gb with(nolock)
    join Branch 
        b with(nolock) on b.IdBranch=gb.IdBranch and IdPayer=@IdPayer
    left join 
        city c with(nolock) on b.IdCity=c.IdCity
    left join 
        [state] s with(nolock) on c.IdState=s.IdState
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
    b.[address] desc
end

return @StateReceive

end