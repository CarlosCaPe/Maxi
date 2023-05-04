CREATE procedure [Corp].[st_GetPermissionTreeByApp]
@IdApplication int,
@IdAgent int,
@IdLenguage int = null
as

declare @IdGenericStatusEnabled int
set @IdGenericStatusEnabled = 1

if @IdLenguage is null 
    set @IdLenguage=1

IF @IdAgent <= 0 SET @IdAgent = NULL

select
    M.IdApplication,
    M.IdModule,
    M.Name ModuleName,
    case @IdLenguage when 1 then M.Description else M.DescriptionES end ModuleDescription,
    O.IdOption,
    O.Name OptionName,
    case @IdLenguage when 1 then O.Description else O.DescriptionES end OptionDescription,
    A.IdAction,
    A.Code ActionCode,
    case @IdLenguage when 1 then A.Description else A.DescriptionES end ActionDescription,
    a.Isdefaultoption,
    a.ordernumber ActionOrder,
    case @IdLenguage when 1 then  O.Parentname else O.ParentnameES end Parentname,
    o.groupname,
    o.showinmenu,
    o.parentorder,
    o.ordernumber OptionOrder,
    o.ApplicationView,
    o.ShorcutImage
INTO #Result
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
    inner join ActionAllowed A with(nolock) on O.IdOption = A.IdOption
    where M.IdApplication =@IdApplication 
order by  o.parentorder,o.ordernumber



select 
	R.IdApplication,
    R.IdModule,
    R.ModuleName,
    R.ModuleDescription,
    R.IdOption,
    R.OptionName,
    R.OptionDescription,
    R.IdAction,
    R.ActionCode,
    R.ActionDescription,
    R.Isdefaultoption,
    R.ActionOrder,
    R.Parentname,
    R.groupname,
    R.showinmenu,
    R.parentorder,
    R.OptionOrder,
    R.ApplicationView,
    R.ShorcutImage
from #Result R
	left join [AdditionalRestriction] AR with(nolock) ON R.[ActionCode] = AR.[ActionCode] AND R.[OptionName] = AR.[OptionName] AND R.[ModuleName] = AR.[ModuleName]
		and ((@IdAgent is null and AR.[ApplyToMonoAgent] = 1) or (@IdAgent is not null and AR.[ApplyToMonoAgent] = 0) )
Where AR.[AdditionalRestrictionId] IS NULL --and R.OptionName not in ('TransferTo','LunexTopUp','RegaliiTopUp')
order by r.IdAction

