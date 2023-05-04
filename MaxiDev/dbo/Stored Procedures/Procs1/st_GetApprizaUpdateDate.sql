CREATE procedure [dbo].[st_GetApprizaUpdateDate]                                    
as                                    
Set nocount on                                   
                                              
                                           
Declare @IdGateway int = 32

select 
    min(CONVERT(varchar(8),a.dateoftransfer,112)) ProcessDate,
    replace(convert(varchar, min(a.dateoftransfer), 108),':','') ProcessTime
from [dbo].[Transfer] AS a WITH(NOLOCK) 
    where idstatus in (25,29,23,26) and idgateway=@IdGateway