

/*  Create de SP st_CreateAgentFee (Nuevo) */

CREATE procedure [dbo].[st_CreateAgentFee]
(
@IdCountry int,
@PercentageFee int,
@IdAgentApplication int
) as
    INSERT INTO [dbo].[FeesAgentApplication] ([IdCountry],[PercentageFee],[IdAgentApplication]) VALUES (@IdCountry, @PercentageFee, @IdAgentApplication);
