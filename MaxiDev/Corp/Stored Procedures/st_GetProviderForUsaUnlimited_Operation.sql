CREATE procedure [Corp].[st_GetProviderForUsaUnlimited_Operation]
as
select IdProvider,ProviderName from providers WITH (NOLOCK) where idprovider in (3) order by providername
