create Procedure [dbo].[st_ReportDepositChecksold]      
 (      
 @StartDate Datetime,      
 @EndDate Datetime      
 )
       
 AS

-- -----------------
 SET  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
 SET NOCOUNT ON; 
-- -----------------


--DECLARE @StartDate DATETIME      
--DECLARE @EndDate DATETIME      

--    SET @StartDate = '2016-06-13'
--    SET @EndDate = '2016-06-14'

    Declare @Tomorroy datetime = DateAdd(day, 1, getDate())   
 
		DECLARE  @TempChecks Table  
		(
		Entry DATETIME,
		Agent NVARCHAR(MAX),
		Amount MONEY,
		Notes NVARCHAR(MAX),
		Date DATETIME,
		BankName NVARCHAR(100),
		UserName NVARCHAR(100),
		MoveType NVARCHAR(100),
		DebitOrCredit NVARCHAR(100),
		OrderReport NVARCHAR (5)
		) 


       
		SET @StartDate = dbo.RemoveTimeFromDatetime(@StartDate)      
		SET @EndDate =dbo.RemoveTimeFromDatetime(@EndDate+1)      



		INSERT INTO @TempChecks 
		(
		Entry,
		Agent,
		Amount,
		Notes,
		Date,
		BankName,
		UserName,
		MoveType,
		DebitOrCredit,
		OrderReport
        )
       
    	  SELECT
			 ck.DateOfMovement as Entry, 
			 B.AgentCode +' '+B.AgentName Agent, 
			 ck.Amount Amount,    
			 'By Scanner Process, Check Number: '+  isnull(convert(varchar, ck.CheckNumber),'-')  Notes,  
			 ck.DateStatusChange as Date,     
			 case 
				when IdCheckProcessorBank=1 then'Wells Fargo Sub Account' 
				when IdCheckProcessorBank=2 then'Southside Bank, 1518801' 
				when IdCheckProcessorBank=3 then'Bank of Texas' 
				else ''
			 end BankName ,	
			 U.UserName,   	 	  	    
			 'CHECK' as MoveType,
			 'Credit' DebitOrCredit,
			 'a'	
	    FROM Checks ck 
	   --INNER JOIN AgentBalance AB 
	   --   ON ck.IdCheck = ab.idtransfer
	   INNER JOIN Agent B  
	      ON ck.IdAgent=B.IdAgent   
	   INNER JOIN users U 
	      ON U.IdUser= ck.EnteredByIdUser

	   WHERE ck.IdStatus = 30
	     --AND ab.TypeOfMovement = 'CH'
		 AND ck.BachCode is null
	     AND ck.DateStatusChange > @StartDate 
	     AND ck.DateStatusChange < @EndDate  

----------------------------------Cheques cargados en bach - pagados

       UNION	

	  SELECT
			 MAX(ck.DateOfMovement) as Entry, 
			 MAX(B.AgentCode) +' '+MAX(B.AgentName) Agent, 
			 SUM(ck.Amount) Amount,    
			 dbo.[fn_GetDetailNumberCheckBach] (ck.BachCode, IdCheckProcessorBank)  Notes,  
			 MAX(ck.DateStatusChange) as Date,     
			 case 
				when IdCheckProcessorBank=1 then'Wells Fargo Sub Account' 
				when IdCheckProcessorBank=2 then'Southside Bank, 1518801' 
				when IdCheckProcessorBank=3 then'Bank of Texas' 
				else ''
			 end BankName ,	
			 MAX(U.UserName),   	 	  	    
			 'CHECK' as MoveType,
			 'Credit'	DebitOrCredit,
			  'a'  	  
	    FROM Checks ck 
	   --INNER JOIN AgentBalance AB 
	   --   ON ck.IdCheck = ab.idtransfer
	   INNER JOIN Agent B 
	      ON ck.IdAgent=B.IdAgent   
	   INNER JOIN users U 
	      ON U.IdUser= ck.EnteredByIdUser

	   WHERE ck.IdStatus = 30
	     AND ck.BachCode IS NOT NULL
	     --AND ab.TypeOfMovement = 'CH'
	     AND ck.DateStatusChange > @StartDate 
	     AND ck.DateStatusChange < @EndDate  

	   GROUP BY BachCode, IdCheckProcessorBank


   ---------------------------------------
   ----------------Rechazados-------------
   UNION

     SELECT
			 ck.DateOfMovement as Entry, 
			 B.AgentCode +' '+B.AgentName Agent, 
			 ck.Amount Amount,    
			'By Scanner Process, Check Number: '+  isnull(convert(varchar, ck.CheckNumber),'-')+ ', Note: '+cd.Note  Notes,  
			 ck.DateStatusChange as Date,     
			 case 
				when IdCheckProcessorBank=1 then'Wells Fargo Sub Account' 
				when IdCheckProcessorBank=2 then'Southside Bank, 1518801' 
				when IdCheckProcessorBank=3 then'Bank of Texas' 
				else ''
			 end BankName ,	
			 U.UserName,   	 	  	    
			 'CHECK' as MoveType,
			 'Debit'  DebitOrCredit,
			 'c'	
	    FROM Checks ck 
	   INNER JOIN AgentBalance AB 
	      ON ck.IdCheck = ab.idtransfer
      INNER JOIN
		(
			select max(IdCheckDetail) IdCheckDetail, IdCheck
			from CheckDetails where IdStatus = 31 group by IdCheck
		)l ON l.IdCheck = ck.IdCheck
       INNER JOIN CheckDetails cd ON l.IdCheckDetail = cd.IdCheckDetail
	   INNER JOIN Agent B 
	      ON ck.IdAgent=B.IdAgent   
	   INNER JOIN users U 
	      ON U.IdUser= ck.EnteredByIdUser

	   WHERE ck.IdStatus = 31
	     AND ab.TypeOfMovement = 'CHRTN'
		 --AND ck.BachCode is null
	     AND ck.DateStatusChange > @StartDate 
	     AND ck.DateStatusChange < @EndDate  



		 
		INSERT INTO @TempChecks 
		(
		Entry,
		Agent,
		Amount,
		Notes,
		Date,
		BankName,
		UserName,
		MoveType,
		DebitOrCredit,
		OrderReport
        )
       
		SELECT NULL, Agent, sum(Amount), 'By Scanner Process, ' + BankName + ', Hour: ' + CONVERT(VARCHAR, Date, 108), Date, BankName, 'System', 'CHECK', '', 'a'  
		FROM  @TempChecks 
			WHERE DebitOrCredit = 'Credit' 
			group by Date, Agent, BankName
	


	SELECT [dbo].[ValidateLaboralDay](Date) as Entry, Agent, Amount, Notes, Entry as [Date], BankName, UserName, MoveType,	DebitOrCredit, OrderReport 
	FROM @TempChecks 
	ORDER BY Agent, BankName, OrderReport, Date, isnull( Entry, @tomorroy)

