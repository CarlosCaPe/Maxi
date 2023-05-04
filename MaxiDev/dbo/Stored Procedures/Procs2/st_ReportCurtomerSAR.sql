
CREATE PROCEDURE [dbo].[st_ReportCurtomerSAR]
	   @IdCustomer INT,
	   @dateStart DATE,
	   @dateEnd DATE,

	--
	@IdLenguage int,
	@HasError bit output,
	@ResultMessage nvarchar(max) output
	--
AS
BEGIN

--DECLARE @IdCustomer INT
--DECLARE @dateStart date
--DECLARE @dateEnd date
--    SET @IdCustomer = 282279
--	SET @dateStart = '2013-01-01'
--	SET @dateEnd = '2013-05-01'
--------------------------------
--------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
							     

WITH ctCsDny AS (
				  SELECT TOP 1
						 IdCustomer, 
						 REPLACE(CONVERT(NVARCHAR, DateInToList, 106), ' ', '-') DateInToList,
						 NoteInToList	   
					FROM DenyListCustomer
				   WHERE IdCustomer = @IdCustomer
				   ORDER BY DateInToList DESC 
			     )

, ctStatusSAR AS (
				  SELECT TOP 1
					     IdCustomer,
						 DataLastChange
				    FROM StatusCustomerSAR
				   WHERE StatusSAR = 1
				     AND IdCustomer = @IdCustomer
				   ORDER BY DataLastChange DESC 	
				  )

			SELECT 
				   cs.IdCustomer,
				   cs.Name +' '+cs.FirstLastName+' '+cs.SecondLastName fName,
			       cs.[Address],
				   cs.Country,
			       cs.[State],
			       ISNULL(it.Name,'') IdentificationType,
			       cs.City,
			       ISNULL(CONVERT(VARCHAR,it.IdCustomerIdentificationType), '') IdCustomerIdentificationType,    
				   REPLACE(CONVERT(NVARCHAR, sr.DataLastChange, 106), ' ', '-') DataLastChange,
				   ctCsDny.DateInToList,
			       ctCsDny.NoteInToList
		      FROM Customer cs
		      LEFT JOIN CustomerIdentificationType it
		        ON cs.IdCustomer = it.IdCustomerIdentificationType    
	  		   LEFT JOIN ctStatusSAR sr --ultimo y activado (1)  
	               ON cs.IdCustomer = sr.IdCustomer
		      LEFT JOIN ctCsDny
		        ON ctCsDny.IdCustomer = cs.IdCustomer 						 
			-------
		     WHERE cs.IdCustomer = @IdCustomer	

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
	SELECT 
		   REPLACE(CONVERT(NVARCHAR, rt.DateOfTransfer, 106), ' ', '-') DataLastChange,
		   ag.AgentCode,
		   rt.folio,
		   bn.IdBeneficiary,
		   bn.Country,
		   bn.Name +' '+bn.FirstLastName +' '+bn.SecondLastName bFlName,
		   --
		   bn.[State],
		   ISNULL(ste.StateName,'') StateName,
		   rt.AmountInDollars,
		   st.StatusName,
		   agt.AgentName,
		   py.PayerName
      FROM [Transfer] rt
	 INNER JOIN Agent ag
	    ON rt.IdAgent = ag.IdAgent
	  LEFT JOIN Beneficiary bn
	    ON rt.IdBeneficiary = bn.IdBeneficiary
--------------------------------------------------------	  
	  LEFT JOIN	TransferPayInfo  rpi
	    ON rt.IdTransfer = rpi.IdTransfer and rpi.IdTransferPayInfo = ( SELECT MAX(IdTransferPayInfo) 
																		        FROM TransferPayInfo 
																		       WHERE IdTransfer = rt.IdTransfer )

	  LEFT JOIN branch br
		ON rpi.IdBranch = br.IdBranch	
	  LEFT JOIN City cy
	    ON cy.IdCity = br.IdCity
	 LEFT JOIN [state] ste
	    ON ste.IdState = cy.IdState	 							  
--------------------------------------------------------				
	 LEFT JOIN [Status] st
		ON rt.IdStatus = st.IdStatus
	 LEFT JOIN [Agent] agt
	    ON rt.IdAgent = agt.IdAgent
	 LEFT JOIN Payer py	
	    ON rt.IdPayer = py.IdPayer

     WHERE rt.IdCustomer = @IdCustomer
	   AND rt.DateOfTransfer >= @dateStart
	   AND rt.DateOfTransfer <= @dateEnd

	   UNION

	   SELECT 
		   REPLACE(CONVERT(NVARCHAR, rt.DateOfTransfer, 106), ' ', '-') DataLastChange,
		   ag.AgentCode,
		   rt.folio,
		   bn.IdBeneficiary,
		   bn.Country,
		   bn.Name +' '+bn.FirstLastName +' '+bn.SecondLastName bFlName,
		   --
		   bn.[State],
		   ISNULL(ste.StateName,'') StateName,
		   rt.AmountInDollars,
		   st.StatusName,
		   agt.AgentName,
		   py.PayerName
      FROM [TransferClosed] rt
	 INNER JOIN Agent ag
	    ON rt.IdAgent = ag.IdAgent
	  LEFT JOIN Beneficiary bn
	    ON rt.IdBeneficiary = bn.IdBeneficiary
--------------------------------------------------------	  
	  LEFT JOIN	TransferPayInfo  rpi
	    ON rt.IdTransferClosed = rpi.IdTransfer and rpi.IdTransferPayInfo = ( SELECT MAX(IdTransferPayInfo) 
																		        FROM TransferPayInfo 
																		       WHERE IdTransfer = rt.IdTransferClosed )

	  LEFT JOIN branch br
		ON rpi.IdBranch = br.IdBranch	
	  LEFT JOIN City cy
	    ON cy.IdCity = br.IdCity
	  LEFT JOIN [state] ste
	    ON ste.IdState = cy.IdState	 							  
--------------------------------------------------------					
	 INNER JOIN [Status] st
		ON rt.IdStatus = st.IdStatus
	 INNER JOIN [Agent] agt
	    ON rt.IdAgent = agt.IdAgent
	 INNER JOIN Payer py	
	    ON rt.IdPayer = py.IdPayer

     WHERE rt.IdCustomer = @IdCustomer
	   AND rt.DateOfTransfer >= @dateStart
	   AND rt.DateOfTransfer <= @dateEnd

END 