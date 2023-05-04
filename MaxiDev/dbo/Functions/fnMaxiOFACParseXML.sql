CREATE FUNCTION fnMaxiOFACParseXML
(
	@XMLResult XML
)
RETURNS TABLE
AS
RETURN
(
	SELECT 
		t.c.value('./@SDN_NAME', 'nvarchar(max)') 		SDN_NAME,
		t.c.value('./@SDN_REMARKS', 'nvarchar(max)') 	SDN_REMARKS,
		t.c.value('./@ALT_TYPE', 'nvarchar(max)') 		ALT_TYPE,
		t.c.value('./@ALT_NAME', 'nvarchar(max)') 		ALT_NAME,
		t.c.value('./@ALT_REMARKS', 'nvarchar(max)') 	ALT_REMARKS,
		t.c.value('./@ADD_ADDRESS', 'nvarchar(max)') 	ADD_ADDRESS,
		t.c.value('./@ADD_CITY_NAME', 'nvarchar(max)') 	ADD_CITY_NAME,
		t.c.value('./@ADD_COUNTRY', 'nvarchar(max)') 	ADD_COUNTRY,
		t.c.value('./@ADD_REMARKS', 'nvarchar(max)') 	ADD_REMARKS,
		t.c.value('./@FULL_Match', 'bit') 				FULL_Match,
		t.c.value('./@Percent_Match', 'NUMERIC') 		Percent_Match
	FROM @XMLResult.nodes('/OFACInfo/row') t(c)
)

