/* Creación de SP CreateAgentExceptions (Nuevo) */

CREATE procedure [dbo].[st_CreateAgentExceptions]
(
@IdCountry int,
@IdPayer int,
@ExceptionAgentFee int,
@IdAgentApplication int
) as
    INSERT INTO [dbo].[ExceptionsAgentApplication] ([IdCountry],[IdPayer],[ExceptionAgentFee],[IdAgentApplication]) VALUES (@IdCountry, @IdPayer, @ExceptionAgentFee, @IdAgentApplication);
