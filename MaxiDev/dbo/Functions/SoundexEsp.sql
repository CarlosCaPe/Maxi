CREATE FUNCTION SoundexEsp
(
	@Input VARCHAR(100)
) 
RETURNS VARCHAR(100)
AS
BEGIN
	SET @Input = LTRIM(RTRIM(@Input))

	IF LEN(@Input) = 0
		RETURN NULL;
 
 
	-- 1: LIMPIEZA:
		-- pasar a mayuscula, eliminar la letra "H" inicial, los acentos y la enie
		-- 'holá coñó' => 'OLA CONO'
	SET @Input = REPLACE(UPPER(@Input), 'H', '');
	--ÑÁÉÍÓÚÀÈÌÒÙÜ','NAEIOUAEIOUU'
	
	SET @Input = REPLACE(@Input, 'Ñ', 'N')
	SET @Input = REPLACE(@Input, 'Á', 'A')
	SET @Input = REPLACE(@Input, 'É', 'E')
	SET @Input = REPLACE(@Input, 'Í', 'I')
	SET @Input = REPLACE(@Input, 'Ó', 'O')
	SET @Input = REPLACE(@Input, 'Ú', 'U')
	SET @Input = REPLACE(@Input, 'À', 'A')
	SET @Input = REPLACE(@Input, 'È', 'E')
	SET @Input = REPLACE(@Input, 'Ì', 'I')
	SET @Input = REPLACE(@Input, 'Ò', 'O')
	SET @Input = REPLACE(@Input, 'Ù', 'U')
	SET @Input = REPLACE(@Input, 'Ü', 'U')


 
		-- eliminar caracteres no alfabéticos (números, símbolos como &,%,",*,!,+, etc.
		-- @Input=regexp_replace(@Input, '[^a-zA-Z]', '', 'g');
 
	-- 2: PRIMERA LETRA ES IMPORTANTE, DEBO ASOCIAR LAS SIMILARES
	--  'vaca' se convierte en 'baca'  y 'zapote' se convierte en 'sapote'
	-- un fenomeno importante es GE y GI se vuelven JE y JI; CA se vuelve KA, etc
	DECLARE @FirstLetter		VARCHAR(1),
			@SurrogateLetter	VARCHAR(1),
			@RestWord			VARCHAR(99)

	SET @FirstLetter = SUBSTRING(@Input, 1, 1)
	SET @RestWord = SUBSTRING(@Input, 2, 99)

	SET @SurrogateLetter =CASE 
		WHEN @FirstLetter IN ('V') 
			THEN 'B' 
		WHEN @FirstLetter IN ('Z', 'X') 
			THEN 'S'
		WHEN @FirstLetter IN ('G') AND SUBSTRING(@RestWord, 1, 1) IN ('E', 'I')
			THEN 'J'
		WHEN @FirstLetter IN ('C') AND SUBSTRING(@RestWord, 1, 1) NOT IN ('H','E','I')
			THEN 'K'
		ELSE @FirstLetter 
	END 

	--corregir el parametro con las consonantes sustituidas:
	SET @Input = @SurrogateLetter + @RestWord;		
 
	-- 3: corregir "letras compuestas" y volverlas una sola
	SET @Input = REPLACE(@Input, 'CH', 'V')
	SET @Input = REPLACE(@Input, 'QU', 'K')
	SET @Input = REPLACE(@Input, 'LL', 'J')
	SET @Input = REPLACE(@Input, 'CE', 'S')
	SET @Input = REPLACE(@Input, 'CI', 'S')
	SET @Input = REPLACE(@Input, 'YA', 'J')
	SET @Input = REPLACE(@Input, 'YE', 'J')
	SET @Input = REPLACE(@Input, 'YI', 'J')
	SET @Input = REPLACE(@Input, 'YO', 'J')
	SET @Input = REPLACE(@Input, 'YU', 'J')
	SET @Input = REPLACE(@Input, 'GE', 'J')
	SET @Input = REPLACE(@Input, 'GI', 'J')
	SET @Input = REPLACE(@Input, 'NY', 'N')
 
	-- EMPIEZA EL CALCULO DEL SOUNDEX
	-- 4: OBTENER PRIMERA letra
	SET @FirstLetter = SUBSTRING(@Input, 1, 1)
 
	-- 5: retener el resto del string
	SET @RestWord = SUBSTRING(@Input, 2, 99)
 
	--6: en el resto del string, quitar vocales y vocales fonéticas
	-- AEIOUHWY
	SET @RestWord = REPLACE(@RestWord, 'A', '')
	SET @RestWord = REPLACE(@RestWord, 'E', '')
	SET @RestWord = REPLACE(@RestWord, 'I', '')
	SET @RestWord = REPLACE(@RestWord, 'O', '')
	SET @RestWord = REPLACE(@RestWord, 'U', '')
	SET @RestWord = REPLACE(@RestWord, 'H', '')
	SET @RestWord = REPLACE(@RestWord, 'W', '')
	SET @RestWord = REPLACE(@RestWord, 'Y', '')
 
	--7: convertir las letras foneticamente equivalentes a numeros  (esto hace que B sea equivalente a V, C con S y Z, etc.)
	-- BPFVCGKSXZDTLMNRQJ
	-- 111122222233455677
	SET @RestWord = REPLACE(@RestWord, 'B', '1')
	SET @RestWord = REPLACE(@RestWord, 'P', '1')
	SET @RestWord = REPLACE(@RestWord, 'F', '1')
	SET @RestWord = REPLACE(@RestWord, 'V', '1')
	SET @RestWord = REPLACE(@RestWord, 'C', '2')
	SET @RestWord = REPLACE(@RestWord, 'G', '2')
	SET @RestWord = REPLACE(@RestWord, 'K', '2')
	SET @RestWord = REPLACE(@RestWord, 'S', '2')
	SET @RestWord = REPLACE(@RestWord, 'X', '2')
	SET @RestWord = REPLACE(@RestWord, 'Z', '2')
	SET @RestWord = REPLACE(@RestWord, 'D', '3')
	SET @RestWord = REPLACE(@RestWord, 'T', '3')
	SET @RestWord = REPLACE(@RestWord, 'L', '4')
	SET @RestWord = REPLACE(@RestWord, 'M', '5')
	SET @RestWord = REPLACE(@RestWord, 'N', '5')
	SET @RestWord = REPLACE(@RestWord, 'R', '6')
	SET @RestWord = REPLACE(@RestWord, 'Q', '7')
	SET @RestWord = REPLACE(@RestWord, 'J', '7')


	SET @Input = @SurrogateLetter + @RestWord;	
 
	--8: eliminar números iguales adyacentes (A11233 se vuelve A123)
	DECLARE @Result			VARCHAR(100),
			@Count			INT,
			@LastLetter		VARCHAR(1),
			@CurrentLetter	VARCHAR(1)

	SET @LastLetter = SUBSTRING(@Input,1 ,1);
	SET @Result = @LastLetter;
	SET @Count = 1

	WHILE (@Count < LEN(@Input))
	BEGIN
		SET @Count = @Count + 1
		SET @CurrentLetter = SUBSTRING(@Input, @Count, 1)

		IF @CurrentLetter <> @LastLetter
		BEGIN
			SET @Result = @Result + @CurrentLetter
			SET @LastLetter = @CurrentLetter
		END
	END
 
	--FOR i IN 2 .. LENGTH(soundex) LOOP
	--	actual = substr(soundex, i, 1);
	--	IF actual <> anterior THEN
	--		corregido=corregido || actual;
	--		anterior=actual;			
	--	END IF;
	--END LOOP;
	---- así va la cosa
	--soundex=corregido;
 
	-- 9: siempre retornar un string de 4 posiciones
	--soundex=rpad(soundex,4,'0');
	--soundex=substr(soundex,1,4);		

	SET @Result = LEFT(@Input + '000', 4)
 
	-- YA ESTUVO
	RETURN @Result;	
END;
