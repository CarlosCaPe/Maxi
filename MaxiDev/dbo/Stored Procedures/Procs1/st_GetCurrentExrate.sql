CREATE procedure [dbo].[st_GetCurrentExrate] (@IdCountryCurrency money, @IdGateway money, @IdPayer money, @IdAgent int, @IdCity int, @IdPaymentType int, @IdAgentSchema int,@AmountInDollars MONEY, @CurrentExRate money out)  
as

SELECT @CurrentExRate = dbo.FunCurrentExRate(@IdCountryCurrency,@IdGateway,@IdPayer,@Idagent,@idcity,@IdPaymentType,@IdAgentSchema,@AmountInDollars)--@ActualExRate--[dbo].[FunRefExRate] (@IdCountryCurrency,@IdGateway,@IdPayer)
