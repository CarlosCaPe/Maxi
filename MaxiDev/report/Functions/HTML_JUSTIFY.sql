
--0 = normal, -1 = bold/italic
CREATE function [report].[HTML_JUSTIFY](
	@Text			varchar(max),
	@Length			float,
	@FontName		varchar(31),
	@FontSize		float,
	@FontBold		int,
	@FontItalic		int
)
returns varchar(max)
as
begin 
	--Constants:
	declare @FontAdjustment float = 200.0  	--200: table report.CharacterWidth generated from MS ACCESS with 10 signs Font Size 20. (20* 10 = 200)

	--variables:
	declare @InList as int = report.False()
	declare @brNeeded_LastLine as int = report.False() --beginning, no br needed!
	declare @brNeeded_CurrentLine as int = report.True() 

	declare @HTMLEnd as int -- Helpervariable for @curHTML (starting with '&' or '<')
	declare @curHTML varchar(max)= ''  -- current HTML-Tag might be long <span ... >

	declare @result varchar(max) = ''
	
	declare @numRegWhiteSpace_all int  -- number of regular white spaces between words 
	declare @sizeWhiteSpace_big int -- size of last white spaces between the first words 
	declare @numWhiteSpace_big int -- number of big white spaces
	declare @neededSizeWhiteSpace_help float
	
	declare @pointer int = 1	-- points to the current character which is handled
	
	declare @curChar varchar(8) -- HTML-masked signs like &Auml; will be handled as one character. So we need more size.
	declare @curCharVal as smallint
	declare @curCharWidth as float
	
	declare @curWord as varchar(max) = ''
	declare @curWordWidth as float = 0

	declare @curLine table
	(
		[no] int,  -- PK, for sort order
		word varchar(max),
		HTML int, --Boolean: Is HTML-Tag (or normal word)
		cWord int
	)
	--Cursor-Vaiables for table @curLine
	declare @word varchar(max)
	declare @HTML int  
	declare @cWord int  --@curLineWordCount
	
	declare @curLineWidth as float = 0
	declare @curLineWordCount as int = 0
	declare @curLineHTMLCount as int  = 0 -- only used to calculate no
	
	declare @whiteSpaceWidth as float
	select @whiteSpaceWidth = cw.[length] / @FontAdjustment * @FontSize from report.CharacterWidth cw with(nolock) where cw.code =  32 and cw.FontName = @FontName and cw.FontBold = report.False() and cw.FontItalic = report.False()
		
	set @Text = replace(@Text,char(13)+char(10),' ') + '  ' -- remove all pagebreaks
	set @Text = replace(@Text,'<br>',' <br>')				-- insert spcae befor break to identify end of line. TODO: Evtl also at </li>?
	
	--loop through all characters. 'set @pointer = @pointer + 1' at the end of the loop
	while @pointer <= len(@Text) + 2  -- len does not count white spaces at the end!
	begin
		set @curChar = SUBSTRING(@Text, @pointer, 1)
		if @curChar = '<' 
		begin
			--HTML-Tag
			--TODO: Changing FontSize
			--<br> does not need special handling, see below ...
			
			set @HTMLEnd = CHARINDEX ('>' ,@Text, @pointer)
			set @curHTML = substring(@Text,@pointer, @HTMLEnd-@pointer+1)
			set @curCharWidth = @whiteSpaceWidth
			set @pointer = @HTMLEnd
			
			if @curHTML = '<b>' set @FontBold = report.True() 
			if @curHTML = '</b>' set @FontBold = report.False() 
			
			if @curHTML = '<i>' set @FontItalic = report.True() 
			if @curHTML = '</i>' set @FontItalic = report.False() 
						
			if @curHTML in ('<ol>','</ol>','<ul>','</ul>','<li>','</li>','<br>')
				set @brNeeded_CurrentLine = report.False() ;  --TODO:  '<li>' correct? 		
			if @curHTML = '<li>' 
			begin
				set @InList = report.True()
				set @curHTML = CHAR(13) + CHAR(10) + @curHTML --CHAR(13) + CHAR(10) only for better readability of the output. no change in the text field. 
			end
			if @curHTML = '</li>' set @InList = report.False();  
		end
		
		if @curChar = '&' 
		begin
			set @HTMLEnd = CHARINDEX (';' ,@Text, @pointer)
			if @HTMLEnd > @pointer and (@HTMLEnd - @pointer < 6) and (CHARINDEX (' ' ,@Text, @pointer) > @HTMLEnd)
			begin
				-- width for special signs not available --> use default value.
				select @curCharWidth = cw.[length] / @FontAdjustment * @FontSize from report.characterwidth cw WITH(NOLOCK) where cw.code =  60 and cw.FontName = @FontName and cw.FontBold = @FontBold  and cw.FontItalic = @FontItalic 
				set @curChar = substring(@Text,@pointer, @HTMLEnd-@pointer+1)
				set @pointer = @HTMLEnd
			end
			if @curChar in ('&Hold;') set @curChar = '&'  -- workaround: It is difficult to tell if &___; is a HTML tag or not.
		end 
				
		if @curChar <> '<' and LEN(@curChar)<=1 -- char32: len:0
		begin	
			--normal text sign
			set @curHTML = ''
			set @curCharVal = ASCII(@curChar)
			select @curCharWidth = cw.[length] / @FontAdjustment * @FontSize from report.characterwidth cw WITH(NOLOCK) where cw.code =  @curCharVal and cw.FontName = @FontName and cw.FontBold = @FontBold  and cw.FontItalic = @FontItalic 
		end 
				
		if @curCharVal = 32 or @curHTML <> '' -- white space/HTML-Tag: new word --> new word
		begin 
			if	(
						@curLineWidth + @curWordWidth <= @length 
					or	@curHTML in ('<br>', CHAR(13) + CHAR(10) + '<li>' , '</li>')
				) and @curWordWidth > 0
 			begin
 				-- insert word in the cur-Lines table
 				-- similar code at: @curWordWidth > 0 below
				set @curLineWordCount = @curLineWordCount + 1
				insert @curLine values(@curLineWordCount+ @curLineHTMLCount, @curWord, report.False(), @curLineWordCount)
				set @curLineWidth = @curLineWidth + @curWordWidth + @curCharWidth -- can be longer than @length! (but @curLineWidth + @curWordWidth <= @length)
				set @curWordWidth = 0
				set @curWord = ''	
			end
			
			if		@curLineWidth + @curWordWidth + @curCharWidth >= @length 
				or	@pointer >= len(@Text) + 1 
				or	@curHTML in ('<br>', CHAR(13) + CHAR(10) + '<li>' , '</li>')
			begin
				--linebreak needed!
				if @brNeeded_LastLine = report.True() and @curLineWordCount>0 
					set @result = @result + '<br>' + CHAR(13)+CHAR(10);
									
				if			@curLineWordCount > 1												-- no justify for the last line!
					and		(@pointer <= len(@Text) - 1 or @curWordWidth > 0)					-- devision by zero
					and		@curHTML not in ('<br>', CHAR(13) + CHAR(10) + '<li>' , '</li>')
				begin
					set @neededSizeWhiteSpace_help = @length - @curLineWidth + (@whiteSpaceWidth * @curLineWordCount) -- white spaces in @curLineWidth subtracted! (@curLineWidth contains @curLineWordCount white spaces!)
					
					set @numRegWhiteSpace_all = @neededSizeWhiteSpace_help / @whiteSpaceWidth / (@curLineWordCount - 1)
					set @neededSizeWhiteSpace_help = @neededSizeWhiteSpace_help - (@numRegWhiteSpace_all * @whiteSpaceWidth * (@curLineWordCount - 1))
					
					set @sizeWhiteSpace_big = (@neededSizeWhiteSpace_help / (@whiteSpaceWidth / @FontSize) / (@curLineWordCount - 1)) + 1
					set @numWhiteSpace_big = (@neededSizeWhiteSpace_help - ((@sizeWhiteSpace_big -1) * (@whiteSpaceWidth / @FontSize) * (@curLineWordCount - 1))) / (@whiteSpaceWidth / @FontSize)
				end
				else
				begin
					-- no extra white spaces
					set @numRegWhiteSpace_all = 1
					set @sizeWhiteSpace_big = 0
					set @numWhiteSpace_big = 0
				end
				
				--read from table and add it to result. Put white spaces between 				
				declare word_cursor cursor for
				select cl.word, cl.HTML, cl.cWord  from @curLine cL order by cL.[no] asc
				open word_cursor
				fetch next from  word_cursor into @word, @HTML, @cWord
				WHILE @@FETCH_STATUS = 0  
				BEGIN 
					set @result = @result + @Word 
					
					if @HTML=report.False() and @cWord < @curLineWordCount  -- no @nbsp; at the end!
					begin
						set @result = @result + ' ' + replace(space(@numRegWhiteSpace_all-1),' ','&nbsp;');
						if @cWord <= @numWhiteSpace_big and @sizeWhiteSpace_big > 0 --the first words have larger white spaces
							set @result = @result + '<span style="font-size: ' + CAST(@sizeWhiteSpace_big as varchar(3)) + 'pt">&nbsp;</span>';
						if @cWord > @numWhiteSpace_big and @sizeWhiteSpace_big > 1 --	the last words
							set @result = @result + '<span style="font-size: ' + CAST((@sizeWhiteSpace_big - 1) as varchar(3)) + 'pt">&nbsp;</span>';
					end --@HTML=report.False() and @cWord < @curLineWordCount
				 
					fetch next from  word_cursor into @word, @HTML, @cWord
				END --WHILE @@FETCH_STATUS = 0  
				close word_cursor;
				deallocate word_cursor;
				
				-- @curLine to @result added --> do reset
				if @InList = report.False()  
					set @curLineWidth = 0;
				else
					set @curLineWidth = 11; --TODO: Only estimation!
				set @curLineWordCount = 0
				set @curLineHTMLCount = 0
				delete @curLine
				set @brNeeded_LastLine = @brNeeded_CurrentLine 
				set @brNeeded_CurrentLine = report.True() 
				
			end --@curLineWidth + @curWordWidth + @curCharWidth >= @length or @pointer = len(@Text) + 1 or	@curHTML in ('<br>', CHAR(13) + CHAR(10) + '<li>' , '</li>')
			
			if @curWordWidth > 0 
			begin
				-- similar code at: (@curLineWidth + @curWordWidth <= @length or @curHTML = '<br>')and @curWordWidth > 0 above!
				set @curLineWordCount = @curLineWordCount + 1
				insert @curLine values(@curLineWordCount + @curLineHTMLCount, @curWord, report.False() , @curLineWordCount)
				set @curLineWidth = @curLineWidth + @curWordWidth + @curCharWidth -- can be longer than @length! (but @curLineWidth + @curWordWidth <= @length)
				set @curWordWidth = 0
				set @curWord = ''	
			end
			
			if @curHTML <> '' 
			begin
				set @curLineHTMLCount = @curLineHTMLCount + 1
				insert @curLine values(@curLineWordCount + @curLineHTMLCount, @curHTML, report.True() , @curLineWordCount);
				set @curHTML = ''	
			end
				
		end --@curCharVal = 32 or @HTML <> ''
		else
		begin
			--regular case: next sign t o add to the word. 
			if @curCharVal > 32 -- no special signs!
			begin
				set @curWord = @curWord + @curChar 
				set @curWordWidth = @curWordWidth + @curCharWidth 
			end	
			--ignore signs
		end
		set @pointer = @pointer + 1
	end --while @pointer <= len(@Text) + 2
	
	RETURN replace(replace(@result,CHAR(13),''),CHAR(10),'')
end

