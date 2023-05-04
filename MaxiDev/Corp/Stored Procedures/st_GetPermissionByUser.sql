CREATE procedure [Corp].[st_GetPermissionByUser]
@IdApplication int,
@IdAgent int,
@IdUser int,
@IdLenguage int = null
as


declare @IdGenericStatusEnabled int
set @IdGenericStatusEnabled = 1

if @IdLenguage is null 
    set @IdLenguage=1

select 
    M.Name ModuleName,
    O.Name OptionName,
    OU.Action,
    --a.Isdefaultoption,
    --a.ordernumber ActionOrder,
    case @IdLenguage when 1 then  O.Parentname else O.ParentnameES end Parentname,
    o.groupname,
    o.showinmenu,
    o.parentorder,
    o.ordernumber OptionOrder,
    o.ApplicationView,
    o.ShorcutImage,
    case @IdLenguage when 1 then O.Description else O.DescriptionES end OptionDescription,
    case @IdLenguage when 1 then M.Description else M.DescriptionES end ModuloDescription
from Modulo M with(nolock)
        inner join 
            (
                    select MM.IdModuloMaster
                    from dbo.ModuloMaster MM with(nolock)
                    where MM.IsFilterByAgent=0
				union
                    select MM.IdModuloMaster
                    from dbo.ModuloMaster MM with(nolock)
						inner join dbo.AgentProducts AP with(nolock) on 
                            case 
                                when AP.IdOtherProducts = 10 then 5 
                                when AP.IdOtherProducts =6 then 7 
                                --when AP.IdOtherProducts=9 then 7 
                                else AP.IdOtherProducts 
                            end =MM.IdOtherProducts and AP.IdAgent =@IdAgent and AP.IdGenericStatus=@IdGenericStatusEnabled
                    where MM.IsFilterByAgent=1 
			   union
					select MM.IdModuloMaster
					from dbo.ModuloMaster MM with(nolock)
						   inner join dbo.AgentChecks AC with(nolock) on AC.IdChecksModulo = MM.IdChekcModulo and AC.IdAgent =@IdAgent
					where MM.IsFilterByAgent=1 
            ) L on M.IdModuloMaster= L.IdModuloMaster  
        inner join [Option] O with(nolock) on M.IdModule=O.IdModule
        inner join dbo.OptionUsers OU with(nolock) on OU.IdOption = O.IdOption
        where  M.IdApplication =@IdApplication and OU.IdUser=@IdUser --and O.Name not in ('TransferTo','LunexTopUp','RegaliiTopUp')
--order by o.parentorder,o.ordernumber
