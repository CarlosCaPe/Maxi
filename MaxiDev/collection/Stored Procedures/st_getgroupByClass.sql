create PROCEDURE COLLECTION.st_getgroupByClass
as
select t.IdAgentClass,t.IsSpecial,AgentClass,isnull(tot,0) TOT from (
select idagentclass,0 IsSpecial,Description AgentClass from AgentClass
union all
select idagentclass,1 IsSpecial,'Special Category ' + Description AgentClass from AgentClass
) t
left join
(
	SELECT 
		G.IdAgentClass,IsSpecial,COUNT(1) TOT 
	FROM 
		COLLECTION.Groups G
	JOIN
		AgentClass C ON G.IdAgentClass=C.IdAgentClass
	Where
		g.IdGenericStatus=1
	GROUP BY 
		G.IdAgentClass,IsSpecial,C.Description	
) tot on t.IdAgentClass=tot.IdAgentClass and t.IsSpecial=tot.IsSpecial
ORDER BY
		t.AgentClass

--SELECT 
--	G.IdAgentClass,IsSpecial,case when IsSpecial=1 then 'Special Category ' else '' end + c.Description  AgentClass,COUNT(1) TOT 
--FROM 
--	COLLECTION.Groups G
--JOIN
--	AgentClass C ON G.IdAgentClass=C.IdAgentClass
--Where
--	g.IdGenericStatus=1
--GROUP BY 
--	G.IdAgentClass,IsSpecial,C.Description
--ORDER BY
--	C.Description