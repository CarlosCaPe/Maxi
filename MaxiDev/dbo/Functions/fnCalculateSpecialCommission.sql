CREATE function [dbo].[fnCalculateSpecialCommission] 
(
@TempApplyForTransaction bit,
	@TempCommission money,	
	@TempFrom int,
	@TempTo int,
	@TempNumberTransactions int
)
returns money
BEGIN
	declare @TempCommissionResult money=0

	IF (@TempApplyForTransaction=0)
				BEGIN
					SET @TempCommissionResult=@TempCommission
				END
			ELSE
				BEGIN
					
					IF(@TempTo=0 or @TempTo>@TempNumberTransactions)
						BEGIN
							IF(@TempFrom<=0)
								BEGIN
									SET @TempCommissionResult=@TempCommission*(@TempNumberTransactions)
								END
							ELSE
								BEGIN
									IF (@TempNumberTransactions<=@TempFrom)
										BEGIN
											SET @TempCommissionResult=0
										END
									ELSE
										BEGIN
											SET @TempCommissionResult=@TempCommission*(@TempNumberTransactions-@TempFrom+1)
										END
								END							
						END
					ELSE
						BEGIN
							IF(@TempFrom<=0)
								BEGIN
									SET @TempCommissionResult=@TempCommission*(@TempTo)
								END
							ELSE
								BEGIN
									IF (@TempTo<=@TempFrom)
										BEGIN
											SET @TempCommissionResult=0
										END
									ELSE
										BEGIN
											SET @TempCommissionResult=@TempCommission*(@TempTo-@TempFrom+1)
										END
								END		
							
						END
											
				END
	
	return  @TempCommissionResult
END