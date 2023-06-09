﻿CREATE FUNCTION [dbo].[fn_calculateJaroWinkler](@str1 VARCHAR(MAX), @str2 VARCHAR(MAX)) 
RETURNS float As 
BEGIN
	DECLARE @jaro_distance			FLOAT
	DECLARE @jaro_winkler_distance	FLOAT
	DECLARE @prefixLength			INT
	DECLARE @prefixScaleFactor		FLOAT

	SET		@prefixScaleFactor	= 0.1 --Constant = .1

	SET		@jaro_distance	= dbo.fn_calculateJaro(@str1, @str2)	
	SET		@prefixLength	= dbo.fn_calculatePrefixLength(@str1, @str2)

	SET		@jaro_winkler_distance = @jaro_distance + ((@prefixLength * @prefixScaleFactor) * (1.0 - @jaro_distance))
	RETURN	@jaro_winkler_distance
END
