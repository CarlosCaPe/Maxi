CREATE procedure [MaxiMobile].[st_getDisclaimer]
as
select dbo.GetGlobalAttributeByName('MaxiAgentMobilDisES') MaxiAgentMobilDisES,dbo.GetGlobalAttributeByName('MaxiAgentMobilDisEN') MaxiAgentMobilDisEN
