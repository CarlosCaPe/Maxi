create function [dbo].[fnPaymentTypeComparison](@ParameterIdPaymentType int, @ColumnIdPaymentType int)
returns bit
Begin

declare @IdPaymentTypeDirectCash int
set @IdPaymentTypeDirectCash =4

declare @IdPaymentTypeCash int
set @IdPaymentTypeCash =1

return case
			when @ParameterIdPaymentType=@ColumnIdPaymentType then 1
			when @ParameterIdPaymentType = @IdPaymentTypeCash and (@ColumnIdPaymentType=@IdPaymentTypeDirectCash or @ColumnIdPaymentType=@IdPaymentTypeCash) then 1
			else 0
		end


End
