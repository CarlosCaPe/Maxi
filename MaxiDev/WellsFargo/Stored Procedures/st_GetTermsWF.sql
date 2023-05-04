create procedure [WellsFargo].[st_GetTermsWF]
(
    @IdLenguage int
)
as
select [dbo].[GetMessageFromMultiLenguajeResorces](@IdLenguage,'ECHEKTERMS') Terms