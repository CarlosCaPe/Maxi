Create function [dbo].[fn_DigitoVerificadorBTS] (@claim_code varchar(30))
returns nvarchar(30)
Begin

		 DECLARE  @ClaveN    BIGINT,              
		   @Clave    VARCHAR(10),              
		   @Num   VARCHAR(2),              
		   @NumeroCD    VARCHAR(11),              
		   @Numero   INTEGER,               
		   @Numero1  INTEGER,               
		   @Numero2  INTEGER,               
		   @NumTot  INTEGER,              
		   @N1   INTEGER,              
		   @N2   INTEGER,              
		   @N3   INTEGER,              
		   @N4   INTEGER,              
		   @N5   INTEGER,              
		   @N6   INTEGER,              
		   @N7   INTEGER 


		set @ClaveN= convert(bigint,substring(@claim_code,1,10))
		
		    
		          
		 SET @CLAVE = CONVERT(VARCHAR(10),@ClaveN)              
		 SET @numeroCD = @CLAVE              
		              
		 SET @N1 = CONVERT(INT,SUBSTRING(@clave, 4, 1))              
		 SET @N1 = @N1 * 2              
		 -----------------------------------------------------------------------------------------------------------------------------------------------------------------              
		 IF @N1 >= 10               
		  BEGIN              
		  SET @num=CONVERT(VARCHAR(2),@N1)              
		  SET @Numero1= CONVERT(INTEGER,SUBSTRING(@num, 1, 1))              
		  SET @Numero2= CONVERT(INTEGER,SUBSTRING(@num, 2, 1))              
		  SET @N1 = @Numero1+@Numero2              
		  END              
		 -----------------------------------------------------------------------------------------------------------------------------------------------------------------              
		 SET @N2 = CONVERT(INT,SUBSTRING(@clave, 5, 1))              
		 SET @N3 = CONVERT(INT,SUBSTRING(@clave, 6, 1))              
		 SET @N3 = @N3 * 2              
		 -----------------------------------------------------------------------------------------------------------------------------------------------------------------              
		 IF @N3 >= 10               
		  BEGIN              
		  SET @num=CONVERT(VARCHAR(2),@N3)              
		  SET @Numero1= CONVERT(INTEGER,SUBSTRING(@num, 1, 1))              
		  SET @Numero2= CONVERT(INTEGER,SUBSTRING(@num, 2, 1))              
		  SET @N3 = @Numero1+@Numero2              
		  END              
		 -----------------------------------------------------------------------------------------------------------------------------------------------------------------              
		 SET @N4 = CONVERT(INT,SUBSTRING(@clave, 7, 1))              
		 SET @N5 = CONVERT(INT,SUBSTRING(@clave, 8, 1))              
		 SET @N5 = @N5 * 2              
		 -----------------------------------------------------------------------------------------------------------------------------------------------------------------              
		 IF @N5 >= 10               
		  BEGIN              
		  SET @num=CONVERT(VARCHAR(2),@N5)              
		  SET @Numero1= CONVERT(INTEGER,SUBSTRING(@num, 1, 1))              
		  SET @Numero2= CONVERT(INTEGER,SUBSTRING(@num, 2, 1))              
		  SET @N5 = @Numero1+@Numero2              
		  END              
		 -----------------------------------------------------------------------------------------------------------------------------------------------------------------              
		 SET @N6 = CONVERT(INT,SUBSTRING(@clave, 9, 1))              
		 SET @N7 = CONVERT(INT,SUBSTRING(@clave, 10, 1))              
		 SET @N7 = @N7 * 2              
		 -----------------------------------------------------------------------------------------------------------------------------------------------------------------              
		 IF @N7 >= 10               
		  BEGIN              
		  SET @num=CONVERT(VARCHAR(2),@N7)                
		  SET @Numero1= CONVERT(INTEGER,SUBSTRING(@num, 1, 1))              
		  SET @Numero2= CONVERT(INTEGER,SUBSTRING(@num, 2, 1))              
		  SET @N7 = @Numero1+@Numero2              
		  END              
		 -----------------------------------------------------------------------------------------------------------------------------------------------------------------              
		 SET @NumTot = @N1 +  @N2 +  @N3 +  @N4 +  @N5 +  @N6 +  @N7              
		 SET @NumTot = @NumTot % 10              
		 IF @NumTot  > 0               
		  BEGIN              
		  SET @NumTot = 10 - @NumTot              
		  END              
		 ELSE              
		  BEGIN              
		  SET @NumTot=0              
		  END              
		                
		 SET @num = CONVERT(varchar(1),@NumTot)              

		 return @NumeroCD + @Num              
End
