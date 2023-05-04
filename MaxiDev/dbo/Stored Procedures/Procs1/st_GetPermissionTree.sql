CREATE procedure [dbo].[st_GetPermissionTree]
    @IdLenguage int = null
as

if @IdLenguage is null 
    set @IdLenguage=1

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
from Modulo M
	inner join [Option] O on M.IdModule=O.IdModule
	inner join ActionAllowed A on O.IdOption = A.IdOption
--where O.Name not in ('LunexTopUp', 'Lunex Commissions')
order by  M.IdApplication,o.parentorder,o.ordernumber
