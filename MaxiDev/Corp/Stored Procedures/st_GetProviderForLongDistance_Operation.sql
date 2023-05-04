CREATE procedure [Corp].[st_GetProviderForLongDistance_Operation]
as
select IdProvider,ProviderName from providers WITH (NOLOCK)  where idprovider in (4,3) order by providername
