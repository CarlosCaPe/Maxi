
CREATE procedure [dbo].[st_GetPermissionByUser]
@IdApplication int,
@IdAgent int,
@IdUser int,
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

DECLARE @Providers TABLE (provider varchar(255)) --#2

INSERT INTO @Providers--#2
SELECT Provider
FROM (
SELECT Provider = 'BillPayment'
--SELECT Provider = IIF(@IdUser in (2162), null, 'LunexTopUp')
/*SELECT Provider = 'TransferTo' 
UNION SELECT Provider = IIF(@IdUser in (2162), null, 'LunexTopUp')
UNION SELECT Provider = 'RegaliiTopUp' 
UNION SELECT Provider = 'BillPaymentInternational'*/
)  AS t
WHERE Provider is not null


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
        inner join dbo.OptionUsers OU on OU.IdOption = O.IdOption
        where  M.IdApplication =@IdApplication and OU.IdUser=@IdUser 
		  --and O.Name not in ('TransferTo','LunexTopUp','RegaliiTopUp', 'BillPaymentInternational')--#1
		  --and O.Name not in (select provider from @Providers)--#2
		  --and O.Name not in ('LunexTopUp', 'Lunex Commissions')
		  --and O.Name not in ('BillPayment', 'WindowsLog')--#3
		  --and O.Name not in ('BillPayment')--#3
		  --and O.Name <>'WindowsLog' and O.ParentName<>'Application'
--order by o.parentorder,o.ordernumber
