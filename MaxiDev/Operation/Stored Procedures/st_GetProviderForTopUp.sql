create procedure operation.st_GetProviderForTopUp
as
select IdProvider,ProviderName from providers where idprovider in (2,4,3) order by providername