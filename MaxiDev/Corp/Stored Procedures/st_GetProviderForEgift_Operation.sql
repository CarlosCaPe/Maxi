CREATE procedure [Corp].[st_GetProviderForEgift_Operation]
as
select IdProvider,ProviderName from providers WITH (NOLOCK) where idprovider in (3) order by providername
