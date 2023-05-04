CREATE FUNCTION dbo.SoundexAplhaFunction( @instring VARCHAR(50) )
RETURNS VARCHAR(50)
AS
BEGIN

    DECLARE @cKey VARCHAR(50),
            @cChar VARCHAR(3),
            @cChars VARCHAR(3),
            @cVowels VARCHAR(10),
            @cFirst_char CHAR(1),
            @cResult VARCHAR(10)

    DECLARE @i integer

    /* vowels */
    SELECT @cVowels = 'AEIOU'

    /* trim all spaces */
    SELECT @instring = REPLACE( @instring, ' ', '' )
    SELECT @instring = UPPER( @instring )

    /* save first char */
    SELECT @cFirst_char = LEFT( @instring, 1 )

    /* ( 1) remove all 'S' and 'Z' chars from the end of the surname */
    SELECT @i = LEN( @instring )
    WHILE SUBSTRING( @instring, @i, 1 ) IN ( 'S', 'Z' )
        SELECT @i = @i - 1
    SELECT @instring = LEFT( @instring, @i )

     /* ( 2) transcode initial strings */
    /*      MAC => MC                 */
    /*      PF => F                     */
    SELECT @instring = CASE
                            WHEN LEFT( @instring, 3 ) = 'MAC' THEN 'MC' + SUBSTRING( @instring, 3, LEN( @instring ) )
                            WHEN LEFT( @instring, 2 ) = 'PF' THEN 'F' + SUBSTRING( @instring, 3, LEN( @instring ) )
                            ELSE @instring    -- do nothing
                       END

    /* ( 3) Transcode trailing strings as follows */
    /*      IX       => IC                        */
    /*      EX       => EC                        */
    /*      YE,EE,IE => Y                         */
    /*      NT,ND    => D                         */
    SELECT @instring = CASE
                            WHEN RIGHT( @instring, 2 ) = 'IX' THEN LEFT( @instring, LEN( @instring ) - 2 ) + 'IC'
                            WHEN RIGHT( @instring, 2 ) = 'EX' THEN LEFT( @instring, LEN( @instring ) - 2 ) + 'EC'
                            WHEN RIGHT( @instring, 2 ) IN ( 'YE', 'EE', 'IE' ) THEN LEFT( @instring, LEN( @instring ) - 2 ) + 'Y'
                            WHEN RIGHT( @instring, 2 ) IN ( 'NT', 'ND' ) THEN LEFT( @instring, LEN( @instring ) - 2 ) + 'D'
                            ELSE @instring    -- do nothing
                       END

    /* the step ( 4) I moved to begining of WHILE ... END below */

    /* ( 5) use first character of name as first character of key */
    /* SELECT @cKey = LEFT( @instring, 1 ) */
    /* don't now, what they thing with this, but with @cKey = '' it seems to be working */
    SELECT @cKey = ''


    SELECT @i = 1
    /* while not end of @instring */
    WHILE SUBSTRING( @instring, @i, 1 ) > ''
    BEGIN
        SELECT @cChars = SUBSTRING( @instring, @i, 3 )

        SELECT @cResult = CASE /* ( 4) transcode 'EV' to 'EF' if not at start of name */
                               WHEN @i > 1 AND LEFT( @cChars, 2 ) = 'EV' THEN 'AF'
                               /* ( 6) remove any 'W' that follows a vowel */
                               WHEN LEFT( @cChars, 1 ) = 'W' AND CHARINDEX( SUBSTRING( @instring, @i - 1, 1 ), @cVowels ) > 0 THEN SUBSTRING( @instring, @i - 1, 1 )
                               /* ( 7) replace all vowels with 'A' */
                               WHEN CHARINDEX( LEFT( @cChars, 1 ), @cVowels ) > 0 THEN 'A'
                                /* ( 8) transcode 'GHT' to 'GT' */
                               WHEN LEFT( @cChars, 2 ) = 'GHT' THEN 'GGG'
                                /* ( 9) transcode 'DG' to 'G' */
                               WHEN LEFT( @cChars, 2 ) = 'DG' THEN 'G'
                               /* (10) transcode 'PH' to 'F' */
                               WHEN LEFT( @cChars, 2 ) = 'PH' THEN 'F'
                                /* (11) if not first character, eliminate all 'H' preceded or followed by a vowel */
                               WHEN LEFT( @cChars, 1 ) = 'H' AND @i > 1 AND ( CHARINDEX( SUBSTRING( @instring, @i - 1, 1 ), @cVowels ) > 0 OR CHARINDEX( SUBSTRING( @instring, @i + 1, 1 ), @cVowels ) > 0 ) THEN SUBSTRING( @instring, @i - 1, 1 )
                               /* (12) change 'KN' to 'N', else 'K' to 'C' */
                               WHEN LEFT( @cChars, 2 ) = 'KN' THEN 'N'
                               WHEN LEFT( @cChars, 1 ) = 'K' THEN 'C'
                               /* (13) if not first character, change 'M' to 'N' */
                               WHEN @i > 1 AND LEFT( @cChars, 1 ) = 'M' THEN 'N'
                               /* (14) if not first character, change 'Q' to 'G' */
                               WHEN @i > 1 AND LEFT( @cChars, 1 ) = 'Q' THEN 'G'
                               /* (15) transcode 'SH' to 'S' */
                               WHEN LEFT( @cChars, 2 ) = 'SH' THEN 'S'
                               /* (16) transcode 'SCH' to 'S' */
                               WHEN @cChars = 'SCH' THEN 'SSS'
                               /* (17) transcode 'YW' to 'Y' */
                               WHEN LEFT( @cChars, 2 ) = 'YW' THEN 'Y'
                               /* (18) if not first or last character, change 'Y' to 'A' */
                               WHEN @i > 1 AND @i < LEN( @instring ) AND LEFT( @cChars, 1 ) = 'Y' THEN 'A'     
                               /* (19) transcode 'WR' to 'R' */
                               WHEN LEFT( @cChars, 2 ) = 'WR' THEN 'R'
                               /* (20) if not first character, change 'Z' to 'S' */
                               WHEN @i > 1 AND LEFT( @cChars, 1 ) = 'Z' THEN 'S'
                               ELSE LEFT( @cChars, 1 )
                         END

        SELECT @instring = STUFF( @instring, @i, LEN( @cResult ), @cResult )

        /* Add current to key if current <> last key character */
        IF RIGHT( @cKey, 1 ) != LEFT( @cResult, 1 )
            SELECT @cKey = @cKey + @cResult


        SELECT @i = @i + 1

    END


    /* (21) transcode terminal 'AY' to 'Y' */
    IF RIGHT( @cKey, 2 ) = 'AY'
        SELECT @cKey = LEFT( @cKey, LEN( @cKey ) - 2 ) + 'Y'
  
    /* (22) remove traling vowels */
    /*      start vowels */
    SELECT @i = 1
    WHILE CHARINDEX( SUBSTRING( @cKey, @i, 1 ), @cVowels ) > 0
        /* replace vowels with spaces */
        SELECT @cKey = STUFF( @cKey, @i, 1, ' ' ),
               @i = @i + 1

    /*     end vowels */
    SELECT @i = LEN( @cKey )
    WHILE CHARINDEX( SUBSTRING( @cKey, @i, 1 ), @cVowels ) > 0
        /* replace vowels with spaces */
        SELECT @cKey = STUFF( @cKey, @i, 1, ' ' ),
               @i = @i - 1
    /*     remove spaces */
    SELECT @cKey = REPLACE( @cKey, ' ', '' )

    /* (23) collapse all strings of repeated characters */
    /* not neede, see 'Add current to key if current <> last key character' before step (21) */

/* (24) if first char of original surname was a vowel, append it to the start of code */
    IF CHARINDEX( @cFirst_char, @cVowels ) > 0
        SELECT @cKey = @cFirst_char + @cKey

    RETURN @cKey

END