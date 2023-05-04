create procedure operation.st_GetProviderForEgift
as
select IdProvider,ProviderName from providers where idprovider in (3) order by providername