create procedure operation.st_GetProviderForLongDistance
as
select IdProvider,ProviderName from providers where idprovider in (4,3) order by providername