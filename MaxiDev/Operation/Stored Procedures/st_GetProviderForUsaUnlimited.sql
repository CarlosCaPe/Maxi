create procedure operation.st_GetProviderForUsaUnlimited
as
select IdProvider,ProviderName from providers where idprovider in (3) order by providername