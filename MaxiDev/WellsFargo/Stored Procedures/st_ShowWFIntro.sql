create procedure [WellsFargo].[st_ShowWFIntro]
(
    @IdUser int,
    @IsShow bit out
)
as
select @IsShow=IsShow from [WellsFargo].[WFShowIntro] where enterbyiduser=@IdUser


set @IsShow=isnull(@IsShow,1)