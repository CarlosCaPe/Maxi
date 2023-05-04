create procedure [WellsFargo].st_GetAgentPINInfo
(
    @IdUser int
)
as
select IdCarrier,CelullarNumber,Email,PIN,* from [WellsFargo].WFPIN where enterbyiduser=@IdUser and idgenericstatus=1

