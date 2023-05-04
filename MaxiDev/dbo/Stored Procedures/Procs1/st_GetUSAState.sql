CREATE PROCEDURE [dbo].[st_GetUSAState]
as
select idstate,statename,statecode from state (nolock) where idcountry=18 order by statename
