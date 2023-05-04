CREATE PROCEDURE Soporte.st_GetContactsStamps
AS
BEGIN
	SELECT
		REPLACE(O.Name, ',', '') 'Name',
		REPLACE(CONCAT(O.LastName, ' ', O.SecondLastName), ',', '') 'Last Name', 
		REPLACE(CONCAT(A.AgentCode, ' ', A.AgentName), ',', '') 'Company', 
		REPLACE(A.AgentAddress, ',', '') 'Address', 
		REPLACE(A.AgentCity, ',', '')  'City',
		REPLACE(a.AgentState, ',', '') 'State', 
		REPLACE(A.AgentZipcode, ',', '') 'ZIP Code'
	FROM	Agent A WITH(NOLOCK),
			Owner O WITH(NOLOCK),
            Users U WITH(NOLOCK)
	WHERE A.IdOwner = O.IdOwner
	AND A.IdUserSeller = U.IdUser
	AND NOT A.IdAgentStatus in ('2','5','6')
	ORDER BY A.AgentCode
END


