CREATE procedure [dbo].[st_GetPermissionTreeByApp]
@IdApplication int,
@IdAgent int,
@IdLenguage int = null
as

/********************************************************************
<Author>unk</Author>
<app>---</app>
<Description>unk.</Description>

<ChangeLog>
<log Date="15/06/2018" Author="azavala">Se descartan las opciones de 'TransferTo', 'LunexTopUp','RegaliiTopUp', 'BillPaymentInternational' #1</log>
<log Date="16/06/2018" Author="azavala">Se descarta lunex para el usuario 0020tx #2</log>
<log Date="22/06/2018" Author="jmmolina">Se elimina filtro para 'TransferTo', 'LunexTopUp','RegaliiTopUp', 'BillPaymentInternational' </log>
<log Date="30/06/2018" Author="jdarellano" Name="#3">Se agrega "BillPayment" para evitar mostrar Pago de Bill Nacional</log>
</ChangeLog>
*********************************************************************/

declare @IdGenericStatusEnabled int
set @IdGenericStatusEnabled = 1

if @IdLenguage is null 
    set @IdLenguage=1

IF @IdAgent <= 0 SET @IdAgent = NULL

DECLARE @Agents TABLE (IdAgent int)

INSERT INTO @Agents--#2
SELECT DISTINCT IdAgent FROM dbo.AgentUser WITH(NOLOCK) WHERE IdUser in (2162)

DECLARE @Providers TABLE (provider varchar(255))--#2

INSERT INTO @Providers--#2
SELECT Provider
FROM (
--SELECT Provider = IIF(EXISTS(SELECT 1 FROM @Agents WHERE IdAgent = @IdAgent), null, 'LunexTopUp')
SELECT Provider = 'LunexTopUp'
/*SELECT Provider = 'TransferTo' 
UNION SELECT Provider = IIF(EXISTS(SELECT 1 FROM @Agents WHERE IdAgent = @IdAgent), null, 'LunexTopUp')
UNION SELECT Provider = 'RegaliiTopUp' 
UNION SELECT Provider = 'BillPaymentInternational'*/
)  AS t
WHERE Provider is not null

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
from Modulo M
    inner join 
        (
            select MM.IdModuloMaster
            from dbo.ModuloMaster MM                                                                   
            where MM.IsFilterByAgent=0
		union
            select MM.IdModuloMaster
            from dbo.ModuloMaster MM
                   inner join dbo.AgentProducts AP on 
                    case 
                        when AP.IdOtherProducts = 10 then 5 
                        when AP.IdOtherProducts =6 then 7 
                        --when AP.IdOtherProducts=9 then 7 
                        else AP.IdOtherProducts 
                    end =MM.IdOtherProducts and AP.IdAgent =@IdAgent and AP.IdGenericStatus=@IdGenericStatusEnabled
            where MM.IsFilterByAgent=1
		union
			select MM.IdModuloMaster
					from dbo.ModuloMaster MM
						   inner join dbo.AgentChecks AC on AC.IdChecksModulo = MM.IdChekcModulo and AC.IdAgent =@IdAgent
					where MM.IsFilterByAgent=1 
        ) L on M.IdModuloMaster= L.IdModuloMaster  
    inner join [Option] O on M.IdModule=O.IdModule
    inner join ActionAllowed A on O.IdOption = A.IdOption
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
	left join [AdditionalRestriction] AR ON R.[ActionCode] = AR.[ActionCode] AND R.[OptionName] = AR.[OptionName] AND R.[ModuleName] = AR.[ModuleName]
		and ((@IdAgent is null and AR.[ApplyToMonoAgent] = 1) or (@IdAgent is not null and AR.[ApplyToMonoAgent] = 0) )
Where AR.[AdditionalRestrictionId] IS NULL
--and R.OptionName not in ('TransferTo','LunexTopUp','RegaliiTopUp', 'BillPaymentInternational')--#1
--and R.OptionName not in (select provider from @Providers)--#2
--and R.OptionName not in ('LunexTopUp', 'Lunex Commissions')
--and R.OptionName not in ('BillPayment', 'WindowsLog')--#3
--and R.OptionName not in ('BillPayment')--#3
--and R.OptionName <>'WindowsLog' and R.Parentname<>'Application'

